import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginController extends GetxController {
  TextEditingController phoneController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  var isOtpSent = false.obs;

  /// 🌍 Country Code
  var countryCode = "+91".obs;

  /// 🔔 Common Toast Function
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

  /// 📤 SEND OTP
  void sendOtp() {
    String phone = phoneController.text.trim();

    if (phone.length != 10 || !GetUtils.isNumericOnly(phone)) {
      showToast("Enter valid 10 digit number", bgColor: Colors.red);
      return;
    }

    String fullNumber = "${countryCode.value}$phone";
    print("Sending OTP to: $fullNumber");

    isOtpSent.value = true;

    showToast("OTP Sent Successfully", bgColor: Colors.green);
  }

  /// 🔐 VERIFY OTP
  void verifyOtp() {
    String otp = otpController.text.trim();

    if (otp.length < 4 || !GetUtils.isNumericOnly(otp)) {
      showToast("Enter valid OTP", bgColor: Colors.red);
      return;
    }
     
    /// 🔥 Dummy verification
    if (otp == "1234") {
      showToast("OTP Verified ✅", bgColor: Colors.green);

      /// 👉 Navigate
      // Get.offAll(() => HomeView());

    } else {
      showToast("Invalid OTP ❌", bgColor: Colors.red);
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }
}