import 'package:dharma_app/Profile/profile_setup_view.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  final isOtpSent = false.obs;
  final countryCode = "+91".obs;

  void showToast(String msg, {Color bgColor = Colors.black}) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: bgColor,
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  void sendOtp() {
    final phone = phoneController.text.trim();

    if (phone.isEmpty || !GetUtils.isNumericOnly(phone)) {
      showToast("Enter valid mobile number", bgColor: Colors.red);
      return;
    }

    final fullNumber = "${countryCode.value}$phone";
    debugPrint("Sending OTP to: $fullNumber");

    isOtpSent.value = true;
    showToast("OTP Sent Successfully", bgColor: Colors.green);
  }

  void verifyOtp() {
    final otp = otpController.text.trim();

    if (otp.length < 4 || !GetUtils.isNumericOnly(otp)) {
      showToast("Enter valid OTP", bgColor: Colors.red);
      return;
    }

    if (otp == "1234") {
      showToast("OTP Verified", bgColor: Colors.green);
      Get.to(() => const ProfileSetupView());
    } else {
      showToast("Invalid OTP", bgColor: Colors.red);
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
