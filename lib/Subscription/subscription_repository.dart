import 'package:dharma_app/Subscription/subscription_model.dart';
import 'package:dharma_app/core/utils/api_utils.dart';
import 'package:dharma_app/services/api_service.dart';
import 'package:get/get.dart';

class SubscriptionRepository {
  SubscriptionRepository({ApiService? apiService})
      : _apiService = apiService ??
            (Get.isRegistered<ApiService>()
                ? Get.find<ApiService>()
                : Get.put(ApiService(), permanent: true));

  final ApiService _apiService;

  Future<SubscriptionPlansResponseModel> listPlans() async {
    final response = await _apiService.listSubscriptionPlans();
    final mapBody = ApiUtils.asMap(response.body);

    if (mapBody != null) {
      return SubscriptionPlansResponseModel.fromJson(mapBody);
    }

    return SubscriptionPlansResponseModel(
      success: false,
      message: response.statusText ?? 'Failed to fetch subscription plans',
    );
  }

  Future<CreateSubscriptionOrderResponseModel> createOrder({
    required int planId,
  }) async {
    final response = await _apiService.createSubscriptionOrder(planId: planId);
    final mapBody = ApiUtils.asMap(response.body);

    if (mapBody != null) {
      return CreateSubscriptionOrderResponseModel.fromJson(mapBody);
    }

    return CreateSubscriptionOrderResponseModel(
      success: false,
      message: response.statusText ?? 'Failed to create subscription order',
    );
  }

  Future<VerifySubscriptionPaymentResponseModel> verifyPayment({
    required Map<String, dynamic> body,
  }) async {
    final response = await _apiService.verifySubscriptionPayment(body: body);
    final mapBody = ApiUtils.asMap(response.body);

    if (mapBody != null) {
      return VerifySubscriptionPaymentResponseModel.fromJson(mapBody);
    }

    return VerifySubscriptionPaymentResponseModel(
      success: false,
      message: response.statusText ?? 'Failed to verify subscription payment',
    );
  }
}
