import 'package:dharma_app/Profile/profile_model.dart';
import 'package:dharma_app/Profile/profile_repository.dart';
import 'package:dharma_app/core/constants/api_constants.dart';
import 'package:dharma_app/core/utils/toast_utils.dart';
import 'package:dharma_app/services/storage_service.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  ProfileController({ProfileRepository? repository})
    : _repository =
          repository ??
          (Get.isRegistered<ProfileRepository>()
              ? Get.find<ProfileRepository>()
              : Get.put(ProfileRepository(), permanent: true));

  final ProfileRepository _repository;
  final ImagePicker _imagePicker = ImagePicker();

  final isLoading = false.obs;
  final isUpdatingImage = false.obs;
  final profile = Rxn<ProfileResponseData>();

  ProfileUser? get user => profile.value?.user;
  ProfileSubscription? get subscription => profile.value?.subscription;
  String get fullName => user?.fullName?.trim().isNotEmpty == true
      ? user!.fullName!
      : 'User';
  String? get profileImageUrl {
    final path = profile.value?.profileImagePath;
    if (path == null || path.trim().isEmpty) return null;
    return '${ApiConstants.baseUrl}$path';
  }

  bool get hasProfileImage => profileImageUrl != null;
  bool get hasActiveSubscription {
    if (user?.isSubscriptionPaid == 1) return true;
    final status = subscription?.status?.trim().toLowerCase();
    return status == 'active';
  }

  @override
  void onInit() {
    super.onInit();
    if (StorageService.getToken()?.isNotEmpty == true) {
      loadProfile();
    }
  }

  Future<void> ensureProfileLoaded() async {
    if (StorageService.getToken()?.isNotEmpty != true) return;
    while (isLoading.value) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    if (profile.value != null) return;
    await loadProfile(silent: true);
  }

  Future<void> loadProfile({bool silent = false}) async {
    if (!silent) {
      isLoading.value = true;
    }

    try {
      final model = await _repository.getProfile();
      if (!model.success) {
        if (model.message.isNotEmpty && !silent) {
          ToastUtils.show(model.message);
        }
        return;
      }

      profile.value = model.data;
    } finally {
      if (!silent) {
        isLoading.value = false;
      }
    }
  }

  Future<void> pickAndUploadProfileImage() async {
    final currentUser = user;
    if (currentUser == null) {
      ToastUtils.show('Profile data not loaded yet');
      return;
    }

    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (pickedFile == null) {
      return;
    }

    isUpdatingImage.value = true;
    try {
      final model = await _repository.updateProfile(
        fullName: currentUser.fullName,
        currentLocation: currentUser.currentLocation,
        gender: currentUser.gender,
        birthDate: currentUser.birthDate,
        birthTime: currentUser.birthTime,
        birthPlace: currentUser.birthPlace,
        profileImagePath: pickedFile.path,
      );

      if (!model.success) {
        ToastUtils.show(
          model.message.isEmpty
              ? 'Failed to update profile image'
              : model.message,
        );
        return;
      }

      final existing = profile.value;
      profile.value = ProfileResponseData(
        user: model.data?.user ?? existing?.user,
        profileImagePath:
            model.data?.profileImagePath ?? existing?.profileImagePath,
        subscription: existing?.subscription,
      );
      ToastUtils.show(
        model.message.isEmpty
            ? 'Profile image updated successfully'
            : model.message,
      );
    } finally {
      isUpdatingImage.value = false;
    }
  }
}
