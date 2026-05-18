import 'package:dharma_app/Profile/profile_controller.dart';
import 'package:dharma_app/Src/src_model.dart';
import 'package:dharma_app/Src/src_repository.dart';
import 'package:dharma_app/core/utils/toast_utils.dart';
import 'package:dharma_app/services/payment_error_mapper.dart';
import 'package:dharma_app/services/storage_service.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class SrcController extends GetxController {
  SrcController({SrcRepository? repository})
      : _repository = repository ??
            (Get.isRegistered<SrcRepository>()
                ? Get.find<SrcRepository>()
                : Get.put(SrcRepository(), permanent: true));

  final SrcRepository _repository;
  final Razorpay _razorpay = Razorpay();

  final isLoadingHistory = false.obs;
  final isCreatingOrder = false.obs;
  final isOpeningCheckout = false.obs;
  final isVerifyingPayment = false.obs;
  final pendingQuantity = RxnInt();
  final historyError = ''.obs;
  final history = Rxn<SrcHistoryData>();

  SrcOrderData? _pendingOrder;

  List<SrcHistoryTransaction> get transactions =>
      history.value?.transactions ?? const [];

  double get currentBalance {
    final historyBalance = history.value?.user?.coin;
    if (historyBalance != null) return historyBalance;

    if (Get.isRegistered<ProfileController>()) {
      return Get.find<ProfileController>().srcBalance;
    }
    return 0;
  }

  @override
  void onInit() {
    super.onInit();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    if (StorageService.getToken()?.isNotEmpty == true) {
      loadHistory(silent: true);
    }
  }

  Future<void> loadHistory({bool silent = false}) async {
    if (isLoadingHistory.value) return;
    isLoadingHistory.value = true;
    historyError.value = '';

    try {
      final response = await _repository.getHistory();
      if (!response.success) {
        historyError.value = response.message.isNotEmpty
            ? response.message
            : 'SRC history load nahi ho paayi.';
        return;
      }
      history.value = response.data;
    } finally {
      isLoadingHistory.value = false;
    }
  }

  Future<void> refreshHistory() => loadHistory();

  Future<void> purchaseSrc(int srcQuantity) async {
    if (srcQuantity <= 0) {
      ToastUtils.show('src_quantity_invalid'.tr);
      return;
    }
    if (isCreatingOrder.value) return;

    isCreatingOrder.value = true;
    pendingQuantity.value = srcQuantity;

    try {
      final response = await _repository.createOrder(srcQuantity: srcQuantity);
      if (!response.success) {
        ToastUtils.show(
          response.message.isNotEmpty
              ? response.message
              : 'src_order_create_failed'.tr,
        );
        pendingQuantity.value = null;
        return;
      }

      final data = response.data;
      final order = data?.order;
      if (data?.razorpayKeyId == null ||
          data!.razorpayKeyId!.isEmpty ||
          order?.orderId == null ||
          order!.orderId!.isEmpty ||
          order.amount == null) {
        ToastUtils.show('invalid_src_razorpay_order_response'.tr);
        pendingQuantity.value = null;
        return;
      }

      _pendingOrder = data;
      isOpeningCheckout.value = true;
      _openRazorpayCheckout(data);
    } finally {
      isCreatingOrder.value = false;
    }
  }

  void _openRazorpayCheckout(SrcOrderData orderData) {
    final profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController(), permanent: true);
    final user = profileController.user;
    final loginEmail = _clean(StorageService.getLoginEmail());
    final loginMobile = _clean(StorageService.getLoginMobile());
    final profileEmail = _clean(user?.email);
    final profileMobile = _clean(user?.mobile);
    final quantity = orderData.src?.srcQuantity ?? pendingQuantity.value ?? 0;
    final prefill = <String, dynamic>{
      'name': user?.fullName ?? '',
    };

    if (loginEmail != null) {
      prefill['email'] = loginEmail;
    } else if (loginMobile != null) {
      prefill['contact'] = loginMobile;
    } else {
      if (profileEmail != null) {
        prefill['email'] = profileEmail;
      }
      if (profileMobile != null) {
        prefill['contact'] = profileMobile;
      }
    }

    final options = <String, dynamic>{
      'key': orderData.razorpayKeyId,
      'amount': orderData.order?.amount,
      'currency': orderData.order?.currency ?? 'INR',
      'name': 'Global Sanatan Community',
      'description': 'buy_src_description'.trParams({'quantity': '$quantity'}),
      'order_id': orderData.order?.orderId,
      'prefill': prefill,
      'notes': {
        'transaction_id': orderData.transactionId?.toString() ?? '',
        'src_quantity': quantity.toString(),
      },
      'theme': {
        'color': '#0B0A79',
      },
    };

    try {
      _razorpay.open(options);
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (isClosed) return;
        if (isOpeningCheckout.value) {
          isOpeningCheckout.value = false;
        }
      });
    } catch (_) {
      isOpeningCheckout.value = false;
      pendingQuantity.value = null;
      ToastUtils.show('razorpay_open_failed'.tr);
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    isOpeningCheckout.value = false;
    isVerifyingPayment.value = true;
    try {
      final order = _pendingOrder?.order;
      if (order?.orderId == null || order!.orderId!.isEmpty) {
        ToastUtils.show('payment_response_invalid'.tr);
        pendingQuantity.value = null;
        return;
      }

      final verifyResponse = await _repository.verifyPayment(
        body: {
          'razorpay_order_id': response.orderId ?? order.orderId!,
          'payment_status': 'captured',
          'razorpay_payment_id': response.paymentId ?? '',
          'razorpay_signature': response.signature ?? '',
        },
      );

      if (!verifyResponse.success) {
        ToastUtils.show(
          verifyResponse.message.isNotEmpty
              ? verifyResponse.message
              : 'src_payment_verify_failed'.tr,
        );
        return;
      }

      ToastUtils.show(
        verifyResponse.message.isNotEmpty
            ? verifyResponse.message
            : 'src_purchase_completed_successfully'.tr,
      );
      await _refreshProfileAndHistory();
      _clearPendingState();
    } finally {
      isVerifyingPayment.value = false;
    }
  }

  Future<void> _handlePaymentError(PaymentFailureResponse response) async {
    isOpeningCheckout.value = false;
    isVerifyingPayment.value = true;
    try {
      final errorDetails = PaymentErrorMapper.fromFailure(response);
      final orderId = _pendingOrder?.order?.orderId;
      if (orderId != null && orderId.isNotEmpty) {
        await _repository.verifyPayment(
          body: {
            'razorpay_order_id': orderId,
            'payment_status': 'failed',
            'razorpay_payment_id': '',
            'error_code': errorDetails.apiCode,
            'error_description': errorDetails.apiDescription,
          },
        );
        await loadHistory(silent: true);
      }

      _clearPendingState();
      if (errorDetails.showToast) {
        ToastUtils.show(errorDetails.userMessage);
      }
    } finally {
      isVerifyingPayment.value = false;
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    isOpeningCheckout.value = false;
    ToastUtils.show(
      response.walletName == null
          ? 'external_wallet_selected'.tr
          : 'external_wallet_selected_named'.trParams({
              'wallet': response.walletName ?? '',
            }),
    );
  }

  Future<void> _refreshProfileAndHistory() async {
    if (Get.isRegistered<ProfileController>()) {
      await Get.find<ProfileController>().loadProfile(silent: true);
    }
    await loadHistory(silent: true);
  }

  void _clearPendingState() {
    _pendingOrder = null;
    pendingQuantity.value = null;
  }

  String? _clean(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }
    return text;
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }
}
