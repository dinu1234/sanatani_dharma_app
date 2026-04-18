import 'package:dharma_app/LiveDarshan/live_darshan_model.dart';
import 'package:dharma_app/core/utils/api_utils.dart';
import 'package:dharma_app/services/api_service.dart';
import 'package:get/get.dart';

class LiveDarshanRepository {
  LiveDarshanRepository({ApiService? apiService})
      : _apiService = apiService ??
            (Get.isRegistered<ApiService>()
                ? Get.find<ApiService>()
                : Get.put(ApiService(), permanent: true));

  final ApiService _apiService;

  Future<LiveDarshanResponseModel> listLiveDarshan({
    int page = 1,
    int limit = 20,
    int? isLive,
  }) async {
    final response = await _apiService.listLiveDarshan(
      page: page,
      limit: limit,
      isLive: isLive,
    );
    final mapBody = ApiUtils.asMap(response.body);

    if (mapBody != null) {
      return LiveDarshanResponseModel.fromJson(mapBody);
    }

    return LiveDarshanResponseModel(
      success: false,
      message: response.statusText ?? 'Failed to fetch live darshan',
    );
  }
}
