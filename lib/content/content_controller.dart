import 'package:dharma_app/content/content_model.dart';
import 'package:dharma_app/content/content_repository.dart';
import 'package:dharma_app/services/storage_service.dart';
import 'package:get/get.dart';

class ContentController extends GetxController {
  ContentController({ContentRepository? repository})
      : _repository = repository ??
            (Get.isRegistered<ContentRepository>()
                ? Get.find<ContentRepository>()
                : Get.put(ContentRepository(), permanent: true));

  final ContentRepository _repository;
  Future<void>? _sponsorsLoadFuture;
  Future<void>? _mantrasLoadFuture;

  final isLoadingSponsors = false.obs;
  final isLoadingMantras = false.obs;
  final sponsors = <SponsorItem>[].obs;
  final mantras = <MantraItem>[].obs;

  SponsorItem? get featuredSponsor =>
      sponsors.isNotEmpty ? sponsors.first : null;
  MantraItem? get featuredMantra => mantras.isNotEmpty ? mantras.first : null;

  @override
  void onInit() {
    super.onInit();
    if (StorageService.getToken()?.isNotEmpty == true) {
      loadSponsors();
      loadMantras();
    }
  }

  Future<void> loadSponsors() async {
    if (_sponsorsLoadFuture != null) {
      await _sponsorsLoadFuture;
      return;
    }

    final future = _loadSponsorsInternal();
    _sponsorsLoadFuture = future;
    await future;
  }

  Future<void> _loadSponsorsInternal() async {
    isLoadingSponsors.value = true;
    try {
      final model = await _repository.getSponsors();
      if (model.success) {
        sponsors.assignAll(model.data?.sponsors ?? const []);
      }
    } finally {
      isLoadingSponsors.value = false;
      _sponsorsLoadFuture = null;
    }
  }

  Future<void> loadMantras() async {
    if (_mantrasLoadFuture != null) {
      await _mantrasLoadFuture;
      return;
    }

    final future = _loadMantrasInternal();
    _mantrasLoadFuture = future;
    await future;
  }

  Future<void> _loadMantrasInternal() async {
    isLoadingMantras.value = true;
    try {
      final model = await _repository.getMantras();
      if (model.success) {
        mantras.assignAll(model.data?.mantras ?? const []);
      }
    } finally {
      isLoadingMantras.value = false;
      _mantrasLoadFuture = null;
    }
  }

  Future<void> ensureContentLoaded() async {
    if (StorageService.getToken()?.isNotEmpty != true) return;
    if (sponsors.isEmpty) {
      await loadSponsors();
    }
    if (mantras.isEmpty) {
      await loadMantras();
    }
  }
}
