import 'package:dharma_app/Home/home_view.dart';
import 'package:dharma_app/Profile/profile_controller.dart';
import 'package:dharma_app/Profile/profile_model.dart';
import 'package:dharma_app/Profile/profile_repository.dart';
import 'package:dharma_app/core/utils/toast_utils.dart';
import 'package:dharma_app/services/notification_service.dart';
import 'package:dharma_app/services/storage_service.dart';
import 'package:get/get.dart';

class ProfileSetupController extends GetxController {
  ProfileSetupController({ProfileRepository? repository})
    : _repository =
          repository ??
          (Get.isRegistered<ProfileRepository>()
              ? Get.find<ProfileRepository>()
              : Get.put(ProfileRepository(), permanent: true));

  final ProfileRepository _repository;

  final isFetching = false.obs;
  final isSaving = false.obs;
  final fullName = ''.obs;
  final currentLocation = ''.obs;
  final birthPlace = ''.obs;
  final gender = RxnString();
  final day = RxnString();
  final month = RxnString();
  final year = RxnString();

  bool get isLoading => isFetching.value || isSaving.value;
  String get loadingMessage =>
      isSaving.value ? 'Saving profile' : 'Loading profile';

  static const Map<String, String> _monthValueMap = {
    'January': '01',
    'February': '02',
    'March': '03',
    'April': '04',
    'May': '05',
    'June': '06',
    'July': '07',
    'August': '08',
    'September': '09',
    'October': '10',
    'November': '11',
    'December': '12',
  };

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isFetching.value = true;
    try {
      final model = await _repository.getProfile();
      if (!model.success) {
        if (model.message.isNotEmpty) {
          ToastUtils.show(model.message);
        }
        return;
      }

      _applyProfile(model.data?.user);
      await StorageService.setProfileCompleted(
        _isProfileComplete(model.data?.user),
      );
    } finally {
      isFetching.value = false;
    }
  }

  Future<void> saveProfile() async {
    if (!_validate()) return;

    isSaving.value = true;
    try {
      final model = await _repository.updateProfile(
        fullName: fullName.value,
        currentLocation: currentLocation.value,
        gender: gender.value,
        birthDate: formattedBirthDate,
        birthPlace: birthPlace.value,
      );

      if (!model.success) {
        ToastUtils.show(
          model.message.isEmpty ? 'Failed to update profile' : model.message,
        );
        return;
      }

      ToastUtils.show(
        model.message.isEmpty ? 'Profile updated successfully' : model.message,
      );
      await StorageService.setProfileCompleted(true);
      if (Get.isRegistered<ProfileController>()) {
        await Get.find<ProfileController>().loadProfile(silent: true);
      }
      await NotificationService.syncTokenIfEligible();
      Get.offAll(() => const HomeView());
    } finally {
      isSaving.value = false;
    }
  }

  void updateFullName(String value) => fullName.value = value;
  void updateCurrentLocation(String value) => currentLocation.value = value;
  void updateBirthPlace(String value) => birthPlace.value = value;
  void updateGender(String? value) => gender.value = value;
  void updateDay(String? value) => day.value = value;
  void updateMonth(String? value) => month.value = value;
  void updateYear(String? value) => year.value = value;

  bool _isProfileComplete(ProfileUser? user) =>
      user != null &&
      user.fullName?.trim().isNotEmpty == true &&
      user.currentLocation?.trim().isNotEmpty == true &&
      user.gender?.trim().isNotEmpty == true &&
      user.birthDate?.trim().isNotEmpty == true &&
      user.birthPlace?.trim().isNotEmpty == true;

  String get formattedBirthDate {
    final monthNumber = _monthValueMap[month.value] ?? '01';
    final dayNumber =
        int.tryParse(day.value ?? '')?.toString().padLeft(2, '0') ?? '01';
    return '${year.value}-$monthNumber-$dayNumber';
  }

  String? _monthNameFromValue(String monthValue) {
    for (final entry in _monthValueMap.entries) {
      if (entry.value == monthValue) {
        return entry.key;
      }
    }
    return null;
  }

  void _applyProfile(ProfileUser? user) {
    if (user == null) return;

    fullName.value = user.fullName ?? '';
    currentLocation.value = user.currentLocation ?? '';
    birthPlace.value = user.birthPlace ?? '';
    gender.value = user.gender;

    final birthDate = user.birthDate;
    if (birthDate == null || birthDate.isEmpty) return;

    final parts = birthDate.split('-');
    if (parts.length != 3) return;

    year.value = parts[0];
    day.value = int.tryParse(parts[2])?.toString() ?? parts[2];
    month.value = _monthNameFromValue(parts[1]);
  }

  bool _validate() {
    if (fullName.value.trim().isEmpty ||
        currentLocation.value.trim().isEmpty ||
        birthPlace.value.trim().isEmpty ||
        gender.value == null ||
        day.value == null ||
        month.value == null ||
        year.value == null) {
      ToastUtils.show('Please fill all fields before continuing');
      return false;
    }

    return true;
  }
}
