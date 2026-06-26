import 'package:dharma_app/SpiritualMedia/spiritual_media_model.dart';
import 'package:dharma_app/core/utils/api_utils.dart';
import 'package:dharma_app/services/api_service.dart';
import 'package:get/get.dart';

class SpiritualMediaRepository {
  SpiritualMediaRepository({ApiService? apiService})
    : _apiService =
          apiService ??
          (Get.isRegistered<ApiService>()
              ? Get.find<ApiService>()
              : Get.put(ApiService(), permanent: true));

  final ApiService _apiService;

  Future<SpiritualMediaListResponse> listMedia({
    int page = 1,
    int limit = 20,
    String? search,
    String? mediaType,
  }) async {
    final response = await _apiService.listSpiritualMedia(
      page: page,
      limit: limit,
      search: search,
      mediaType: mediaType,
    );
    final mapBody = ApiUtils.asMap(response.body);

    if (mapBody != null) {
      return SpiritualMediaListResponse.fromJson(
        mapBody,
        statusCode: response.statusCode,
      );
    }

    return SpiritualMediaListResponse(
      success: false,
      message: response.statusText ?? 'Failed to fetch spiritual media',
      statusCode: response.statusCode,
    );
  }

  Future<SpiritualMediaDetailResponse> getMediaDetail({
    required int mediaId,
  }) async {
    final response = await _apiService.getSpiritualMediaDetail(mediaId: mediaId);
    final mapBody = ApiUtils.asMap(response.body);

    if (mapBody != null) {
      return SpiritualMediaDetailResponse.fromJson(
        mapBody,
        statusCode: response.statusCode,
      );
    }

    return SpiritualMediaDetailResponse(
      success: false,
      message: response.statusText ?? 'Failed to fetch spiritual media detail',
      statusCode: response.statusCode,
    );
  }
}
