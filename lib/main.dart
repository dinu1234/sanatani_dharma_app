import 'package:dharma_app/core/bindings/app_bindings.dart';
import 'package:dharma_app/firebase_options.dart';
import 'package:dharma_app/services/notification_service.dart';
import 'package:dharma_app/language/translations.dart';
import 'package:dharma_app/services/storage_service.dart';
import 'package:dharma_app/splash_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!NotificationService.isSupportedPlatform) return;

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint(
    'Background message received | title: ${message.notification?.title} | body: ${message.notification?.body} | data: ${message.data}',
  );
  await NotificationService.showRemoteNotification(message);
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  AppBindings.init();

  if (NotificationService.isSupportedPlatform) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await NotificationService.initialize();
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFFD6EAF8),
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.white,
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
