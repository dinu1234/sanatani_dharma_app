import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,

          /// 🌈 Gradient
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD6EAF8), Color(0xFFA9CCE3)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),

          child: Center(
            // ✅ PURE UI CENTER
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// 🔴 LOGO + TEXT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/dharma.png",
                        height: size.height * 0.12,
                      ),
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

                  /// 📦 CARD
                  Container(
                    width: size.width * 0.85,
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

                    child: Obx(
                      () => Column(
                        children: [
                          /// 📱 PHONE FIELD
                          Row(
                            children: [
                              /// 🌍 FULL COUNTRY PICKER WITH FLAG
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: CountryCodePicker(
                                  onChanged: (country) {
                                    controller.countryCode.value =
                                        country.dialCode!;
                                  },
                                  initialSelection: 'IN',
                                  favorite: const ['+91', 'IN'],
                                  showCountryOnly: false,
                                  showOnlyCountryWhenClosed: false,
                                  alignLeft: false,
                                ),
                              ),

                              const SizedBox(width: 10),

                              /// 📱 PHONE INPUT
                              Expanded(
                                child: TextField(
                                  controller: controller.phoneController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 10,
                                  enabled: !controller.isOtpSent.value,
                                  decoration: InputDecoration(
                                    counterText: "",
                                    filled: true,
                                    fillColor: Colors.grey.shade200,
                                    hintText: "Enter mobile number",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          /// 🔢 OTP FIELD (same card me niche)
                          if (controller.isOtpSent.value) ...[
                            const SizedBox(height: 15),

                            TextField(
                              controller: controller.otpController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                hintText: "Enter OTP",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),

                          /// 🔘 BUTTON
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
                  ),

                  SizedBox(height: size.height * 0.11),

                  /// 🌐 GOOGLE LOGIN
                  Text(
                    "Connect with Google",
                    style: TextStyle(
                      fontSize: size.width * 0.045,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 20),

                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Image.network(
                      "https://cdn-icons-png.flaticon.com/512/281/281764.png",
                      height: 35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
