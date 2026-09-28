import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import '../../view_models/get_x/notification_history_controller.dart';
import '../../view_models/get_x/unread_counter_controller.dart';
import 'call_back_screen.dart';
import 'callback_detail_screen.dart';
import 'get_pass_screen.dart';
import 'visitors_screen.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  final NotificationHistoryController _historyController =
      Get.put(NotificationHistoryController());

  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    // Automatically mark all notifications as read when the screen is viewed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _historyController.markAllAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFD1E9FF), // Light Blue
              Color(0xFFE9D5FF), // Light Purple
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // -------------------------------------------------
              // TOP APP BAR
              // -------------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF2C3E50), size: 22),
                      onPressed: () => Get.back(),
                      tooltip: 'Back',
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'NOTIFICATIONS',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C3E50),
                            letterSpacing: 1.1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balances the back button on left
                  ],
                ),
              ),

              // -------------------------------------------------
              // FILTER TABS
              // -------------------------------------------------
              _buildFilterTabs(),

              const SizedBox(height: 10),

              // -------------------------------------------------
              // NOTIFICATION LIST
              // -------------------------------------------------
              Expanded(
                child: Obx(() {
                  final allList = _historyController.notifications;
                  final filteredList = allList.where((item) {
                    final resolvedType = (item.type == 'gate_pass' ||
                            item.type == 'visitor' ||
                            item.type == 'callback')
                        ? item.type
                        : detectNotificationCategory(
                            data: item.data,
                            title: item.title,
                            body: item.body,
                          );
                    if (_selectedFilter == 'all') return true;
                    if (_selectedFilter == 'callback') return resolvedType == 'callback';
                    if (_selectedFilter == 'gate_pass') return resolvedType == 'gate_pass';
                    if (_selectedFilter == 'visitor') return resolvedType == 'visitor';
                    return true;
                  }).toList();

                  if (filteredList.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.notifications_none_rounded,
                                  size: 50, color: Color(0xFF4E54C8)),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Notifications Yet',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2C3E50),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Incoming push notifications for Callback, Gate Pass, and Visitors will appear here.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return _buildNotificationCard(item);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    final tabs = [
      {'id': 'all', 'label': 'All'},
      {'id': 'callback', 'label': 'Callbacks'},
      {'id': 'gate_pass', 'label': 'Gate Pass'},
      {'id': 'visitor', 'label': 'Visitors'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        children: tabs.map((tab) {
          final id = tab['id']!;
          final label = tab['label']!;
          final isSelected = _selectedFilter == id;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              showCheckmark: false,
              label: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF334155),
                ),
              ),
              selectedColor: const Color(0xFF4E54C8),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF4E54C8) : Colors.white,
                  width: 1,
                ),
              ),
              elevation: isSelected ? 2 : 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              onSelected: (_) {
                setState(() {
                  _selectedFilter = id;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationCard(AppNotificationItem item) {
    final resolvedType = (item.type == 'gate_pass' ||
            item.type == 'visitor' ||
            item.type == 'callback')
        ? item.type
        : detectNotificationCategory(
            data: item.data,
            title: item.title,
            body: item.body,
          );

    IconData icon;
    Color iconColor;
    Color iconBg;
    String categoryLabel;

    switch (resolvedType) {
      case 'gate_pass':
        icon = Icons.badge_outlined;
        iconColor = const Color(0xFF0D9488);
        iconBg = const Color(0xFFCCFBF1);
        categoryLabel = 'GATE PASS';
        break;
      case 'visitor':
        icon = Icons.people_alt_rounded;
        iconColor = const Color(0xFF2563EB);
        iconBg = const Color(0xFFEFF6FF);
        categoryLabel = 'VISITOR';
        break;
      case 'callback':
        icon = Icons.phone_callback_rounded;
        iconColor = const Color(0xFFDC2626);
        iconBg = const Color(0xFFFEF2F2);
        categoryLabel = 'CALLBACK';
        break;
      default:
        icon = Icons.notifications_active_rounded;
        iconColor = const Color(0xFF4E54C8);
        iconBg = const Color(0xFFEEF2FF);
        categoryLabel = 'GENERAL';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: item.isRead ? Colors.white : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.isRead ? const Color(0xFFE2E8F0) : iconColor.withValues(alpha: 0.3),
          width: item.isRead ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _historyController.markAsRead(item.id);
            _navigateToTarget(item);
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: iconBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              categoryLabel,
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: iconColor,
                              ),
                            ),
                          ),
                          Text(
                            _formatTimeAgo(item.timestamp),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      if (item.body.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.body,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!item.isRead) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToTarget(AppNotificationItem item) {
    _historyController.markAsRead(item.id);
    final data = item.data;

    if (item.type == 'gate_pass') {
      UnreadCounterController.to.clearGatePass();
      Get.to(() => const GetPassScreen());
    } else if (item.type == 'visitor') {
      UnreadCounterController.to.clearVisitor();
      Get.to(() => const VisitorsScreen());
    } else if (item.type == 'callback') {
      UnreadCounterController.to.clearCallback();
      final callbackIdStr = data?['callback_id'] ?? data?['id'];
      if (callbackIdStr != null && int.tryParse(callbackIdStr.toString()) != null) {
        final callbackId = int.parse(callbackIdStr.toString());
        Get.to(() => CallbackDetailScreen(callbackId: callbackId));
      } else {
        Get.to(() => const CallBackScreen());
      }
    } else {
      Get.to(() => const CallBackScreen());
    }
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }
}
