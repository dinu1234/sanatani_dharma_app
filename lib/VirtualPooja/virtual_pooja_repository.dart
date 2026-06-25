import 'package:dharma_app/VirtualPooja/virtual_pooja_model.dart';
import 'package:dharma_app/core/utils/api_utils.dart';
import 'package:dharma_app/services/api_service.dart';
import 'package:get/get.dart';

class VirtualPoojaRepository {
  VirtualPoojaRepository({ApiService? apiService})
    : _apiService =
          apiService ??
          (Get.isRegistered<ApiService>()
              ? Get.find<ApiService>()
              : Get.put(ApiService(), permanent: true));

  final ApiService _apiService;

  Future<VirtualPoojaDeityListResponse> listActiveDeities() async {
    final response = await _apiService.listDeities();
    final mapBody = ApiUtils.asMap(response.body);

    if (mapBody != null) {
      return VirtualPoojaDeityListResponse.fromJson(mapBody);
    }

    final statusCode = response.statusCode ?? 0;
    final statusText = response.statusText?.trim() ?? '';
    String message = statusText.isNotEmpty
        ? statusText
        : 'Unable to fetch deities.';

    if (statusCode == 408) {
      message = 'Request timed out. Please tap Retry.';
    } else if (statusCode == 0) {
      message = 'No internet connection. Please check your network and retry.';
    }

    return VirtualPoojaDeityListResponse(
      success: false,
      message: message,
    );
  }
}
