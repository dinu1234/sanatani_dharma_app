import 'package:country_code_picker/country_code_picker.dart';
import 'package:dharma_app/core/widgets/app_loader.dart';
import 'package:dharma_app/core/widgets/shree_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'login_controller.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final LoginController controller =
      Get.isRegistered<LoginController>()
          ? Get.find<LoginController>()
          : Get.put(LoginController());
  static const Color _topBgColor = Color(0xFFD6EAF8);
  static const Color _bottomBgColor = Color(0xFFA9CCE3);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _topBgColor,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Obx(
          () => Stack(
            children: [
              SafeArea(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_topBgColor, _bottomBgColor],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ShreeSvg(height: size.height * 0.12),
                              const SizedBox(width: 10),
                              Text(
                                "Global Sanathan\nCommunity",
                                style: TextStyle(
                                  fontSize: size.width * 0.08,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF8B0000),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.10),
                          Container(
                            width: size.width * 0.9,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 15,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 82,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: CountryCodePicker(
                                        onChanged: (country) {
                                          controller.countryCode.value =
                                              country.dialCode ?? "+91";
                                          controller.countryIsoCode.value =
                                              country.code ?? "IN";
                                        },
                                        initialSelection: 'IN',
                                        favorite: const ['+91', 'IN'],
                                        showCountryOnly: false,
                                        showOnlyCountryWhenClosed: false,
                                        alignLeft: false,
                                        padding: EdgeInsets.zero,
                                        flagWidth: 20,
                                        textStyle: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        controller: controller.phoneController,
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.done,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(15),
                                        ],
                                        enabled:
                                            !controller.isOtpSent.value &&
                                            !controller.isLoading,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.grey.shade200,
                                          hintText: "Enter mobile number",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (controller.isOtpSent.value) ...[
                                  const SizedBox(height: 15),
                                  TextField(
                                    controller: controller.otpController,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.done,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    enabled: !controller.isLoading,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.grey.shade200,
                                      hintText: "Enter OTP",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        controller.resendSecondsLeft.value > 0
                                            ? "Resend OTP in ${controller.resendSecondsLeft.value}s"
                                            : "Didn't receive OTP?",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed:
                                            controller.canResendOtp &&
                                                    !controller.isLoading
                                                ? controller.resendOtp
                                                : null,
                                        style: TextButton.styleFrom(
                                          foregroundColor: const Color(
                                            0xFF8B0000,
                                          ),
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(0, 0),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text(
                                          "Resend OTP",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF8B0000),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    onPressed: () {
                                      if (controller.isLoading) {
                                        return;
                                      }

                                      if (!controller.isOtpSent.value) {
                                        controller.sendOtp();
                                      } else {
                                        controller.verifyOtp();
                                      }
                                    },
                                    child: Text(
                                      controller.isOtpSent.value
                                          ? "Verify OTP"
                                          : "Send OTP",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: size.height * 0.11),
                          Text(
                            "Continue with Google",
                            style: TextStyle(
                              fontSize: size.width * 0.045,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: controller.isLoading
                                ? null
                                : controller.continueWithGoogle,
                            child: CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.white,
                              child: Image.network(
                                "https://cdn-icons-png.flaticon.com/512/281/281764.png",
                                height: 35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (controller.isLoading)
                AppLoader(message: controller.loadingMessage),
            ],
          ),
        ),
      ),
    );
  }
}
