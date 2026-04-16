import 'package:dharma_app/Notifications/notifications_model.dart';
import 'package:dharma_app/core/utils/api_utils.dart';
import 'package:dharma_app/services/api_service.dart';
import 'package:get/get.dart';

class NotificationsRepository {
  NotificationsRepository({ApiService? apiService})
    : _apiService =
          apiService ??
          (Get.isRegistered<ApiService>()
              ? Get.find<ApiService>()
              : Get.put(ApiService(), permanent: true));

  final ApiService _apiService;

  Future<NotificationsResponseModel> listNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiService.listNotifications(
      page: page,
      limit: limit,
    );

    final mapBody = ApiUtils.asMap(response.body);
    if (mapBody != null) {
      return NotificationsResponseModel.fromJson(mapBody);
    }

    return NotificationsResponseModel(
      success: false,
      message: response.statusText ?? 'Failed to fetch notifications',
    );
  }

  Future<MarkNotificationReadResponseModel> markNotificationRead({
    required int notificationId,
  }) async {
    final response = await _apiService.markNotificationRead(
      notificationId: notificationId,
    );

    final mapBody = ApiUtils.asMap(response.body);
    if (mapBody != null) {
      return MarkNotificationReadResponseModel.fromJson(mapBody);
    }

    return MarkNotificationReadResponseModel(
      success: false,
      message: response.statusText ?? 'Failed to mark notification as read',
    );
  }
}
