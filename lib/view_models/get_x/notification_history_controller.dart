import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/notification_model.dart';

class NotificationHistoryController extends GetxController {
  static NotificationHistoryController get to {
    if (Get.isRegistered<NotificationHistoryController>()) {
      return Get.find<NotificationHistoryController>();
    }
    return Get.put(NotificationHistoryController(), permanent: true);
  }

  static const String _storageKey = 'saved_app_notifications';
  var notifications = <AppNotificationItem>[].obs;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        final list = decoded
            .map((item) => AppNotificationItem.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        notifications.assignAll(list);
        debugPrint('🔔 [NotificationHistoryController] Loaded ${notifications.length} notifications ($unreadCount unread)');
      }
    } catch (e) {
      debugPrint('⚠️ [NotificationHistoryController Load Error]: $e');
    }
  }

  Future<void> addNotification({
    required String title,
    required String body,
    String type = 'general',
    Map<String, dynamic>? data,
  }) async {
    final newItem = AppNotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: type,
      isRead: false,
      data: data,
    );

    notifications.insert(0, newItem);
    await _saveToStorage();
    debugPrint('🔔 [NotificationHistoryController] Added new notification: "$title"');
  }

  Future<void> markAsRead(String id) async {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      notifications.refresh();
      await _saveToStorage();
    }
  }

  Future<void> markAllAsRead() async {
    for (int i = 0; i < notifications.length; i++) {
      notifications[i] = notifications[i].copyWith(isRead: true);
    }
    notifications.refresh();
    await _saveToStorage();
  }

  Future<void> clearAll() async {
    notifications.clear();
    await _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonStr = jsonEncode(notifications.map((n) => n.toJson()).toList());
      await prefs.setString(_storageKey, jsonStr);
    } catch (e) {
      debugPrint('⚠️ [NotificationHistoryController Save Error]: $e');
    }
  }
}
