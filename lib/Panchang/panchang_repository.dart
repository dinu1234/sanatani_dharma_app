import 'package:dharma_app/Panchang/panchang_model.dart';
import 'package:dharma_app/core/utils/api_utils.dart';
import 'package:dharma_app/services/api_service.dart';
import 'package:get/get.dart';

class PanchangRepository {
  PanchangRepository({ApiService? apiService})
      : _apiService = apiService ??
            (Get.isRegistered<ApiService>()
                ? Get.find<ApiService>()
                : Get.put(ApiService(), permanent: true));

  final ApiService _apiService;

  Future<PanchangResponseModel> getTodayPanchang({
    required double lat,
    required double lng,
    String? date,
  }) async {
    final response = await _apiService.getTodayPanchang(
      lat: lat,
      lng: lng,
      date: date,
    );
    final mapBody = ApiUtils.asMap(response.body);

    if (mapBody != null) {
      return PanchangResponseModel.fromJson(mapBody);
    }

    return PanchangResponseModel(
      success: false,
      message: response.statusText ?? 'Failed to fetch Panchang',
    );
  }
}
