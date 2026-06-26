import 'package:dharma_app/SpiritualMedia/spiritual_media_model.dart';
import 'package:dharma_app/SpiritualMedia/spiritual_media_repository.dart';
import 'package:dharma_app/core/utils/toast_utils.dart';
import 'package:dharma_app/services/storage_service.dart';
import 'package:get/get.dart';

class SpiritualMediaController extends GetxController {
  SpiritualMediaController({SpiritualMediaRepository? repository})
    : _repository =
          repository ??
          (Get.isRegistered<SpiritualMediaRepository>()
              ? Get.find<SpiritualMediaRepository>()
              : Get.put(SpiritualMediaRepository(), permanent: true));

  final SpiritualMediaRepository _repository;

  final isLoading = false.obs;
  final isDetailLoading = false.obs;
  final selectedFilter = ''.obs;
  final searchQuery = ''.obs;
  final errorMessage = ''.obs;
  final isSubscriptionRequiredForList = false.obs;
  final mediaItems = <SpiritualMediaItem>[].obs;

  int totalCount = 0;

  Future<void> loadMedia({
    String? mediaType,
    String? search,
    bool showLoader = true,
  }) async {
    if (StorageService.getToken()?.isNotEmpty != true) return;

    final nextFilter = mediaType ?? selectedFilter.value;
    final nextSearch = search ?? searchQuery.value;
    selectedFilter.value = nextFilter;
    searchQuery.value = nextSearch;
    errorMessage.value = '';
    isSubscriptionRequiredForList.value = false;
    if (showLoader) {
      isLoading.value = true;
    }

    try {
      final response = await _repository.listMedia(
        page: 1,
        limit: 40,
        search: nextSearch,
        mediaType: nextFilter.isEmpty ? null : nextFilter,
      );

      if (response.success) {
        mediaItems.assignAll(response.data?.media ?? const []);
        totalCount = response.data?.pagination?.total ?? mediaItems.length;
        return;
      }

      mediaItems.clear();
      totalCount = 0;
      errorMessage.value = response.message;
      if (response.statusCode == 403) {
        isSubscriptionRequiredForList.value = true;
      }
    } finally {
      if (showLoader) {
        isLoading.value = false;
      }
    }
  }

  Future<void> ensureMediaLoaded() async {
    if (mediaItems.isEmpty && !isLoading.value) {
      await loadMedia();
    }
  }

  Future<void> applyFilter(String mediaType) async {
    if (selectedFilter.value == mediaType && mediaItems.isNotEmpty) return;
    await loadMedia(mediaType: mediaType);
  }

  Future<void> applySearch(String query) async {
    await loadMedia(search: query.trim());
  }

  Future<SpiritualMediaDetailItem?> fetchDetail(int mediaId) async {
    final detailResponse = await fetchDetailResponse(mediaId);
    return detailResponse?.data?.media;
  }

  Future<SpiritualMediaDetailResponse?> fetchDetailResponse(int mediaId) async {
    if (isDetailLoading.value || mediaId <= 0) return null;
    isDetailLoading.value = true;
    try {
      final response = await _repository.getMediaDetail(mediaId: mediaId);
      if (!response.success && response.message.trim().isNotEmpty) {
        ToastUtils.show(response.message.trim());
      }
      return response;
    } finally {
      isDetailLoading.value = false;
    }
  }
}
