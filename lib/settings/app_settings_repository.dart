import 'package:dharma_app/core/utils/api_utils.dart';
import 'package:dharma_app/services/api_service.dart';
import 'package:dharma_app/settings/app_settings_model.dart';
import 'package:get/get.dart';

class AppSettingsRepository {
  AppSettingsRepository({ApiService? apiService})
    : _apiService =
          apiService ??
          (Get.isRegistered<ApiService>()
              ? Get.find<ApiService>()
              : Get.put(ApiService(), permanent: true));

  final ApiService _apiService;

  Future<PublicSettingsResponseModel> getPublicSettings({
    String? settingKey,
  }) async {
    final response = await _apiService.getPublicSettings(
      settingKey: settingKey,
    );
    final mapBody = ApiUtils.asMap(response.body);

    if (mapBody != null) {
      return PublicSettingsResponseModel.fromJson(mapBody);
    }

    return PublicSettingsResponseModel(
      success: false,
      message: response.statusText ?? 'Failed to fetch public settings',
    );
  }
}
