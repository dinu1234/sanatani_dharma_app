import 'dart:async';

import 'package:dharma_app/Home/home_view.dart';
import 'package:dharma_app/Login/LoginModel.dart';
import 'package:dharma_app/Login/login_repository.dart';
import 'package:dharma_app/core/utils/toast_utils.dart';
import 'package:dharma_app/Profile/profile_setup_view.dart';
import 'package:dharma_app/services/notification_service.dart';
import 'package:dharma_app/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginController extends GetxController {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  final isOtpSent = false.obs;
  final isSendingOtp = false.obs;
  final isResendingOtp = false.obs;
  final isVerifyingOtp = false.obs;
  final isGoogleSigningIn = false.obs;
  final resendSecondsLeft = 0.obs;
  final countryCode = "+91".obs;
  final countryIsoCode = "IN".obs;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final LoginRepository _repository =
      Get.isRegistered<LoginRepository>()
          ? Get.find<LoginRepository>()
          : Get.put(LoginRepository(), permanent: true);
  Timer? _resendTimer;

  static const Map<String, List<int>> _phoneLengthByCountry = {
    "IN": [10],
    "US": [10],
    "CA": [10],
    "GB": [10, 11],
    "AU": [9],
    "AE": [9],
    "SG": [8],
    "MY": [9, 10],
    "NP": [10],
    "LK": [9],
  };

  bool get isLoading =>
      isSendingOtp.value ||
      isResendingOtp.value ||
      isVerifyingOtp.value ||
      isGoogleSigningIn.value;

  String get loadingMessage =>
      isGoogleSigningIn.value
          ? "Signing in with Google"
          : isResendingOtp.value
          ? "Resending OTP"
          : isVerifyingOtp.value
          ? "Verifying OTP"
          : "Sending OTP";

  bool get canResendOtp => isOtpSent.value && resendSecondsLeft.value == 0;

  bool _isBlank(String? value) =>
      value == null ||
      value.trim().isEmpty ||
      value.trim().toLowerCase() == 'null';

  bool _isProfileComplete(dynamic user) =>
      user != null &&
      !_isBlank(user.fullName) &&
      !_isBlank(user.currentLocation) &&
      !_isBlank(user.gender) &&
      !_isBlank(user.birthDate) &&
      !_isBlank(user.birthPlace);

  String _buildSendOtpSuccessMessage(SendOtpResponseModel model) {
    final baseMessage =
        model.message.isEmpty ? "OTP Sent Successfully" : model.message;
    final debugOtp = model.data?.debugOtp?.trim();

    if (debugOtp == null || debugOtp.isEmpty) {
      return baseMessage;
    }

    return "$baseMessage\nOTP: $debugOtp";
  }

  void _startResendCooldown([int seconds = 30]) {
    _resendTimer?.cancel();
    resendSecondsLeft.value = seconds;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSecondsLeft.value <= 1) {
        resendSecondsLeft.value = 0;
        timer.cancel();
        return;
      }

      resendSecondsLeft.value -= 1;
    });
  }

  Future<void> sendOtp() async {
    final phone = phoneController.text.trim();

    if (!_isValidPhoneNumber(phone)) {
      final expectedLengths =
          _phoneLengthByCountry[countryIsoCode.value] ?? const [6, 15];
      final lengthHint = expectedLengths.length == 1
          ? "${expectedLengths.first} digits"
          : "${expectedLengths.first}-${expectedLengths.last} digits";

      ToastUtils.show(
        "Enter valid mobile number ($lengthHint)",
        backgroundColor: const Color(0xFFD32F2F),
      );
      return;
    }

    isSendingOtp.value = true;

    try {
      final model = await _repository.sendOtp(
        countryCode: countryCode.value,
        mobile: phone,
      );

      if (!model.success) {
        ToastUtils.show(
          model.message.isEmpty ? "Failed to send OTP" : model.message,
          backgroundColor: const Color(0xFFD32F2F),
        );
        return;
      }

      isOtpSent.value = true;
      otpController.clear();
      _startResendCooldown();
      ToastUtils.show(
        _buildSendOtpSuccessMessage(model),
        backgroundColor: const Color(0xFF2E7D32),
        toastLength: Toast.LENGTH_LONG,
      );
      debugPrint(
        "Send OTP response: country=${model.data?.countryCode}, mobile=${model.data?.mobile}, debugOtp=${model.data?.debugOtp}",
      );
    } finally {
      isSendingOtp.value = false;
    }
  }

  Future<void> resendOtp() async {
    final phone = phoneController.text.trim();

    if (!isOtpSent.value) {
      await sendOtp();
      return;
    }

    if (!canResendOtp) {
      ToastUtils.show(
        "Please wait ${resendSecondsLeft.value}s before resending OTP",
        backgroundColor: const Color(0xFFD32F2F),
      );
      return;
    }

    if (!_isValidPhoneNumber(phone)) {
      ToastUtils.show(
        "Enter valid mobile number",
        backgroundColor: const Color(0xFFD32F2F),
      );
      return;
    }

    isResendingOtp.value = true;

    try {
      final model = await _repository.resendOtp(
        countryCode: countryCode.value,
        mobile: phone,
      );

      if (!model.success) {
        ToastUtils.show(
          model.message.isEmpty ? "Failed to resend OTP" : model.message,
          backgroundColor: const Color(0xFFD32F2F),
        );
        return;
      }

      otpController.clear();
      _startResendCooldown();
      ToastUtils.show(
        _buildSendOtpSuccessMessage(model),
        backgroundColor: const Color(0xFF2E7D32),
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      isResendingOtp.value = false;
    }
  }

  bool _isValidPhoneNumber(String phone) {
    if (phone.isEmpty || !GetUtils.isNumericOnly(phone)) {
      return false;
    }

    final allowedLengths = _phoneLengthByCountry[countryIsoCode.value];
    if (allowedLengths != null) {
      return allowedLengths.contains(phone.length);
    }

    return phone.length >= 6 && phone.length <= 15;
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();
    final phone = phoneController.text.trim();

    if (otp.length < 4 || !GetUtils.isNumericOnly(otp)) {
      ToastUtils.show(
        "Enter valid OTP",
        backgroundColor: const Color(0xFFD32F2F),
      );
      return;
    }

    if (!_isValidPhoneNumber(phone)) {
      ToastUtils.show(
        "Enter valid mobile number",
        backgroundColor: const Color(0xFFD32F2F),
      );
      return;
    }

    isVerifyingOtp.value = true;

    try {
      final model = await _repository.verifyOtp(
        countryCode: countryCode.value,
        mobile: phone,
        otp: otp,
      );
      await _completeLogin(
        model,
        errorMessage: "Invalid OTP",
        successMessage: "Login successful",
        loginMobile: phone,
      );
    } finally {
      isVerifyingOtp.value = false;
    }
  }

  Future<void> continueWithGoogle() async {
    isGoogleSigningIn.value = true;

    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        return;
      }

      final displayName = account.displayName?.trim();
      final fallbackName = account.email.split('@').first.trim();
      final name =
          displayName != null && displayName.isNotEmpty
              ? displayName
              : fallbackName;

      final model = await _repository.googleLogin(
        googleId: account.id,
        name: name,
        email: account.email,
        profileImage: account.photoUrl,
      );

      await _completeLogin(
        model,
        errorMessage: "Google login failed",
        successMessage: "Google login successful",
        loginEmail: account.email,
      );
    } catch (e) {
      ToastUtils.show(
        "Google sign-in failed. Please try again.",
        backgroundColor: const Color(0xFFD32F2F),
      );
      debugPrint('Google sign-in error: $e');
    } finally {
      isGoogleSigningIn.value = false;
    }
  }

  Future<void> _completeLogin(
    VerifyOtpResponseModel model, {
    required String errorMessage,
    required String successMessage,
    String? loginMobile,
    String? loginEmail,
  }) async {
    if (!model.success || model.data?.token == null) {
      ToastUtils.show(
        model.message.isEmpty ? errorMessage : model.message,
        backgroundColor: const Color(0xFFD32F2F),
      );
      return;
    }

    await StorageService.setToken(model.data!.token!);
    if (loginEmail != null && loginEmail.trim().isNotEmpty) {
      await StorageService.setLoginEmail(loginEmail.trim());
    } else if (loginMobile != null && loginMobile.trim().isNotEmpty) {
      await StorageService.setLoginMobile(loginMobile.trim());
    } else if (model.data!.user?.email?.trim().isNotEmpty == true) {
      await StorageService.setLoginEmail(model.data!.user!.email!.trim());
    } else if (model.data!.user?.mobile?.trim().isNotEmpty == true) {
      await StorageService.setLoginMobile(model.data!.user!.mobile!.trim());
    }

    ToastUtils.show(
      model.message.isEmpty ? successMessage : model.message,
      backgroundColor: const Color(0xFF2E7D32),
    );

    final user = model.data!.user;
    final isProfileComplete = _isProfileComplete(user);
    await StorageService.setProfileCompleted(isProfileComplete);

    if (!isProfileComplete) {
      Get.offAll(() => const ProfileSetupView());
      return;
    }

    await NotificationService.syncTokenIfEligible();
    Get.offAll(() => const HomeView());
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
