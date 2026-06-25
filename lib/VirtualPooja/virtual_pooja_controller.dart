import 'package:dharma_app/Profile/profile_controller.dart';
import 'package:dharma_app/VirtualPooja/virtual_pooja_model.dart';
import 'package:dharma_app/VirtualPooja/virtual_pooja_repository.dart';
import 'package:dharma_app/core/utils/toast_utils.dart';
import 'package:get/get.dart';

class VirtualPoojaController extends GetxController {
  VirtualPoojaController({VirtualPoojaRepository? repository})
    : _repository =
          repository ??
          (Get.isRegistered<VirtualPoojaRepository>()
              ? Get.find<VirtualPoojaRepository>()
              : Get.put(VirtualPoojaRepository(), permanent: true));

  final VirtualPoojaRepository _repository;
  final ProfileController _profileController =
      Get.isRegistered<ProfileController>()
      ? Get.find<ProfileController>()
      : Get.put(ProfileController(), permanent: true);

  final deities = <VirtualPoojaDeity>[].obs;
  final selectedDeityId = 0.obs;
  final isLoading = false.obs;
  final loadErrorMessage = ''.obs;
  final selectedDeity = Rxn<VirtualPoojaDeity>();
  final activeOffering = ''.obs;
  final diyaProgress = 0.obs;
  final diyaHoldProgress = 0.0.obs;
  final ghantaRings = 0.obs;
  final petalCount = 0.obs;
  final petalEvent = 0.obs;
  final isNavaGrahaStarted = false.obs;
  final navaGrahaProgress = 1.obs;

  @override
  void onInit() {
    super.onInit();
    loadActiveDeities();
  }

  Future<void> loadActiveDeities() async {
    loadErrorMessage.value = '';
    isLoading.value = true;
    final response = await _repository.listActiveDeities();
    isLoading.value = false;

    if (!response.success) {
      final message = response.message.isNotEmpty
          ? response.message
          : 'Unable to fetch deities.';
      loadErrorMessage.value = message;
      if (deities.isEmpty) {
        ToastUtils.show(message);
      }
      return;
    }

    final sortedDeities = [...response.deities]
      ..sort((a, b) {
        if (a.isFree == b.isFree) return a.id.compareTo(b.id);
        return a.isFree ? -1 : 1;
      });

    deities.assignAll(sortedDeities);
    for (final deity in sortedDeities) {
      if (deity.isFree) {
        selectDeity(deity);
        return;
      }
    }
  }

  bool get hasLoadError => loadErrorMessage.value.trim().isNotEmpty;

  void selectDeity(VirtualPoojaDeity deity) {
    if (isDeityLocked(deity)) {
      ToastUtils.show('Active subscription is required to access this deity.');
      return;
    }

    selectedDeityId.value = deity.id;
    selectedDeity.value = deity;
    activeOffering.value = '';
    diyaProgress.value = 0;
    diyaHoldProgress.value = 0;
    ghantaRings.value = 0;
    petalCount.value = 0;
    petalEvent.value = 0;
    isNavaGrahaStarted.value = false;
    navaGrahaProgress.value = 1;
  }

  bool isDeityLocked(VirtualPoojaDeity deity) {
    return deity.isPaid && !_profileController.hasActiveSubscription;
  }

  void offer(String offering) {
    activeOffering.value = offering;
    ToastUtils.show('$offering offered');
  }

  void ringGhanta() {
    if (petalCount.value < 6) return;
    if (ghantaRings.value >= 3) return;
    ghantaRings.value += 1;
    activeOffering.value = 'Ghanta Nadam';
  }

  void lightDiya() {
    diyaProgress.value = 3;
    diyaHoldProgress.value = 1;
    activeOffering.value = 'Diya Prajwalit';
  }

  void setDiyaHoldProgress(double value) {
    if (diyaProgress.value >= 3) {
      diyaHoldProgress.value = 1;
      return;
    }
    diyaHoldProgress.value = value.clamp(0.0, 1.0);
  }

  void offerPetal() {
    if (diyaProgress.value < 3 || petalCount.value >= 6) return;
    petalCount.value += 1;
    petalEvent.value += 1;
    activeOffering.value = 'Pushpa Arpan';
  }

  void resetCurrentPooja() {
    final deity = selectedDeity.value;
    if (deity == null) return;
    activeOffering.value = '';
    diyaProgress.value = 0;
    diyaHoldProgress.value = 0;
    ghantaRings.value = 0;
    petalCount.value = 0;
    petalEvent.value = 0;
    isNavaGrahaStarted.value = false;
    navaGrahaProgress.value = 1;
  }

  void resetNavaGraha() {
    navaGrahaProgress.value = 1;
  }

  void advanceNavaGraha() {
    if (navaGrahaProgress.value >= 9) return;
    navaGrahaProgress.value += 1;
  }

  void startNavaGraha() {
    if (ghantaRings.value < 3) return;
    isNavaGrahaStarted.value = true;
    if (navaGrahaProgress.value < 1) {
      navaGrahaProgress.value = 1;
    }
  }
}
