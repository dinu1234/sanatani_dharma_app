import 'package:dharma_app/AskPandit/ask_pandit_model.dart';
import 'package:dharma_app/core/utils/api_utils.dart';
import 'package:dharma_app/services/api_service.dart';
import 'package:get/get.dart';

class AskPanditRepository {
  AskPanditRepository({ApiService? apiService})
    : _apiService =
          apiService ??
          (Get.isRegistered<ApiService>()
              ? Get.find<ApiService>()
              : Get.put(ApiService(), permanent: true));

  final ApiService _apiService;

  Future<AskPanditResponseModel> askQuestion({
    required String question,
    String? sessionId,
    int stream = 0,
    double? lat,
    double? lng,
  }) async {
    final response = await _apiService.askPandit(
      question: question,
      sessionId: sessionId,
      stream: stream,
      lat: lat,
      lng: lng,
    );
    final mapBody = ApiUtils.asMap(response.body);
    if (mapBody != null) {
      return AskPanditResponseModel.fromJson(mapBody);
    }
    return AskPanditResponseModel(
      success: false,
      message: response.statusText ?? 'Unable to fetch Ask Pandit response',
    );
  }
}
