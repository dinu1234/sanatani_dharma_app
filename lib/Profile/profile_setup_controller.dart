import 'package:dharma_app/Home/home_view.dart';
import 'package:dharma_app/Profile/profile_controller.dart';
import 'package:dharma_app/Profile/profile_model.dart';
import 'package:dharma_app/Profile/profile_repository.dart';
import 'package:dharma_app/core/utils/toast_utils.dart';
import 'package:dharma_app/services/api_service.dart';
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
  final birthTime = ''.obs;
  final gender = RxnString();
  final day = RxnString();
  final month = RxnString();
  final year = RxnString();
  final currentLocationSuggestions = <LocationSuggestion>[].obs;
  final birthPlaceSuggestions = <LocationSuggestion>[].obs;
  final selectedCurrentLocation = Rxn<LocationSuggestion>();
  final selectedBirthPlace = Rxn<LocationSuggestion>();
  final isSearchingCurrentLocation = false.obs;
  final isSearchingBirthPlace = false.obs;
  final List<Worker> _workers = [];
  int _currentLocationSearchId = 0;
  int _birthPlaceSearchId = 0;

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
    _workers.addAll([
      debounce<String>(
        currentLocation,
        (value) => _searchLocation(
          query: value,
          target: currentLocationSuggestions,
          loading: isSearchingCurrentLocation,
          isCurrentLocation: true,
        ),
        time: const Duration(milliseconds: 300),
      ),
      debounce<String>(
        birthPlace,
        (value) => _searchLocation(
          query: value,
          target: birthPlaceSuggestions,
          loading: isSearchingBirthPlace,
          isCurrentLocation: false,
        ),
        time: const Duration(milliseconds: 300),
      ),
    ]);
    loadProfile();
  }

  @override
  void onClose() {
    for (final worker in _workers) {
      worker.dispose();
    }
    super.onClose();
  }

  Future<void> loadProfile() async {
    isFetching.value = true;
    try {
      final model = await _repository.getProfile();
      if (!model.success) {
        if (model.message.isNotEmpty && !ApiService.isAuthFailureHandled) {
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
        birthTime: birthTime.value,
        birthPlace: birthPlace.value,
        birthLat: selectedBirthPlace.value?.lat,
        birthLng: selectedBirthPlace.value?.lng,
        birthTimezone: selectedBirthPlace.value?.timezone,
      );

      if (!model.success) {
        if (!ApiService.isAuthFailureHandled) {
          ToastUtils.show(
            model.message.isEmpty ? 'Failed to update profile' : model.message,
          );
        }
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
  void updateCurrentLocation(String value) {
    currentLocation.value = value;
    if (selectedCurrentLocation.value?.label != value.trim()) {
      selectedCurrentLocation.value = null;
    }
  }

  void updateBirthPlace(String value) {
    birthPlace.value = value;
    if (selectedBirthPlace.value?.label != value.trim()) {
      selectedBirthPlace.value = null;
    }
  }

  void selectCurrentLocation(LocationSuggestion suggestion) {
    selectedCurrentLocation.value = suggestion;
    currentLocation.value = suggestion.label;
    currentLocationSuggestions.clear();
  }

  void selectBirthPlace(LocationSuggestion suggestion) {
    selectedBirthPlace.value = suggestion;
    birthPlace.value = suggestion.label;
    birthPlaceSuggestions.clear();
  }

  void clearCurrentLocation() {
    _currentLocationSearchId++;
    selectedCurrentLocation.value = null;
    currentLocation.value = '';
    currentLocationSuggestions.clear();
    isSearchingCurrentLocation.value = false;
  }

  void clearBirthPlace() {
    _birthPlaceSearchId++;
    selectedBirthPlace.value = null;
    birthPlace.value = '';
    birthPlaceSuggestions.clear();
    isSearchingBirthPlace.value = false;
  }

  void updateBirthTime(String value) => birthTime.value = value;
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
      user.birthTime?.trim().isNotEmpty == true &&
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
    final existingCurrentLocation = user.currentLocation ?? '';
    final existingBirthPlace = user.birthPlace ?? '';
    selectedCurrentLocation.value = existingCurrentLocation.trim().isEmpty
        ? null
        : LocationSuggestion(placeName: existingCurrentLocation);
    selectedBirthPlace.value = existingBirthPlace.trim().isEmpty
        ? null
        : LocationSuggestion(placeName: existingBirthPlace);
    currentLocation.value = existingCurrentLocation;
    birthPlace.value = existingBirthPlace;
    birthTime.value = user.birthTime ?? '';
    gender.value = _normalizeGender(user.gender);

    final birthDate = user.birthDate;
    if (birthDate == null || birthDate.isEmpty) return;

    final parts = birthDate.split('-');
    if (parts.length != 3) return;

    year.value = parts[0];
    day.value = int.tryParse(parts[2])?.toString() ?? parts[2];
    month.value = _monthNameFromValue(parts[1]);
  }

  Future<void> _searchLocation({
    required String query,
    required RxList<LocationSuggestion> target,
    required RxBool loading,
    required bool isCurrentLocation,
  }) async {
    final trimmed = query.trim();
    final selected = isCurrentLocation
        ? selectedCurrentLocation.value
        : selectedBirthPlace.value;

    if (selected?.label == trimmed || trimmed.length < 2) {
      if (isCurrentLocation) {
        _currentLocationSearchId++;
      } else {
        _birthPlaceSearchId++;
      }
      target.clear();
      loading.value = false;
      return;
    }

    final searchId = isCurrentLocation
        ? ++_currentLocationSearchId
        : ++_birthPlaceSearchId;
    loading.value = true;
    try {
      final model = await _repository.searchPlaces(query: trimmed, limit: 5);
      final isLatest = isCurrentLocation
          ? searchId == _currentLocationSearchId
          : searchId == _birthPlaceSearchId;
      if (!isLatest) return;

      if (model.success) {
        target.assignAll(model.data?.suggestions ?? const []);
      } else {
        target.clear();
      }
    } finally {
      final isLatest = isCurrentLocation
          ? searchId == _currentLocationSearchId
          : searchId == _birthPlaceSearchId;
      if (isLatest) {
        loading.value = false;
      }
    }
  }

  String? _normalizeGender(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == 'male' ||
        normalized == 'female' ||
        normalized == 'other') {
      return normalized;
    }
    return null;
  }

  bool _validate() {
    if (fullName.value.trim().isEmpty ||
        currentLocation.value.trim().isEmpty ||
        birthTime.value.trim().isEmpty ||
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
