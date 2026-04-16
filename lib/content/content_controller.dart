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
    isLoadingSponsors.value = true;
    try {
      final model = await _repository.getSponsors();
      if (model.success) {
        sponsors.assignAll(model.data?.sponsors ?? const []);
      }
    } finally {
      isLoadingSponsors.value = false;
    }
  }

  Future<void> loadMantras() async {
    isLoadingMantras.value = true;
    try {
      final model = await _repository.getMantras();
      if (model.success) {
        mantras.assignAll(model.data?.mantras ?? const []);
      }
    } finally {
      isLoadingMantras.value = false;
    }
  }

  Future<void> ensureContentLoaded() async {
    if (StorageService.getToken()?.isNotEmpty != true) return;
    if (sponsors.isEmpty && !isLoadingSponsors.value) {
      await loadSponsors();
    }
    if (mantras.isEmpty && !isLoadingMantras.value) {
      await loadMantras();
    }
  }
}
