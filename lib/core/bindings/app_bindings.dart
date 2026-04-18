import 'package:dharma_app/Login/login_repository.dart';
import 'package:dharma_app/LiveDarshan/live_darshan_controller.dart';
import 'package:dharma_app/LiveDarshan/live_darshan_repository.dart';
import 'package:dharma_app/Notifications/notifications_controller.dart';
import 'package:dharma_app/Notifications/notifications_repository.dart';
import 'package:dharma_app/Profile/profile_controller.dart';
import 'package:dharma_app/Profile/profile_repository.dart';
import 'package:dharma_app/GanaMatch/gana_match_repository.dart';
import 'package:dharma_app/Panchang/panchang_repository.dart';
import 'package:dharma_app/content/content_controller.dart';
import 'package:dharma_app/content/content_repository.dart';
import 'package:dharma_app/japa/japa_controller.dart';
import 'package:dharma_app/japa/japa_repository.dart';
import 'package:dharma_app/services/api_service.dart';
import 'package:get/get.dart';

class AppBindings {
  AppBindings._();

  static void init() {
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService(), permanent: true);
    }

    if (!Get.isRegistered<LoginRepository>()) {
      Get.put(
        LoginRepository(apiService: Get.find<ApiService>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<ProfileRepository>()) {
      Get.put(
        ProfileRepository(apiService: Get.find<ApiService>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<NotificationsRepository>()) {
      Get.put(
        NotificationsRepository(apiService: Get.find<ApiService>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<LiveDarshanRepository>()) {
      Get.put(
        LiveDarshanRepository(apiService: Get.find<ApiService>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<ContentRepository>()) {
      Get.put(
        ContentRepository(apiService: Get.find<ApiService>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<JapaRepository>()) {
      Get.put(
        JapaRepository(apiService: Get.find<ApiService>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<PanchangRepository>()) {
      Get.put(
        PanchangRepository(apiService: Get.find<ApiService>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<GanaMatchRepository>()) {
      Get.put(
        GanaMatchRepository(apiService: Get.find<ApiService>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<ProfileController>()) {
      Get.put(
        ProfileController(repository: Get.find<ProfileRepository>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<ContentController>()) {
      Get.put(
        ContentController(repository: Get.find<ContentRepository>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<JapaController>()) {
      Get.put(
        JapaController(repository: Get.find<JapaRepository>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<NotificationsController>()) {
      Get.put(
        NotificationsController(repository: Get.find<NotificationsRepository>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<LiveDarshanController>()) {
      Get.put(
        LiveDarshanController(repository: Get.find<LiveDarshanRepository>()),
        permanent: true,
      );
    }

  }
}
