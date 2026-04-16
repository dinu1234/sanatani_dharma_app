import 'package:dharma_app/Notifications/notifications_controller.dart';
import 'package:dharma_app/Notifications/notifications_model.dart';
import 'package:dharma_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class NotificationsView extends StatelessWidget {
  NotificationsView({super.key});

  final NotificationsController controller =
      Get.isRegistered<NotificationsController>()
          ? Get.find<NotificationsController>()
          : Get.put(NotificationsController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.homeBackground,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: _NotificationsBody(),
    );
  }
}

class _NotificationsBody extends StatelessWidget {
  const _NotificationsBody();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationsController>();

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.homeBackground,
        foregroundColor: AppColors.homePrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notifications.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.loadNotifications,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 180),
                Center(
                  child: Text(
                    'No notifications yet',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.homePrimary,
          onRefresh: controller.loadNotifications,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            itemCount: controller.notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = controller.notifications[index];
              return _NotificationTile(item: item);
            },
          ),
        );
      }),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});

  final AppNotificationItem item;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationsController>();

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () async {
        await controller.markAsRead(item);
        if (!context.mounted) return;
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(item.title ?? 'Notification'),
            content: Text(item.body ?? 'No message available'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.unread ? Colors.white : Colors.white.withOpacity(0.72),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: item.unread
                ? const Color(0x33A11717)
                : const Color(0x1A000000),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: item.unread
                    ? AppColors.homePrimary.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_active_rounded,
                color: AppColors.homePrimary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title ?? 'Notification',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                item.unread ? FontWeight.w700 : FontWeight.w600,
                            color: AppColors.homePrimary,
                          ),
                        ),
                      ),
                      if (item.unread)
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE53935),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.body ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      color: Color(0xFF4B4B4B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.createdAt ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7B7B7B),
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
