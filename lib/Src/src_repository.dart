import 'package:dharma_app/Src/src_model.dart';
import 'package:dharma_app/core/utils/api_utils.dart';
import 'package:dharma_app/services/api_service.dart';
import 'package:get/get.dart';

class SrcRepository {
  SrcRepository({ApiService? apiService})
      : _apiService = apiService ??
            (Get.isRegistered<ApiService>()
                ? Get.find<ApiService>()
                : Get.put(ApiService(), permanent: true));

  final ApiService _apiService;

  Future<CreateSrcOrderResponseModel> createOrder({
    required int srcQuantity,
  }) async {
    final response = await _apiService.createSrcOrder(srcQuantity: srcQuantity);
    final mapBody = ApiUtils.asMap(response.body);

    if (mapBody != null) {
      return CreateSrcOrderResponseModel.fromJson(mapBody);
    }

    return CreateSrcOrderResponseModel(
      success: false,
      message: response.statusText ?? 'Failed to create SRC order',
    );
  }

  Future<VerifySrcPaymentResponseModel> verifyPayment({
    required Map<String, dynamic> body,
  }) async {
    final response = await _apiService.verifySrcPayment(body: body);
    final mapBody = ApiUtils.asMap(response.body);

    if (mapBody != null) {
      return VerifySrcPaymentResponseModel.fromJson(mapBody);
    }

    return VerifySrcPaymentResponseModel(
      success: false,
      message: response.statusText ?? 'Failed to verify SRC payment',
    );
  }

  Future<SrcHistoryResponseModel> getHistory() async {
    final response = await _apiService.getSrcHistory();
    final mapBody = ApiUtils.asMap(response.body);

    if (mapBody != null) {
      return SrcHistoryResponseModel.fromJson(mapBody);
    }

    return SrcHistoryResponseModel(
      success: false,
      message: response.statusText ?? 'Failed to fetch SRC history',
    );
  }
}
