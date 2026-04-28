import 'package:dharma_app/Profile/profile_controller.dart';
import 'package:dharma_app/Subscription/subscription_model.dart';
import 'package:dharma_app/Subscription/subscription_repository.dart';
import 'package:dharma_app/core/utils/toast_utils.dart';
import 'package:dharma_app/services/storage_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class SubscriptionController extends GetxController {
  SubscriptionController({SubscriptionRepository? repository})
      : _repository = repository ??
            (Get.isRegistered<SubscriptionRepository>()
                ? Get.find<SubscriptionRepository>()
                : Get.put(SubscriptionRepository(), permanent: true));

  final SubscriptionRepository _repository;
  final Razorpay _razorpay = Razorpay();

  final isLoading = false.obs;
  final isCreatingOrder = false.obs;
  final isVerifyingPayment = false.obs;
  final processingPlanId = RxnInt();
  final errorMessage = ''.obs;
  final plans = <SubscriptionPlan>[].obs;
  SubscriptionOrderData? _pendingOrder;
  SubscriptionPlan? _pendingPlan;
  Widget Function()? _successDestinationBuilder;

  SubscriptionPlan? get latestPlan {
    if (plans.isEmpty) return null;
    return plans.reduce((current, next) {
      final currentId = current.id ?? 0;
      final nextId = next.id ?? 0;
      return nextId >= currentId ? next : current;
    });
  }

  @override
  void onInit() {
    super.onInit();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> loadPlans() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.listPlans();
      if (response.success) {
        plans.assignAll(response.data?.plans ?? const []);
      } else {
        plans.clear();
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Subscription plans load nahi ho paaye.';
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPlans() => loadPlans();

  void setPaymentSuccessDestination(Widget Function()? builder) {
    _successDestinationBuilder = builder;
  }

  Future<void> ensurePlansLoaded() async {
    if (plans.isNotEmpty || isLoading.value) return;
    await loadPlans();
  }

  Future<void> choosePlan(SubscriptionPlan plan) async {
    final planId = plan.id;
    if (planId == null || planId <= 0) {
      ToastUtils.show('Invalid subscription plan');
      return;
    }
    if (isCreatingOrder.value) return;

    isCreatingOrder.value = true;
    processingPlanId.value = planId;

    try {
      final response = await _repository.createOrder(planId: planId);
      if (!response.success) {
        ToastUtils.show(
          response.message.isNotEmpty
              ? response.message
              : 'Subscription order create nahi ho paaya.',
        );
        return;
      }

      final data = response.data;
      final order = data?.order;
      if (data?.razorpayKeyId == null ||
          data!.razorpayKeyId!.isEmpty ||
          order?.orderId == null ||
          order!.orderId!.isEmpty ||
          order.amount == null) {
        ToastUtils.show('Invalid Razorpay order response');
        return;
      }

      _pendingOrder = data;
      _pendingPlan = plan;
      _openRazorpayCheckout(data, plan);
    } finally {
      isCreatingOrder.value = false;
    }
  }

  void _openRazorpayCheckout(
    SubscriptionOrderData orderData,
    SubscriptionPlan plan,
  ) {
    final profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController(), permanent: true);
    final user = profileController.user;
    final loginEmail = _clean(StorageService.getLoginEmail());
    final loginMobile = _clean(StorageService.getLoginMobile());
    final profileEmail = _clean(user?.email);
    final profileMobile = _clean(user?.mobile);
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
      'description': plan.displayName,
      'order_id': orderData.order?.orderId,
      'prefill': prefill,
      'notes': {
        'plan_id': plan.id?.toString() ?? '',
        'transaction_id': orderData.transactionId?.toString() ?? '',
      },
      'theme': {
        'color': '#0B0A79',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      processingPlanId.value = null;
      ToastUtils.show('Razorpay open nahi ho paaya.');
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    isVerifyingPayment.value = true;
    try {
      final plan = _pendingPlan;
      final order = _pendingOrder?.order;
      if (plan?.id == null || order?.orderId == null) {
        ToastUtils.show('Payment response invalid hai.');
        processingPlanId.value = null;
        return;
      }

      final verifyResponse = await _repository.verifyPayment(
        body: {
          'plan_id': plan!.id,
          'razorpay_order_id': response.orderId ?? order!.orderId!,
          'payment_status': 'captured',
          'razorpay_payment_id': response.paymentId ?? '',
          'transaction_id': response.paymentId ?? '',
          'razorpay_signature': response.signature ?? '',
        },
      );

      processingPlanId.value = null;

      if (!verifyResponse.success) {
        ToastUtils.show(
          verifyResponse.message.isNotEmpty
              ? verifyResponse.message
              : 'Payment verify nahi ho paaya.',
        );
        return;
      }

      ToastUtils.show(
        verifyResponse.message.isNotEmpty
            ? verifyResponse.message
            : 'Subscription activated successfully.',
      );

      if (Get.isRegistered<ProfileController>()) {
        await Get.find<ProfileController>().loadProfile(silent: true);
      }
      _pendingOrder = null;
      _pendingPlan = null;
      final destinationBuilder = _successDestinationBuilder;
      if (destinationBuilder != null) {
        Get.off(() => destinationBuilder());
      } else {
        Get.back();
      }
    } finally {
      isVerifyingPayment.value = false;
    }
  }

  Future<void> _handlePaymentError(PaymentFailureResponse response) async {
    isVerifyingPayment.value = true;
    try {
      final plan = _pendingPlan;
      final orderId = _pendingOrder?.order?.orderId;
      if (plan?.id != null && orderId != null && orderId.isNotEmpty) {
        await _repository.verifyPayment(
          body: {
            'plan_id': plan!.id,
            'razorpay_order_id': orderId,
            'payment_status': 'failed',
            'razorpay_payment_id': '',
            'error_code': response.code?.toString() ?? '',
            'error_description': response.message ?? 'Payment failed',
          },
        );
      }

      processingPlanId.value = null;
      ToastUtils.show(response.message ?? 'Payment failed');
    } finally {
      isVerifyingPayment.value = false;
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ToastUtils.show(
      response.walletName == null
          ? 'External wallet selected'
          : 'External wallet selected: ${response.walletName}',
    );
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
