import 'package:dharma_app/content/content_model.dart';
import 'package:dharma_app/core/utils/api_utils.dart';
import 'package:dharma_app/services/api_service.dart';
import 'package:get/get.dart';

class ContentRepository {
  ContentRepository({ApiService? apiService})
      : _apiService = apiService ??
            (Get.isRegistered<ApiService>()
                ? Get.find<ApiService>()
                : Get.put(ApiService(), permanent: true));

  final ApiService _apiService;

  Future<SponsorsResponseModel> getSponsors() async {
    final response = await _apiService.getSponsors();
    final mapBody = ApiUtils.asMap(response.body);

    if (mapBody != null) {
      return SponsorsResponseModel.fromJson(mapBody);
    }

    return SponsorsResponseModel(
      success: false,
      message: response.statusText ?? 'Failed to fetch sponsors',
    );
  }

  Future<MantrasResponseModel> getMantras() async {
    final response = await _apiService.getMantras();
    final mapBody = ApiUtils.asMap(response.body);

    if (mapBody != null) {
      return MantrasResponseModel.fromJson(mapBody);
    }

    return MantrasResponseModel(
      success: false,
      message: response.statusText ?? 'Failed to fetch mantras',
    );
  }
}
