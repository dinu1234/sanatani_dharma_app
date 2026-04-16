class NotificationsResponseModel {
  NotificationsResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  final bool success;
  final String message;
  final NotificationsData? data;

  factory NotificationsResponseModel.fromJson(Map<String, dynamic> json) {
    return NotificationsResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? NotificationsData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class NotificationsData {
  NotificationsData({
    required this.notifications,
    this.pagination,
  });

  final List<AppNotificationItem> notifications;
  final NotificationsPagination? pagination;

  factory NotificationsData.fromJson(Map<String, dynamic> json) {
    final notificationsJson = json['notifications'];
    return NotificationsData(
      notifications: notificationsJson is List
          ? notificationsJson
              .whereType<Map>()
              .map(
                (item) => AppNotificationItem.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const [],
      pagination: json['pagination'] is Map<String, dynamic>
          ? NotificationsPagination.fromJson(
              json['pagination'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class NotificationsPagination {
  NotificationsPagination({
    this.page,
    this.limit,
    this.total,
  });

  final int? page;
  final int? limit;
  final int? total;

  factory NotificationsPagination.fromJson(Map<String, dynamic> json) {
    return NotificationsPagination(
      page: _parseInt(json['page']),
      limit: _parseInt(json['limit']),
      total: _parseInt(json['total']),
    );
  }
}

class AppNotificationItem {
  AppNotificationItem({
    this.id,
    this.title,
    this.body,
    this.notificationType,
    this.imageUrl,
    this.firebaseMessageId,
    this.sentStatus,
    this.isRead,
    this.readAt,
    this.createdAt,
    this.payload,
  });

  final int? id;
  final String? title;
  final String? body;
  final String? notificationType;
  final String? imageUrl;
  final String? firebaseMessageId;
  final String? sentStatus;
  final int? isRead;
  final String? readAt;
  final String? createdAt;
  final Map<String, dynamic>? payload;

  bool get unread => (isRead ?? 0) == 0;

  AppNotificationItem copyWith({
    int? id,
    String? title,
    String? body,
    String? notificationType,
    String? imageUrl,
    String? firebaseMessageId,
    String? sentStatus,
    int? isRead,
    String? readAt,
    String? createdAt,
    Map<String, dynamic>? payload,
  }) {
    return AppNotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      notificationType: notificationType ?? this.notificationType,
      imageUrl: imageUrl ?? this.imageUrl,
      firebaseMessageId: firebaseMessageId ?? this.firebaseMessageId,
      sentStatus: sentStatus ?? this.sentStatus,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      payload: payload ?? this.payload,
    );
  }

  factory AppNotificationItem.fromJson(Map<String, dynamic> json) {
    return AppNotificationItem(
      id: _parseInt(json['id']),
      title: _parseString(json['title']),
      body: _parseString(json['body']),
      notificationType: _parseString(json['notification_type']),
      imageUrl: _parseString(json['image_url']),
      firebaseMessageId: _parseString(json['firebase_message_id']),
      sentStatus: _parseString(json['sent_status']),
      isRead: _parseInt(json['is_read']),
      readAt: _parseString(json['read_at']),
      createdAt: _parseString(json['created_at']),
      payload: json['payload'] is Map
          ? Map<String, dynamic>.from(json['payload'] as Map)
          : null,
    );
  }
}

class MarkNotificationReadResponseModel {
  MarkNotificationReadResponseModel({
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;

  factory MarkNotificationReadResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return MarkNotificationReadResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
    );
  }
}

int? _parseInt(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '');

String? _parseString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return null;
  return text;
}
