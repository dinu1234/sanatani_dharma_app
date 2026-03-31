import 'package:dharma_app/language/translations.dart';
import 'package:dharma_app/services/storage_service.dart';
import 'package:dharma_app/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFFD6EAF8),
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(const DharmaApp());
}

class DharmaApp extends StatelessWidget {
  const DharmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Dharma App",
      translations: AppTranslations(),
      locale: _getSavedLocale(),
      fallbackLocale: const Locale('en'),
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color(0xFFD6EAF8),
      ),
      home: SplashView(),
    );
  }

  Locale _getSavedLocale() {
    final langCode = StorageService.getLanguage();
    return Locale(langCode ?? 'en');
  }
}
