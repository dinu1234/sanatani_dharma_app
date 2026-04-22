import 'package:dharma_app/Login/LoginModel.dart';
import 'package:dharma_app/core/utils/api_utils.dart';
import 'package:dharma_app/services/api_service.dart';
import 'package:get/get.dart';

class LoginRepository {
  LoginRepository({ApiService? apiService})
    : _apiService =
          apiService ??
          (Get.isRegistered<ApiService>()
              ? Get.find<ApiService>()
              : Get.put(ApiService(), permanent: true));

  final ApiService _apiService;

  Future<SendOtpResponseModel> sendOtp({
    required String countryCode,
    required String mobile,
  }) async {
    final response = await _apiService.sendOtp(
      countryCode: countryCode,
      mobile: mobile,
    );

    final mapBody = ApiUtils.asMap(response.body);
    if (mapBody != null) {
      return SendOtpResponseModel.fromJson(mapBody);
    }

    return SendOtpResponseModel(
      success: false,
      message: response.statusText ?? "Failed to send OTP",
    );
  }

  Future<SendOtpResponseModel> resendOtp({
    required String countryCode,
    required String mobile,
  }) async {
    final response = await _apiService.resendOtp(
      countryCode: countryCode,
      mobile: mobile,
    );

    final mapBody = ApiUtils.asMap(response.body);
    if (mapBody != null) {
      return SendOtpResponseModel.fromJson(mapBody);
    }

    return SendOtpResponseModel(
      success: false,
      message: response.statusText ?? "Failed to resend OTP",
    );
  }

  Future<VerifyOtpResponseModel> verifyOtp({
    required String countryCode,
    required String mobile,
    required String otp,
  }) async {
    final response = await _apiService.verifyOtp(
      countryCode: countryCode,
      mobile: mobile,
      otp: otp,
    );

    final mapBody = ApiUtils.asMap(response.body);
    if (mapBody != null) {
      return VerifyOtpResponseModel.fromJson(mapBody);
    }

    return VerifyOtpResponseModel(
      success: false,
      message: response.statusText ?? "Invalid OTP",
    );
  }

  Future<VerifyOtpResponseModel> googleLogin({
    required String googleId,
    required String name,
    required String email,
    String? profileImage,
  }) async {
    final response = await _apiService.googleLogin(
      googleId: googleId,
      name: name,
      email: email,
      profileImage: profileImage,
    );

    final mapBody = ApiUtils.asMap(response.body);
    if (mapBody != null) {
      return VerifyOtpResponseModel.fromJson(mapBody);
    }

    return VerifyOtpResponseModel(
      success: false,
      message: response.statusText ?? "Google login failed",
    );
  }
}
