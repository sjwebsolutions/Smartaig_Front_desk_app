import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../models/notification_model.dart';
import '../../services/notification_api_service.dart';

class NotificationHistoryController extends GetxController {
  static NotificationHistoryController get to {
    if (Get.isRegistered<NotificationHistoryController>()) {
      return Get.find<NotificationHistoryController>();
    }
    return Get.put(NotificationHistoryController(), permanent: true);
  }

  final NotificationApiService _apiService = NotificationApiService();

  var notifications = <AppNotificationItem>[].obs;
  var isLoading = false.obs;
  var isMoreLoading = false.obs;
  var errorMessage = ''.obs;

  var currentPage = 1.obs;
  var lastPage = 1.obs;
  var hasMore = false.obs;
  var retentionDays = 7.obs;
  var selectedModule = 'all'.obs;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  /// Fetches notifications from backend API
  Future<void> fetchNotifications({
    bool isRefresh = false,
    String? module,
  }) async {
    if (module != null) {
      selectedModule.value = module;
    }

    if (isRefresh || module != null) {
      currentPage.value = 1;
      hasMore.value = false;
    }

    if (notifications.isEmpty || isRefresh || module != null) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final response = await _apiService.fetchNotifications(
        page: currentPage.value,
        module: selectedModule.value == 'all' ? null : selectedModule.value,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        retentionDays.value = data.retentionDays;

        if (currentPage.value == 1) {
          notifications.assignAll(data.notifications);
        } else {
          notifications.addAll(data.notifications);
        }

        if (data.pagination != null) {
          currentPage.value = data.pagination!.currentPage;
          lastPage.value = data.pagination!.lastPage;
          hasMore.value = data.pagination!.hasMore;
        } else {
          hasMore.value = false;
        }

        debugPrint(
          '🔔 [NotificationHistoryController] Loaded ${data.notifications.length} notifications (Total: ${notifications.length})',
        );
      } else {
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Failed to load notifications.';
      }
    } catch (e) {
      debugPrint('⚠️ [NotificationHistoryController Error]: $e');
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Loads the next page of notifications when user scrolls to bottom
  Future<void> loadMoreNotifications() async {
    if (!hasMore.value || isMoreLoading.value || isLoading.value) return;

    isMoreLoading.value = true;
    currentPage.value++;

    try {
      final response = await _apiService.fetchNotifications(
        page: currentPage.value,
        module: selectedModule.value == 'all' ? null : selectedModule.value,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        notifications.addAll(data.notifications);

        if (data.pagination != null) {
          currentPage.value = data.pagination!.currentPage;
          lastPage.value = data.pagination!.lastPage;
          hasMore.value = data.pagination!.hasMore;
        } else {
          hasMore.value = false;
        }
      }
    } catch (e) {
      debugPrint('⚠️ [NotificationHistoryController LoadMore Error]: $e');
      currentPage.value--;
    } finally {
      isMoreLoading.value = false;
    }
  }

  /// Manually add a notification locally (e.g. test notification)
  void addNotification({
    required String title,
    required String body,
    String type = 'general',
    Map<String, dynamic>? data,
  }) {
    final newItem = AppNotificationItem(
      id: DateTime.now().millisecondsSinceEpoch,
      module: type,
      title: title,
      body: body,
      timestamp: DateTime.now(),
      createdAt: DateTime.now().toIso8601String(),
      timeAgo: 'Just now',
      isRead: false,
      data: data,
    );

    notifications.insert(0, newItem);
    notifications.refresh();
  }

  /// Marks a specific notification as read in current state
  void markAsRead(dynamic id) {
    final index = notifications.indexWhere((n) => n.id.toString() == id.toString());
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      notifications.refresh();
    }
  }

  /// Marks all loaded notifications as read in state
  void markAllAsRead() {
    for (int i = 0; i < notifications.length; i++) {
      notifications[i] = notifications[i].copyWith(isRead: true);
    }
    notifications.refresh();
  }

  /// Clears notifications from state
  void clearAll() {
    notifications.clear();
  }
}
