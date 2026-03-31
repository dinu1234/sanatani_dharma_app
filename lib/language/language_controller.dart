import 'dart:ui';
import 'package:get/get.dart';
import '../../services/storage_service.dart';

class LanguageController extends GetxController {
  final RxString selectedLang = "en".obs;

  @override
  void onInit() {
    super.onInit();

    /// सिर्फ value set करो
    selectedLang.value = StorageService.getLanguage();
  }

  void changeLanguage(String code) {
    if (selectedLang.value == code) return;

    selectedLang.value = code;
    StorageService.setLanguage(code);

    /// ✅ safe call
    Get.updateLocale(Locale(code));
  }
}