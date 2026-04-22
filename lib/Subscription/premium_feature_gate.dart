import 'package:dharma_app/Profile/profile_controller.dart';
import 'package:dharma_app/Subscription/subscription_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PremiumFeatureGate {
  PremiumFeatureGate._();

  static Future<void> open({
    required BuildContext context,
    required Widget Function() featureBuilder,
  }) async {
    final profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController(), permanent: true);

    await profileController.ensureProfileLoaded();
    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => profileController.hasActiveSubscription
            ? featureBuilder()
            : SubscriptionPlansView(
                successDestinationBuilder: featureBuilder,
              ),
      ),
    );
  }
}
