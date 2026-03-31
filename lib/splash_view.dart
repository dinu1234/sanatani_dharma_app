import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'splash_controller.dart';

class SplashView extends StatelessWidget {
  SplashView({super.key});

  final SplashController controller = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        /// 🌈 SAME GRADIENT (IMPORTANT)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFD6EAF8),
              Color(0xFFA9CCE3),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                /// 🔴 YOUR LOGO
                Image.asset(
                  "assets/images/dharma.png", // 👈 apna logo
                  height: size.height * 0.20,
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}