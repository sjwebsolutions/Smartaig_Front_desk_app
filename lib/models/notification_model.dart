class AppNotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String type; // 'callback', 'gate_pass', 'visitor', 'general'
  final bool isRead;
  final Map<String, dynamic>? data;

  AppNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.type = 'general',
    this.isRead = false,
    this.data,
  });

  AppNotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    String? type,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return AppNotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'isRead': isRead,
      'data': data,
    };
  }

  factory AppNotificationItem.fromJson(Map<String, dynamic> json) {
    return AppNotificationItem(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title']?.toString() ?? 'Notification',
      body: json['body']?.toString() ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      type: json['type']?.toString() ?? 'general',
      isRead: json['isRead'] == true,
      data: json['data'] != null && json['data'] is Map
          ? Map<String, dynamic>.from(json['data'])
          : null,
    );
  }
}
