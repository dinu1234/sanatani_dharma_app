import 'package:dharma_app/services/storage_service.dart';
import 'package:dharma_app/splash_view.dart';
import 'package:dharma_app/language/translations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init(); // ✅ storage init
  runApp(DharmaApp());
}

class DharmaApp extends StatelessWidget {
  const DharmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Dharma App",

      /// 🌐 MULTI LANGUAGE SETUP
      translations: AppTranslations(),
      locale: _getSavedLocale(),          // 👈 saved language
      fallbackLocale: const Locale('en'),

      /// 🎨 OPTIONAL (theme add kar sakte ho)
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
      ),

      /// 🚀 START SCREEN
      home: SplashView(),
    );
  }

  /// 📦 STORAGE SE LANGUAGE LOAD
  Locale _getSavedLocale() {
    final langCode = StorageService.getLanguage(); // 👈 tumhe banana hoga
    return Locale(langCode ?? 'en');
  }
}