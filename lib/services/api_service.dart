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
      final token = StorageService.getToken();
      if (token != null && token.isNotEmpty) {
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
    bool showErrorToast = true,
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
        if (showErrorToast) {
          ToastUtils.show("Please login again");
        }
        _logout();
        return Response(statusCode: 401, statusText: "Unauthorized");
      }
    }

    try {
      final response = await post(
        endpoint,
        body,
        contentType: contentType,
      );
      _logResponse(
        method: 'POST',
        endpoint: endpoint,
        response: response,
      );

      if (requireAuth &&
          (response.statusCode == 400 ||
              response.statusCode == 401 ||
              response.statusCode == 402)) {
        _logoutWithToast(
          ApiUtils.message(response.body) ??
              "Session expired. Please login again.",
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

  Future<Response<dynamic>> sendOtp({
    required String countryCode,
    required String mobile,
  }) {
    return postRequest(
      ApiConstants.sendOtp,
      {
        'country_code': countryCode,
        'mobile': mobile,
      },
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
      {
        'country_code': countryCode,
        'mobile': mobile,
      },
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
      {
        'country_code': countryCode,
        'mobile': mobile,
        'otp': otp,
      },
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
      {
        'device_token': deviceToken,
        'device_platform': devicePlatform,
      },
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
    final body = <String, dynamic>{
      'mantra_id': mantraId,
    };
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
    );
  }

  Future<Response<dynamic>> listNotifications({
    int page = 1,
    int limit = 20,
  }) {
    return postRequest(
      ApiConstants.notifications,
      {
        'page': page,
        'limit': limit.clamp(1, 100),
      },
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
      {
        'notification_id': notificationId,
      },
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

  void _logoutWithToast(String message) {
    _logout();
    ToastUtils.show(
      message,
      backgroundColor: const Color(0xFFD32F2F),
    );
  }

  void _logout() {
    StorageService.clear();
    Get.offAll(() => LoginView());
  }
}
