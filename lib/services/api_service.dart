import 'dart:async';
import 'dart:io';

import 'package:dharma_app/Login/LoginView.dart';
import 'package:dharma_app/core/constants/api_constants.dart';
import 'package:dharma_app/core/utils/api_utils.dart';
import 'package:dharma_app/core/utils/toast_utils.dart';
import 'package:dharma_app/services/network_service.dart';
import 'package:dharma_app/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ApiService extends GetConnect {
  static bool _isAuthFailureHandled = false;

  static void resetAuthFailureGuard() {
    _isAuthFailureHandled = false;
  }

  static bool get isAuthFailureHandled => _isAuthFailureHandled;

  String _requestLanguageCode() {
    final code = StorageService.getLanguage().trim();
    return code.isEmpty ? 'en' : code;
  }

  void _logRequest({
    required String method,
    required String endpoint,
    required dynamic body,
    required String contentType,
    required bool requireAuth,
  }) {
    debugPrint('API REQUEST [$method] ${ApiConstants.baseUrl}$endpoint');
    debugPrint('API REQUEST AUTH REQUIRED: $requireAuth');
    debugPrint('API REQUEST CONTENT TYPE: $contentType');
    debugPrint('API REQUEST BODY: $body');
  }

  void _logResponse({
    required String method,
    required String endpoint,
    required Response<dynamic> response,
  }) {
    debugPrint('API RESPONSE [$method] ${ApiConstants.baseUrl}$endpoint');
    debugPrint('API RESPONSE STATUS: ${response.statusCode}');
    debugPrint('API RESPONSE STATUS TEXT: ${response.statusText}');
    debugPrint('API RESPONSE BODY: ${response.body}');
  }

  void _logError({
    required String method,
    required String endpoint,
    required Object error,
    StackTrace? stackTrace,
  }) {
    debugPrint('API ERROR [$method] ${ApiConstants.baseUrl}$endpoint');
    debugPrint('API ERROR DETAILS: $error');
    if (stackTrace != null && kDebugMode) {
      debugPrint('API ERROR STACKTRACE: $stackTrace');
    }
  }

  @override
  void onInit() {
    httpClient.baseUrl = ApiConstants.baseUrl;
    httpClient.timeout = const Duration(seconds: 30);

    httpClient.addRequestModifier<dynamic>((request) {
      final skipAuth = request.headers['X-Skip-Auth'] == 'true';
      request.headers.remove('X-Skip-Auth');

      final token = StorageService.getToken();
      if (!skipAuth && token != null && token.isNotEmpty) {
        request.headers['Authorization'] = "Bearer $token";
      }

      request.headers['Accept'] = 'application/json';
      return request;
    });

    super.onInit();
  }

  Future<Response<dynamic>> postRequest(
    String endpoint,
    dynamic body, {
    String contentType = 'application/json',
    bool requireAuth = false,
    bool includeAuthHeader = true,
    bool showErrorToast = true,
    Duration? timeout,
    int retryCount = 0,
    Duration retryDelay = const Duration(milliseconds: 900),
  }) async {
    _logRequest(
      method: 'POST',
      endpoint: endpoint,
      body: body,
      contentType: contentType,
      requireAuth: requireAuth,
    );

    final hasInternet = await NetworkService.hasInternet();
    if (!hasInternet) {
      _logError(
        method: 'POST',
        endpoint: endpoint,
        error: 'No internet connection',
      );
      if (showErrorToast) {
        ToastUtils.show("No internet connection");
      }
      return Response(statusCode: 0, statusText: "No internet connection");
    }

    if (requireAuth) {
      final token = StorageService.getToken();
      if (token == null || token.isEmpty) {
        _logError(
          method: 'POST',
          endpoint: endpoint,
          error: 'Unauthorized: token missing',
        );
        _handleAuthFailure("Please login again", showToast: showErrorToast);
        return Response(statusCode: 401, statusText: "Unauthorized");
      }
    }

    final maxAttempts = retryCount + 1;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final headers = <String, String>{};
        if (!includeAuthHeader) {
          headers['X-Skip-Auth'] = 'true';
        }

        final response = await post(
          endpoint,
          body,
          contentType: contentType,
          headers: headers,
        ).timeout(timeout ?? httpClient.timeout);
        _logResponse(method: 'POST', endpoint: endpoint, response: response);

        if (_isTimeoutResponse(response)) {
          if (attempt < maxAttempts) {
            await Future.delayed(retryDelay);
            continue;
          }
          if (showErrorToast) {
            ToastUtils.show("Request timed out. Please try again.");
          }
          return Response(
            statusCode: 408,
            statusText: "Request timeout",
            body: response.body,
          );
        }

        if (requireAuth &&
            (response.statusCode == 400 ||
                response.statusCode == 401 ||
                response.statusCode == 402)) {
          _handleAuthFailure(
            ApiUtils.message(response.body) ??
                "Session expired. Please login again.",
            showToast: true,
          );
          return response;
        }

        if (showErrorToast &&
            response.statusCode != null &&
            response.statusCode! >= 400 &&
            response.statusCode != 400 &&
            response.statusCode != 401 &&
            response.statusCode != 402) {
          ToastUtils.show(
            ApiUtils.message(response.body) ?? "Something went wrong",
          );
        }

        return response;
      } on TimeoutException catch (e, stackTrace) {
        _logError(
          method: 'POST',
          endpoint: endpoint,
          error: e,
          stackTrace: stackTrace,
        );
        if (attempt < maxAttempts) {
          await Future.delayed(retryDelay);
          continue;
        }
        if (showErrorToast) {
          ToastUtils.show("Request timed out. Please try again.");
        }
        return Response(statusCode: 408, statusText: "Request timeout");
      } on SocketException catch (e, stackTrace) {
        _logError(
          method: 'POST',
          endpoint: endpoint,
          error: e,
          stackTrace: stackTrace,
        );
        if (attempt < maxAttempts) {
          await Future.delayed(retryDelay);
          continue;
        }
        if (showErrorToast) {
          ToastUtils.show("No internet connection");
        }
        return Response(statusCode: 0, statusText: "No internet connection");
      } catch (e, stackTrace) {
        _logError(
          method: 'POST',
          endpoint: endpoint,
          error: e,
          stackTrace: stackTrace,
        );
        if (showErrorToast) {
          ToastUtils.show("Something went wrong");
        }
        return Response(statusCode: 500, statusText: e.toString());
      }
    }

    return Response(statusCode: 500, statusText: "Something went wrong");
  }

  Future<Response<dynamic>> sendOtp({
    required String countryCode,
    required String mobile,
  }) {
    return postRequest(
      ApiConstants.sendOtp,
      {'country_code': countryCode, 'mobile': mobile},
      contentType: 'application/x-www-form-urlencoded',
      showErrorToast: false,
    );
  }

  Future<Response<dynamic>> resendOtp({
    required String countryCode,
    required String mobile,
  }) {
    return postRequest(
      'resend_otp.php',
      {'country_code': countryCode, 'mobile': mobile},
      contentType: 'application/x-www-form-urlencoded',
      showErrorToast: false,
    );
  }

  Future<Response<dynamic>> verifyOtp({
    required String countryCode,
    required String mobile,
    required String otp,
  }) {
    return postRequest(
      ApiConstants.verifyOtp,
      {'country_code': countryCode, 'mobile': mobile, 'otp': otp},
      contentType: 'application/x-www-form-urlencoded',
      showErrorToast: false,
    );
  }

  Future<Response<dynamic>> googleLogin({
    required String googleId,
    required String name,
    required String email,
    String? profileImage,
  }) {
    return postRequest(
      ApiConstants.googleLogin,
      {
        'google_id': googleId,
        'name': name,
        'email': email,
        'profile_image_url': profileImage ?? '',
      },
      contentType: 'application/x-www-form-urlencoded',
      showErrorToast: false,
    );
  }

  Future<Response<dynamic>> updateFirebaseToken({
    required String deviceToken,
    required String devicePlatform,
  }) {
    return postRequest(
      ApiConstants.updateFirebaseToken,
      {'device_token': deviceToken, 'device_platform': devicePlatform},
      contentType: 'application/x-www-form-urlencoded',
      requireAuth: true,
      showErrorToast: false,
    );
  }

  Future<Response<dynamic>> getSponsors() {
    return postRequest(
      ApiConstants.sponsors,
      <String, dynamic>{},
      contentType: 'application/x-www-form-urlencoded',
      requireAuth: true,
      showErrorToast: false,
    );
  }

  Future<Response<dynamic>> getMantras() {
    return postRequest(
      ApiConstants.mantras,
      <String, dynamic>{},
      contentType: 'application/x-www-form-urlencoded',
      requireAuth: true,
      showErrorToast: false,
    );
  }

  Future<Response<dynamic>> getJapaStatus({int? mantraId}) {
    final body = <String, dynamic>{};
    if (mantraId != null) {
      body['mantra_id'] = mantraId;
    }
    return postRequest(
      ApiConstants.getJapaStatus,
      body,
      contentType: 'application/x-www-form-urlencoded',
      requireAuth: true,
      showErrorToast: false,
    );
  }

  Future<Response<dynamic>> saveJapaProgress({
    required int mantraId,
    int? incrementBy,
    int? currentCount,
    int? chantCount,
    int? targetCount,
  }) {
    final body = <String, dynamic>{'mantra_id': mantraId};
    if (incrementBy != null) body['increment_by'] = incrementBy;
    if (currentCount != null) body['current_count'] = currentCount;
    if (chantCount != null) body['chant_count'] = chantCount;
    if (targetCount != null) body['target_count'] = targetCount;

    return postRequest(
      ApiConstants.saveJapaProgress,
      body,
      contentType: 'application/x-www-form-urlencoded',
      requireAuth: true,
      showErrorToast: false,
    );
  }

  Future<Response<dynamic>> getProfile() {
    return postRequest(
      ApiConstants.getProfile,
      <String, dynamic>{},
      contentType: 'application/x-www-form-urlencoded',
      requireAuth: true,
      showErrorToast: false,
      timeout: const Duration(seconds: 60),
    );
  }

  Future<Response<dynamic>> searchPlaces({
    required String query,
    int limit = 5,
  }) {
    return postRequest(
      ApiConstants.searchPlaces,
      FormData({'q': query, 'limit': limit.clamp(1, 10).toString()}),
      contentType: 'multipart/form-data',
      requireAuth: true,
      showErrorToast: false,
    );
  }

  Future<Response<dynamic>> listNotifications({int page = 1, int limit = 20}) {
    return postRequest(
      ApiConstants.notifications,
      {'page': page, 'limit': limit.clamp(1, 100)},
      contentType: 'application/x-www-form-urlencoded',
      requireAuth: true,
      showErrorToast: false,
    );
  }

  Future<Response<dynamic>> markNotificationRead({
    required int notificationId,
  }) {
    return postRequest(
      ApiConstants.markNotificationRead,
      {'notification_id': notificationId},
      contentType: 'application/x-www-form-urlencoded',
      requireAuth: true,
      showErrorToast: false,
    );
  }

  Future<Response<dynamic>> listLiveDarshan({
    int page = 1,
    int limit = 20,
    int? isLive,
  }) {
    final body = <String, dynamic>{
      'page': page < 1 ? 1 : page,
      'limit': limit.clamp(1, 100),
    };
    if (isLive != null) {
      body['is_live'] = isLive == 1 ? 1 : 0;
    }

    return postRequest(
      ApiConstants.listLiveDarshan,
      body,
      contentType: 'application/x-www-form-urlencoded',
      requireAuth: true,
      showErrorToast: false,
    );
  }

  Future<Response<dynamic>> listDeities() {
    return postRequest(
      ApiConstants.listDeities,
      <String, dynamic>{},
      contentType: 'application/x-www-form-urlencoded',
      requireAuth: true,
      showErrorToast: false,
      timeout: const Duration(seconds: 20),
      retryCount: 1,
    );
  }

  Future<Response<dynamic>> listSpiritualMedia({
    int page = 1,
    int limit = 20,
    String? search,
    String? mediaType,
  }) {
    final body = <String, dynamic>{
      'page': page < 1 ? 1 : page,
      'limit': limit.clamp(1, 100),
    };
    if (search != null && search.trim().isNotEmpty) {
      body['search'] = search.trim();
    }
    if (mediaType != null && mediaType.trim().isNotEmpty) {
      body['media_type'] = mediaType.trim().toLowerCase();
    }

    return postRequest(
      ApiConstants.listSpiritualMedia,
      body,
      contentType: 'application/x-www-form-urlencoded',
      requireAuth: true,
      showErrorToast: false,
      timeout: const Duration(seconds: 20),
      retryCount: 1,
    );
  }

  Future<Response<dynamic>> getSpiritualMediaDetail({
    required int mediaId,
  }) {
    return postRequest(
      ApiConstants.getSpiritualMediaDetail,
      {'media_id': mediaId},
      contentType: 'application/x-www-form-urlencoded',
      requireAuth: true,
      showErrorToast: false,
      timeout: const Duration(seconds: 20),
      retryCount: 1,
    );
  }

  Future<Response<dynamic>> listSubscriptionPlans() {
    return postRequest(
      ApiConstants.listSubscriptionPlans,
      <String, dynamic>{},
      contentType: 'application/x-www-form-urlencoded',
      requireAuth: true,
      showErrorToast: false,
    );
  }

  Future<Response<dynamic>> createSubscriptionOrder({required int planId}) {
    return postRequest(
      ApiConstants.createSubscriptionOrder,
      {'plan_id': planId},
      contentType: 'application/x-www-form-urlencoded',
      requireAuth: true,
      showErrorToast: false,
    );
  }

  Future<Response<dynamic>> verifySubscriptionPayment({
    required Map<String, dynamic> body,
  }) {
    return postRequest(
      ApiConstants.verifySubscriptionPayment,
      body,
      contentType: 'application/x-www-form-urlencoded',
      requireAuth: true,
      showErrorToast: false,
    );
  }

  Future<Response<dynamic>> createSrcOrder({required int srcQuantity}) {
    return postRequest(
      ApiConstants.createSrcOrder,
      {'src_quantity': srcQuantity},
      contentType: 'application/x-www-form-urlencoded',
      requireAuth: true,
      showErrorToast: false,
    );
  }

  Future<Response<dynamic>> verifySrcPayment({
    required Map<String, dynamic> body,
  }) {
    return postRequest(
      ApiConstants.verifySrcPayment,
      body,
      contentType: 'application/x-www-form-urlencoded',
      requireAuth: true,
      showErrorToast: false,
      timeout: const Duration(seconds: 60),
    );
  }

  Future<Response<dynamic>> getSrcHistory() {
    return postRequest(
      ApiConstants.srcHistory,
      <String, dynamic>{},
      contentType: 'application/x-www-form-urlencoded',
      requireAuth: true,
      showErrorToast: false,
      timeout: const Duration(seconds: 60),
    );
  }

  Future<Response<dynamic>> getTodayPanchang({
    required double lat,
    required double lng,
    String? date,
  }) {
    final body = <String, dynamic>{
      'lat': lat.toString(),
      'lng': lng.toString(),
    };
    if (date != null && date.isNotEmpty) {
      body['date'] = date;
    }

    return postRequest(
      ApiConstants.getTodayPanchang,
      body,
      contentType: 'application/x-www-form-urlencoded',
      requireAuth: true,
      showErrorToast: false,
    );
  }

  Future<Response<dynamic>> getDetailedKundliMatching({
    String? girlName,
    required double girlLat,
    required double girlLng,
    required String girlDob,
    String? boyName,
    required double boyLat,
    required double boyLng,
    required String boyDob,
  }) {
    final body = <String, dynamic>{
      'girl_lat': girlLat.toString(),
      'girl_lng': girlLng.toString(),
      'girl_dob': girlDob,
      'boy_lat': boyLat.toString(),
      'boy_lng': boyLng.toString(),
      'boy_dob': boyDob,
    };
    if (girlName != null && girlName.isNotEmpty) {
      body['girl_name'] = girlName;
    }
    if (boyName != null && boyName.isNotEmpty) {
      body['boy_name'] = boyName;
    }

    return postRequest(
      ApiConstants.getDetailedKundliMatching,
      body,
      contentType: 'application/x-www-form-urlencoded',
      requireAuth: true,
      showErrorToast: false,
    );
  }

  Future<Response<dynamic>> updateProfile({
    required dynamic body,
    String contentType = 'application/x-www-form-urlencoded',
  }) {
    return postRequest(
      ApiConstants.updateProfile,
      body,
      contentType: contentType,
      requireAuth: true,
      showErrorToast: false,
    );
  }

  Future<Response<dynamic>> askPandit({
    required String question,
    String? sessionId,
    int stream = 0,
    double? lat,
    double? lng,
  }) {
    final body = <String, dynamic>{
      'question': question,
      'stream': stream,
      'language': _requestLanguageCode(),
    };
    if (sessionId != null && sessionId.trim().isNotEmpty) {
      body['session_id'] = sessionId.trim();
    }
    if (lat != null && lng != null) {
      body['lat'] = lat.toString();
      body['lng'] = lng.toString();
    }
    return postRequest(
      ApiConstants.askPandit,
      body,
      contentType: 'application/x-www-form-urlencoded',
      requireAuth: true,
      showErrorToast: false,
    );
  }

  Future<Response<dynamic>> getAskPanditWelcomeMessage({String? sessionId}) {
    final body = <String, dynamic>{'language': _requestLanguageCode()};
    if (sessionId != null && sessionId.trim().isNotEmpty) {
      body['session_id'] = sessionId.trim();
    }
    return postRequest(
      ApiConstants.askPanditWelcome,
      body,
      contentType: 'application/x-www-form-urlencoded',
      requireAuth: true,
      showErrorToast: false,
    );
  }

  Future<Response<dynamic>> getTodayNityaKarmaChecklist({String? date}) {
    final body = <String, dynamic>{'language': _requestLanguageCode()};
    if (date != null && date.isNotEmpty) {
      body['date'] = date;
    }
    return postRequest(
      ApiConstants.getTodayNityaKarmaChecklist,
      body,
      contentType: 'application/x-www-form-urlencoded',
      requireAuth: true,
      showErrorToast: false,
    );
  }

  Future<Response<dynamic>> toggleNityaKarmaCompletion({
    int? scheduleId,
    int? habitId,
    required int isCompleted,
    String? date,
  }) {
    final body = <String, dynamic>{
      'is_completed': isCompleted,
      'language': _requestLanguageCode(),
    };
    if (scheduleId != null) {
      body['schedule_id'] = scheduleId;
    }
    if (habitId != null) {
      body['habit_id'] = habitId;
    }
    if (date != null && date.isNotEmpty) {
      body['date'] = date;
    }

    return postRequest(
      ApiConstants.toggleNityaKarmaCompletion,
      body,
      contentType: 'application/x-www-form-urlencoded',
      requireAuth: true,
      showErrorToast: false,
    );
  }

  Future<Response<dynamic>> getPublicSettings({String? settingKey}) {
    final body = <String, dynamic>{};
    if (settingKey != null && settingKey.trim().isNotEmpty) {
      body['setting_key'] = settingKey.trim();
    }

    return postRequest(
      ApiConstants.publicSettings,
      body,
      contentType: 'application/x-www-form-urlencoded',
      includeAuthHeader: false,
      showErrorToast: false,
    );
  }

  void _handleAuthFailure(String message, {required bool showToast}) {
    if (_isAuthFailureHandled) return;
    _isAuthFailureHandled = true;

    if (showToast) {
      ToastUtils.show(message, backgroundColor: const Color(0xFFD32F2F));
    }
    unawaited(_logout());
  }

  bool _isTimeoutResponse(Response<dynamic> response) {
    final text = response.statusText?.trim();
    return text != null && text.startsWith('TimeoutException');
  }

  Future<void> _logout() async {
    await StorageService.clearSession();
    Get.offAll(() => LoginView());
  }
}
