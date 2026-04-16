import 'package:dharma_app/Notifications/notifications_model.dart';
import 'package:dharma_app/Notifications/notifications_repository.dart';
import 'package:dharma_app/core/utils/toast_utils.dart';
import 'package:dharma_app/services/storage_service.dart';
import 'package:get/get.dart';

class NotificationsController extends GetxController {
  NotificationsController({NotificationsRepository? repository})
    : _repository =
          repository ??
          (Get.isRegistered<NotificationsRepository>()
              ? Get.find<NotificationsRepository>()
              : Get.put(NotificationsRepository(), permanent: true));

  final NotificationsRepository _repository;

  final isLoading = false.obs;
  final isMarkingRead = false.obs;
  final notifications = <AppNotificationItem>[].obs;
  final currentPage = 1.obs;
  final totalItems = 0.obs;

  int get unreadCount => notifications.where((item) => item.unread).length;

  @override
  void onInit() {
    super.onInit();
    if (StorageService.getToken()?.isNotEmpty == true) {
      loadNotifications();
    }
  }

  Future<void> loadNotifications({int page = 1, int limit = 20}) async {
    if (StorageService.getToken()?.isNotEmpty != true) return;
    isLoading.value = true;
    try {
      final model = await _repository.listNotifications(page: page, limit: limit);
      if (!model.success) {
        if (model.message.isNotEmpty) {
          ToastUtils.show(model.message);
        }
        return;
      }

      notifications.assignAll(model.data?.notifications ?? const []);
      currentPage.value = model.data?.pagination?.page ?? page;
      totalItems.value = model.data?.pagination?.total ?? notifications.length;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(AppNotificationItem item) async {
    final notificationId = item.id;
    if (notificationId == null || !item.unread || isMarkingRead.value) return;

    isMarkingRead.value = true;
    try {
      final model = await _repository.markNotificationRead(
        notificationId: notificationId,
      );
      if (!model.success) {
        if (model.message.isNotEmpty) {
          ToastUtils.show(model.message);
        }
        return;
      }

      final index = notifications.indexWhere((element) => element.id == notificationId);
      if (index >= 0) {
        notifications[index] = notifications[index].copyWith(isRead: 1);
        notifications.refresh();
      }
    } finally {
      isMarkingRead.value = false;
    }
  }
}
