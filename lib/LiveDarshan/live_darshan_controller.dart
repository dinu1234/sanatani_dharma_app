import 'package:dharma_app/LiveDarshan/live_darshan_model.dart';
import 'package:dharma_app/LiveDarshan/live_darshan_repository.dart';
import 'package:dharma_app/services/storage_service.dart';
import 'package:get/get.dart';

class LiveDarshanController extends GetxController {
  LiveDarshanController({LiveDarshanRepository? repository})
      : _repository = repository ??
            (Get.isRegistered<LiveDarshanRepository>()
                ? Get.find<LiveDarshanRepository>()
                : Get.put(LiveDarshanRepository(), permanent: true));

  final LiveDarshanRepository _repository;

  final isLoading = false.obs;
  final showLiveOnly = true.obs;
  final errorMessage = ''.obs;
  final darshanItems = <LiveDarshanItem>[].obs;

  int totalCount = 0;

  Future<void> loadDarshan({bool? liveOnly}) async {
    final filterValue = liveOnly ?? showLiveOnly.value;
    showLiveOnly.value = filterValue;
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.listLiveDarshan(
        page: 1,
        limit: 20,
        isLive: filterValue ? 1 : null,
      );

      if (response.success) {
        darshanItems.assignAll(response.data?.liveDarshan ?? const []);
        totalCount = response.data?.pagination?.total ?? darshanItems.length;
      } else {
        darshanItems.clear();
        totalCount = 0;
        errorMessage.value =
            response.message.isNotEmpty
                ? response.message
                : 'Live darshan load nahi ho paaya.';
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDarshan() => loadDarshan();

  Future<void> updateFilter(bool liveOnly) => loadDarshan(liveOnly: liveOnly);

  Future<void> ensureDarshanLoaded() async {
    if (StorageService.getToken()?.isNotEmpty != true) return;
    if (darshanItems.isEmpty && !isLoading.value) {
      await loadDarshan();
    }
  }
}
