import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dharma_app/services/api_service.dart';
import 'package:dharma_app/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'dharma_high_importance_channel',
    'Dharma Notifications',
    description: 'Important notifications',
    importance: Importance.high,
  );

  static bool _isInitialized = false;
  static final ApiService _apiService =
      Get.isRegistered<ApiService>()
          ? Get.find<ApiService>()
          : Get.put(ApiService(), permanent: true);

  static bool get isSupportedPlatform =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static void _logNotificationTap({
    required String source,
    String? title,
    String? body,
    Map<String, dynamic>? data,
  }) {
    debugPrint(
      'Notification tapped from $source | title: $title | body: $body | data: $data',
    );
  }

  static Future<void> initialize() async {
    if (_isInitialized || !isSupportedPlatform) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const settings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('Local notification tapped | payload: ${response.payload}');
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    final token = await messaging.getToken();
    debugPrint('FCM Token: $token');
    if (token != null) {
      await syncTokenWithServer(token);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      debugPrint('FCM Token refreshed: $token');
      await syncTokenWithServer(token);
    });

    FirebaseMessaging.onMessage.listen(showRemoteNotification);

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _logNotificationTap(
        source: 'background',
        title: message.notification?.title,
        body: message.notification?.body,
        data: message.data,
      );
    });

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _logNotificationTap(
        source: 'terminated',
        title: initialMessage.notification?.title,
        body: initialMessage.notification?.body,
        data: initialMessage.data,
      );
    }

    _isInitialized = true;
  }

  static Future<void> showRemoteNotification(RemoteMessage message) async {
    if (!isSupportedPlatform) return;

    final notification = message.notification;

    if (notification == null && message.data.isEmpty) return;

    await _localNotifications.show(
      id: notification.hashCode,
      title:
          notification?.title ??
          message.data['title']?.toString() ??
          'Notification',
      body:
          notification?.body ?? message.data['body']?.toString() ?? '',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: message.data.toString(),
    );
  }

  static Future<String?> currentToken() async {
    if (!isSupportedPlatform) return null;
    return FirebaseMessaging.instance.getToken();
  }

  static Future<void> syncTokenIfEligible() async {
    await syncTokenWithServer(await currentToken());
  }

  static Future<void> syncTokenWithServer(String? token) async {
    if (!isSupportedPlatform || token == null || token.isEmpty) return;

    final authToken = StorageService.getToken();
    if (authToken == null || authToken.isEmpty) {
      debugPrint('Skipping Firebase token sync: user not logged in');
      return;
    }

    if (!StorageService.isProfileCompleted()) {
      debugPrint('Skipping Firebase token sync: profile incomplete');
      return;
    }

    if (StorageService.getLastSyncedFirebaseToken() == token) {
      debugPrint('Skipping Firebase token sync: token already synced');
      return;
    }

    final platform = Platform.isAndroid
        ? 'android'
        : Platform.isIOS
            ? 'ios'
            : 'web';

    final response = await _apiService.updateFirebaseToken(
      deviceToken: token,
      devicePlatform: platform,
    );

    if (response.isOk) {
      await StorageService.setLastSyncedFirebaseToken(token);
    }

    debugPrint(
      'Update Firebase token response: ${response.statusCode} ${response.body}',
    );
  }
}
