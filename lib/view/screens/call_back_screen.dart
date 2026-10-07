import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/callback_model.dart';
import '../../utils/app_error_formatter.dart';
import '../../utils/app_snackbar.dart';
import '../../view_models/get_x/callback_controller.dart';
import '../../view_models/get_x/unread_counter_controller.dart';
import 'callback_detail_screen.dart';

class CallBackScreen extends StatefulWidget {
  const CallBackScreen({super.key});

  @override
  State<CallBackScreen> createState() => _CallBackScreenState();
}

class _CallBackScreenState extends State<CallBackScreen> {
  final CallbackController _controller = Get.put(CallbackController());

  @override
  void initState() {
    super.initState();
    UnreadCounterController.to.clearCallback();
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
              Color(0xFFD1E9FF), // Vibrant Light Blue
              Color(0xFFE9D5FF), // Vibrant Light Purple
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
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C3E50), size: 22),
                      onPressed: () => Get.back(),
                      tooltip: 'Back',
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'CALLBACK REQUESTS',
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
                    const SizedBox(width: 48), // Spacer to balance back icon
                  ],
                ),
              ),

              // -------------------------------------------------
              // STATUS COUNTS & FILTER TABS
              // -------------------------------------------------
              Obx(() => _buildStatusFilterTabs()),

              const SizedBox(height: 10),

              // -------------------------------------------------
              // MAIN CONTENT LIST
              // -------------------------------------------------
              Expanded(
                child: Obx(() {
                  if (_controller.isLoading.value && _controller.callbackList.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF4E54C8)),
                    );
                  }

                  if (_controller.errorMessage.value.isNotEmpty && _controller.callbackList.isEmpty) {
                    final isNetErr = AppErrorFormatter.isNetworkError(_controller.errorMessage.value);
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isNetErr ? const Color(0xFFFFF7ED) : const Color(0xFFFEF2F2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isNetErr ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                                color: isNetErr ? const Color(0xFFEA580C) : const Color(0xFFD32F2F),
                                size: 54,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              isNetErr ? 'No Internet Connection' : 'Failed to load Callback Requests',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2C3E50),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _controller.errorMessage.value,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: const Color(0xFF64748B),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => _controller.fetchCallbacks(isRefresh: true),
                              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                              label: Text(
                                isNetErr ? 'Retry Connection' : 'Retry',
                                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4E54C8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (_controller.callbackList.isEmpty) {
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
                              child: const Icon(Icons.phone_callback_rounded, size: 50, color: Color(0xFF8B5CF6)),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Callback Requests Found',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2C3E50),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'There are currently no callback requests under this filter.',
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

                  return RefreshIndicator(
                    color: const Color(0xFF4E54C8),
                    onRefresh: () => _controller.fetchCallbacks(isRefresh: true),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      itemCount: _controller.callbackList.length,
                      itemBuilder: (context, index) {
                        final item = _controller.callbackList[index];
                        return _buildCallbackCard(context, item);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------
  // STATUS FILTER CHIPS WITH COUNTS
  // -------------------------------------------------
  Widget _buildStatusFilterTabs() {
    final counts = _controller.counts.value;
    final selected = _controller.selectedStatus.value;

    final tabs = [
      {'id': 'all', 'label': 'All', 'count': counts.all, 'color': const Color(0xFF4E54C8)},
      {'id': 'pending', 'label': 'Pending', 'count': counts.pending, 'color': const Color(0xFFD97706)},
      {'id': 'in_progress', 'label': 'In Progress', 'count': counts.inProgress, 'color': const Color(0xFF2563EB)},
      {'id': 'completed', 'label': 'Completed', 'count': counts.completedToday, 'color': const Color(0xFF059669)},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: tabs.map((tab) {
          final id = tab['id'] as String;
          final label = tab['label'] as String;
          final count = tab['count'] as int;
          final color = tab['color'] as Color;
          final isSelected = selected == id;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              showCheckmark: false,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withValues(alpha: 0.25) : color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$count',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : color,
                      ),
                    ),
                  ),
                ],
              ),
              selectedColor: color,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? color : Colors.white,
                  width: 1,
                ),
              ),
              elevation: isSelected ? 2 : 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              onSelected: (_) => _controller.filterByStatus(id),
            ),
          );
        }).toList(),
      ),
    );
  }

  // -------------------------------------------------
  // CALLBACK REQUEST ITEM CARD
  // -------------------------------------------------
  Widget _buildCallbackCard(BuildContext context, CallbackRequestItem item) {
    final status = (item.status ?? 'pending').toLowerCase();
    final parentName = item.parent?.name ?? 'Parent Name N/A';
    final parentMobile = item.parent?.mobile ?? '';
    final studentName = item.student?.name ?? 'Student Name N/A';
    final className = item.student?.className ?? '';
    final sectionName = item.student?.sectionName ?? '';
    final rollNo = item.student?.rollNo ?? '';
    final reason = (item.reason != null && item.reason!.isNotEmpty)
        ? item.reason!
        : (item.description != null && item.description!.isNotEmpty)
            ? item.description!
            : 'No reason provided';
    final description = (item.description != null &&
            item.description!.isNotEmpty &&
            item.description != item.reason)
        ? item.description!
        : null;
    final timeAgo = item.timeAgo ?? item.requestedAt ?? '';
    final latestNotes = item.latestLog?.notes;

    final isCallDisabled = status == 'completed' || status == 'cancelled';

    Color statusBg;
    Color statusTextColor;
    BorderSide statusBorder;
    String statusDisplay;

    switch (status) {
      case 'in_progress':
        statusBg = const Color(0xFFEFF6FF);
        statusTextColor = const Color(0xFF2563EB);
        statusBorder = const BorderSide(color: Color(0xFFBFDBFE));
        statusDisplay = 'IN PROGRESS';
        break;
      case 'completed':
        statusBg = const Color(0xFFECFDF5);
        statusTextColor = const Color(0xFF059669);
        statusBorder = const BorderSide(color: Color(0xFFA7F3D0));
        statusDisplay = 'COMPLETED';
        break;
      case 'cancelled':
        statusBg = const Color(0xFFFEF2F2);
        statusTextColor = const Color(0xFFDC2626);
        statusBorder = const BorderSide(color: Color(0xFFFECACA));
        statusDisplay = 'CANCELLED';
        break;
      default:
        statusBg = const Color(0xFFFFFBEB);
        statusTextColor = const Color(0xFFD97706);
        statusBorder = const BorderSide(color: Color(0xFFFDE68A));
        statusDisplay = 'PENDING';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (item.id != null) {
              Get.to(() => CallbackDetailScreen(callbackId: item.id!));
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ----------------- Header: Status Badge & Time -----------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.fromBorderSide(statusBorder),
                      ),
                      child: Text(
                        statusDisplay,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusTextColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (timeAgo.isNotEmpty)
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                timeAgo,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // ----------------- Student Details -----------------
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.school_rounded, color: Color(0xFF8B5CF6), size: 22),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            studentName,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Class: $className${sectionName.isNotEmpty ? ' ($sectionName)' : ''}${rollNo.isNotEmpty && rollNo != 'N/A' ? ' | Roll: $rollNo' : ''}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                ),

                // ----------------- Parent Info & Call Action -----------------
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Parent / Guardian',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            parentName,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF334155),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (parentMobile.isNotEmpty) ...[
                            const SizedBox(height: 1),
                            Text(
                              '+91 $parentMobile',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (parentMobile.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: isCallDisabled ? null : () => _makePhoneCall(parentMobile),
                        icon: Icon(
                          Icons.call_rounded,
                          size: 16,
                          color: isCallDisabled ? const Color(0xFF94A3B8) : Colors.white,
                        ),
                        label: Text(
                          'Call',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isCallDisabled ? const Color(0xFF94A3B8) : Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCallDisabled ? const Color(0xFFE2E8F0) : const Color(0xFF10B981),
                          disabledBackgroundColor: const Color(0xFFE2E8F0),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 10),

                // ----------------- Reason & Description Container -----------------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: Color(0xFF4E54C8)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Reason for Callback:',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF4E54C8),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reason,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF334155),
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.description_outlined, size: 14, color: Color(0xFF0284C7)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Description:',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0284C7),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ],
                      if (latestNotes != null && latestNotes.isNotEmpty && latestNotes != "Callback requested by parent. Reason: $reason") ...[
                        const SizedBox(height: 6),
                        Text(
                          'Notes: $latestNotes',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ----------------- Action Buttons (Status change with equal width & confirmation) -----------------
                if (item.id != null)
                  Row(
                    children: [
                      if (status == 'pending') ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showStatusConfirmDialog(context, item.id!, 'in_progress'),
                            icon: const Icon(Icons.play_arrow_rounded, size: 16, color: Color(0xFF2563EB)),
                            label: Text(
                              'In Progress',
                              style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF2563EB), fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF2563EB)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        if (status != 'completed') const SizedBox(width: 10),
                      ],
                      if (status != 'completed')
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showStatusConfirmDialog(context, item.id!, 'completed'),
                            icon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: Colors.white),
                            label: Text(
                              'Mark Completed',
                              style: GoogleFonts.poppins(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showStatusConfirmDialog(BuildContext context, int callbackId, String newStatus) {
    final statusTitle = newStatus == 'completed' ? 'Completed' : 'In Progress';
    final themeColor = newStatus == 'completed' ? const Color(0xFF059669) : const Color(0xFF2563EB);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  newStatus == 'completed' ? Icons.check_circle_outline_rounded : Icons.play_arrow_rounded,
                  color: themeColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Confirm Action',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to mark this callback request as "$statusTitle"?',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF475569),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Obx(() => ElevatedButton(
                  onPressed: _controller.isUpdatingStatus.value
                      ? null
                      : () async {
                          final success = await _controller.updateStatus(callbackId, newStatus);
                          if (success && dialogCtx.mounted) {
                            Navigator.pop(dialogCtx);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _controller.isUpdatingStatus.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Confirm',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                )),
          ],
        );
      },
    );
  }

  Future<void> _makePhoneCall(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (clean.isEmpty) return;
    final url = Uri.parse('tel:$clean');
    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        AppSnackbar.showError(
          title: 'Dialer Error',
          message: 'Could not open phone dialer for $phone',
        );
      }
    } catch (e) {
      AppSnackbar.showError(
        title: 'Dialer Error',
        message: 'Could not open phone dialer for $phone',
      );
    }
  }
}
