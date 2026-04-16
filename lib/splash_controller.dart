import 'package:dharma_app/Home/home_view.dart';
import 'package:dharma_app/language/language_view.dart';
import 'package:dharma_app/no_internet_view.dart';
import 'package:dharma_app/Profile/profile_setup_view.dart';
import 'package:dharma_app/services/network_service.dart';
import 'package:dharma_app/services/storage_service.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  final isRetrying = false.obs;

  @override
  void onInit() {
    super.onInit();
    navigateAfterSplash();
  }

  Future<void> navigateAfterSplash() async {
    await Future.delayed(const Duration(seconds: 3));
    await _checkInternetAndNavigate();
  }

  Future<void> retryInternetCheck() async {
    isRetrying.value = true;
    await _checkInternetAndNavigate();
    isRetrying.value = false;
  }

  Future<void> _checkInternetAndNavigate() async {
    final hasInternet = await NetworkService.hasInternet();

    if (hasInternet) {
      final token = StorageService.getToken();
      if (token != null && token.isNotEmpty) {
        if (StorageService.isProfileCompleted()) {
          Get.offAll(() => const HomeView());
          return;
        }

        Get.offAll(() => const ProfileSetupView());
        return;
      }

      Get.offAll(() => LanguageView());
      return;
    }

    Get.off(
      () => Obx(
        () => NoInternetView(
          isRetrying: isRetrying.value,
          onRetry: retryInternetCheck,
        ),
      ),
    );
  }
}
