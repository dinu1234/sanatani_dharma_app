import 'package:dharma_app/Home/home_view.dart';
import 'package:dharma_app/Login/LoginView.dart';
import 'package:dharma_app/language/language_view.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    navigateToLogin();
  }

  void navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 3));
    Get.off(() => HomeView());
  }
}
