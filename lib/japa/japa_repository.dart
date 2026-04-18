import 'package:dharma_app/core/utils/api_utils.dart';
import 'package:dharma_app/japa/japa_model.dart';
import 'package:dharma_app/services/api_service.dart';
import 'package:get/get.dart';

class JapaRepository {
  JapaRepository({ApiService? apiService})
      : _apiService = apiService ??
            (Get.isRegistered<ApiService>()
                ? Get.find<ApiService>()
                : Get.put(ApiService(), permanent: true));

  final ApiService _apiService;

  Future<JapaStatusResponseModel> getJapaStatus({int? mantraId}) async {
    final response = await _apiService.getJapaStatus(mantraId: mantraId);
    final mapBody = ApiUtils.asMap(response.body);

    if (mapBody != null) {
      return JapaStatusResponseModel.fromJson(mapBody);
    }

    return JapaStatusResponseModel(
      success: false,
      message: response.statusText ?? 'Failed to fetch japa status',
    );
  }

  Future<JapaStatusResponseModel> saveJapaProgress({
    required int mantraId,
    int? incrementBy,
    int? currentCount,
    int? chantCount,
    int? targetCount,
  }) async {
    final response = await _apiService.saveJapaProgress(
      mantraId: mantraId,
      incrementBy: incrementBy,
      currentCount: currentCount,
      chantCount: chantCount,
      targetCount: targetCount,
    );
    final mapBody = ApiUtils.asMap(response.body);

    if (mapBody != null) {
      return JapaStatusResponseModel.fromJson(mapBody);
    }

    return JapaStatusResponseModel(
      success: false,
      message: response.statusText ?? 'Failed to save japa progress',
    );
  }
}
