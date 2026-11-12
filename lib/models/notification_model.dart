class NotificationResponseModel {
  final bool success;
  final String message;
  final NotificationDataModel? data;

  NotificationResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory NotificationResponseModel.fromJson(Map<String, dynamic> json) {
    return NotificationResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map
          ? NotificationDataModel.fromJson(Map<String, dynamic>.from(json['data']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class NotificationDataModel {
  final List<AppNotificationItem> notifications;
  final int retentionDays;
  final NotificationPaginationModel? pagination;

  NotificationDataModel({
    required this.notifications,
    this.retentionDays = 7,
    this.pagination,
  });

  factory NotificationDataModel.fromJson(Map<String, dynamic> json) {
    List<AppNotificationItem> list = [];
    if (json['notifications'] != null && json['notifications'] is List) {
      list = (json['notifications'] as List)
          .map((item) => AppNotificationItem.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return NotificationDataModel(
      notifications: list,
      retentionDays: json['retention_days'] is int
          ? json['retention_days']
          : int.tryParse(json['retention_days']?.toString() ?? '7') ?? 7,
      pagination: json['pagination'] != null && json['pagination'] is Map
          ? NotificationPaginationModel.fromJson(Map<String, dynamic>.from(json['pagination']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications': notifications.map((n) => n.toJson()).toList(),
      'retention_days': retentionDays,
      'pagination': pagination?.toJson(),
    };
  }
}

class NotificationPaginationModel {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMore;

  NotificationPaginationModel({
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 30,
    this.total = 0,
    this.hasMore = false,
  });

  factory NotificationPaginationModel.fromJson(Map<String, dynamic> json) {
    return NotificationPaginationModel(
      currentPage: json['current_page'] is int
          ? json['current_page']
          : int.tryParse(json['current_page']?.toString() ?? '1') ?? 1,
      lastPage: json['last_page'] is int
          ? json['last_page']
          : int.tryParse(json['last_page']?.toString() ?? '1') ?? 1,
      perPage: json['per_page'] is int
          ? json['per_page']
          : int.tryParse(json['per_page']?.toString() ?? '30') ?? 30,
      total: json['total'] is int
          ? json['total']
          : int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      hasMore: json['has_more'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'last_page': lastPage,
      'per_page': perPage,
      'total': total,
      'has_more': hasMore,
    };
  }
}

class AppNotificationItem {
  final dynamic id;
  final String module;
  final String title;
  final String body;
  final bool isRead;
  final String? readAt;
  final String? createdAt;
  final String? timeAgo;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  AppNotificationItem({
    required this.id,
    this.module = 'general',
    required this.title,
    required this.body,
    this.isRead = false,
    this.readAt,
    this.createdAt,
    this.timeAgo,
    DateTime? timestamp,
    this.data,
  }) : timestamp = timestamp ?? _parseTimestamp(createdAt);

  String get type => module.isNotEmpty ? module : 'general';

  static DateTime _parseTimestamp(String? dateStr) {
    if (dateStr != null && dateStr.isNotEmpty) {
      final parsed = DateTime.tryParse(dateStr);
      if (parsed != null) return parsed.toLocal();
    }
    return DateTime.now();
  }

  AppNotificationItem copyWith({
    dynamic id,
    String? module,
    String? title,
    String? body,
    bool? isRead,
    String? readAt,
    String? createdAt,
    String? timeAgo,
    DateTime? timestamp,
    Map<String, dynamic>? data,
  }) {
    return AppNotificationItem(
      id: id ?? this.id,
      module: module ?? this.module,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      timeAgo: timeAgo ?? this.timeAgo,
      timestamp: timestamp ?? this.timestamp,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'module': module,
      'title': title,
      'body': body,
      'is_read': isRead,
      'read_at': readAt,
      'created_at': createdAt ?? timestamp.toIso8601String(),
      'time_ago': timeAgo,
      'data': data,
    };
  }

  factory AppNotificationItem.fromJson(Map<String, dynamic> json) {
    final rawModule = (json['module'] ?? json['type'] ?? 'general').toString();
    final rawCreatedAt = json['created_at']?.toString() ?? json['timestamp']?.toString();

    DateTime parsedDt;
    if (rawCreatedAt != null && rawCreatedAt.isNotEmpty) {
      parsedDt = DateTime.tryParse(rawCreatedAt)?.toLocal() ?? DateTime.now();
    } else {
      parsedDt = DateTime.now();
    }

    return AppNotificationItem(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch,
      module: rawModule,
      title: json['title']?.toString() ?? 'Notification',
      body: json['body']?.toString() ?? '',
      isRead: json['is_read'] == true || json['isRead'] == true,
      readAt: json['read_at']?.toString(),
      createdAt: rawCreatedAt,
      timeAgo: json['time_ago']?.toString(),
      timestamp: parsedDt,
      data: json['data'] != null && json['data'] is Map
          ? Map<String, dynamic>.from(json['data'])
          : null,
    );
  }
}
