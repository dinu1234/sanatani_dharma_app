import 'package:dharma_app/Login/LoginView.dart';
import 'package:dharma_app/core/widgets/shree_svg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import 'language_controller.dart';

class LanguageView extends StatelessWidget {
  LanguageView({super.key});

  final LanguageController controller = Get.put(LanguageController());

  final List<Map<String, String>> languages = [
    {"name": "English", "code": "en"},
    {"name": "हिंदी", "code": "hi"},
    {"name": "मराठी", "code": "mr"},
    {"name": "ગુજરાતી", "code": "gu"},
    {"name": "বাংলা", "code": "bn"},

    {"name": "मराठी", "code": "mr"},
    {"name": "ગુજરાતી", "code": "gu"},
    {"name": "বাংলা", "code": "bn"},
    {"name": "मराठी", "code": "mr"},
    {"name": "ગુજરાતી", "code": "gu"},
    {"name": "বাংলা", "code": "bn"},
    {"name": "मराठी", "code": "mr"},
    {"name": "ગુજરાતી", "code": "gu"},
    {"name": "বাংলা", "code": "bn"},
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
        body: Container(
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
        
          child: Column(
            children: [
              /// 🔝 TOP CONTENT
              Expanded(
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.06),
        
                    /// 🔴 LOGO
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ShreeSvg(height: size.height * 0.13),
                    ),
        
                    SizedBox(height: size.height * 0.02),
        
                    /// TITLE
                    Text(
                      "SRI RAM",
                      style: TextStyle(
                        fontSize: size.width * 0.075,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: const Color(0xFF8B0000),
                      ),
                    ),
        
                    SizedBox(height: size.height * 0.008),
        
                    Text(
                      "Global Sanathan Community",
                      style: TextStyle(
                        fontSize: size.width * 0.042,
                        color: const Color(0xFF8B0000),
                      ),
                    ),
        
                    SizedBox(height: size.height * 0.03),
        
                    /// 🌐 LANGUAGE LIST
                    Expanded(
                      child: ListView.builder(
                        itemCount: languages.length,
                        itemBuilder: (context, index) {
                          final lang = languages[index];
                          return GestureDetector(
                            onTap: () {
                              controller.changeLanguage(lang["code"]!);
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.01,
                              ),
                              child: Center(
                                child: Text(
                                  lang["name"]!,
                                  style: TextStyle(
                                    fontSize: size.width * 0.05,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF8B0000),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
        
              /// 🔻 BOTTOM CARD (Improved)
              Container(
                width: double.infinity,
                margin: EdgeInsets.all(size.width * 0.05),
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.025,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8C00),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "backed_by".tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * 0.035,
                      ),
                    ),
        
                    SizedBox(height: size.height * 0.005),
        
                    Text(
                      "Ek Bharat Abhiyan Foundation",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
        
                    SizedBox(height: size.height * 0.02),
        
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B0000),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.018,
                          ),
                        ),
                        onPressed: controller.selectedLang.value.isEmpty
                            ? null
                            : () {
                                Get.to(() => LoginView());
                              },
        
                        child: Text(
                          "get_started".tr,
                          style: TextStyle(
                            fontSize: size.width * 0.045,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }
}
