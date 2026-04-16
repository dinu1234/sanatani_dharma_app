import 'package:dharma_app/GanaMatch/gana_match_model.dart';
import 'package:dharma_app/core/utils/api_utils.dart';
import 'package:dharma_app/services/api_service.dart';
import 'package:get/get.dart';

class GanaMatchRepository {
  GanaMatchRepository({ApiService? apiService})
      : _apiService = apiService ??
            (Get.isRegistered<ApiService>()
                ? Get.find<ApiService>()
                : Get.put(ApiService(), permanent: true));

  final ApiService _apiService;

  Future<KundliMatchResponseModel> getDetailedKundliMatching({
    String? girlName,
    required double girlLat,
    required double girlLng,
    required String girlDob,
    String? boyName,
    required double boyLat,
    required double boyLng,
    required String boyDob,
  }) async {
    final response = await _apiService.getDetailedKundliMatching(
      girlName: girlName,
      girlLat: girlLat,
      girlLng: girlLng,
      girlDob: girlDob,
      boyName: boyName,
      boyLat: boyLat,
      boyLng: boyLng,
      boyDob: boyDob,
    );
    final mapBody = ApiUtils.asMap(response.body);
    if (mapBody != null) {
      return KundliMatchResponseModel.fromJson(mapBody);
    }

    return KundliMatchResponseModel(
      success: false,
      message: response.statusText ?? 'Failed to fetch kundli matching',
    );
  }
}
