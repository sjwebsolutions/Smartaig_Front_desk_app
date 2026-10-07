import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_error_formatter.dart';
import '../../utils/app_snackbar.dart';
import '../../view_models/get_x/callback_controller.dart';

class CallbackDetailScreen extends StatefulWidget {
  final int callbackId;

  const CallbackDetailScreen({
    super.key,
    required this.callbackId,
  });

  @override
  State<CallbackDetailScreen> createState() => _CallbackDetailScreenState();
}

class _CallbackDetailScreenState extends State<CallbackDetailScreen> {
  final CallbackController _controller = Get.find<CallbackController>();

  @override
  void initState() {
    super.initState();
    _controller.fetchCallbackDetail(widget.callbackId);
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
              // APP BAR
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
                          'CALLBACK DETAILS',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C3E50),
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Spacer to balance back icon
                  ],
                ),
              ),

              // -------------------------------------------------
              // BODY
              // -------------------------------------------------
              Expanded(
                child: Obx(() {
                  if (_controller.isDetailLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF4E54C8)),
                    );
                  }

                  if (_controller.detailErrorMessage.value.isNotEmpty) {
                    final isNetErr = AppErrorFormatter.isNetworkError(_controller.detailErrorMessage.value);
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
                              isNetErr ? 'No Internet Connection' : 'Failed to load details',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2C3E50),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _controller.detailErrorMessage.value,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: const Color(0xFF64748B),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => _controller.fetchCallbackDetail(widget.callbackId),
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

                  final detail = _controller.selectedDetail.value;
                  if (detail == null) {
                    return const Center(child: Text('No details available'));
                  }

                  final status = (detail.status ?? 'pending').toLowerCase();
                  final logs = detail.logs ?? [];
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

                  return RefreshIndicator(
                    color: const Color(0xFF4E54C8),
                    onRefresh: () async => _controller.fetchCallbackDetail(widget.callbackId),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ---------------- MAIN CARD ----------------
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top Status Header
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: statusBg,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.fromBorderSide(statusBorder),
                                      ),
                                      child: Text(
                                        statusDisplay,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: statusTextColor,
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        detail.timeAgo ?? detail.requestedAt ?? '',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF64748B),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Request ID tag
                                Text(
                                  'Request ID: #${detail.id}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),

                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                                ),

                                // Student Details Section
                                Text(
                                  'STUDENT INFORMATION',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF64748B),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF5F3FF),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.school_rounded, color: Color(0xFF8B5CF6), size: 24),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            detail.student?.name ?? 'N/A',
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF1E293B),
                                            ),
                                          ),
                                          Text(
                                            'Class ${detail.student?.className ?? ''} (${detail.student?.sectionName ?? ''}) | Roll: ${detail.student?.rollNo ?? 'N/A'}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: const Color(0xFF64748B),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                                ),

                                // Parent Details Section
                                Text(
                                  'PARENT INFORMATION',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF64748B),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            detail.parent?.name ?? 'N/A',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF334155),
                                            ),
                                          ),
                                          if (detail.parent?.mobile != null && detail.parent!.mobile!.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              '+91 ${detail.parent!.mobile!}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: const Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (detail.parent?.mobile != null && detail.parent!.mobile!.isNotEmpty)
                                      ElevatedButton.icon(
                                        onPressed: isCallDisabled ? null : () => _makePhoneCall(detail.parent!.mobile!),
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
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          elevation: 0,
                                        ),
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Reason & Description Container
                                Builder(
                                  builder: (context) {
                                    final detailReason = (detail.reason != null && detail.reason!.isNotEmpty)
                                        ? detail.reason!
                                        : (detail.description != null && detail.description!.isNotEmpty)
                                            ? detail.description!
                                            : 'No reason provided';
                                    final detailDesc = (detail.description != null &&
                                            detail.description!.isNotEmpty &&
                                            detail.description != detail.reason)
                                        ? detail.description
                                        : null;

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'REASON FOR CALLBACK',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF64748B),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFFBEB),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: const Color(0xFFFDE68A)),
                                          ),
                                          child: Text(
                                            detailReason,
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              color: const Color(0xFF92400E),
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                        if (detailDesc != null) ...[
                                          const SizedBox(height: 14),
                                          Text(
                                            'DESCRIPTION',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF64748B),
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF0F9FF),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: const Color(0xFFBAE6FD)),
                                            ),
                                            child: Text(
                                              detailDesc,
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: const Color(0xFF0369A1),
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ---------------- ACTIVITY LOGS TIMELINE HEADER & ADD NOTE BUTTON ----------------
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Activity Logs (${logs.length})',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E293B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () => _showAddNoteDialog(context, widget.callbackId),
                                icon: const Icon(Icons.edit_note_rounded, size: 18, color: Colors.white),
                                label: Text(
                                  'Log Note',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4F46E5),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          if (logs.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'No activity logs found for this request.',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: logs.length,
                              itemBuilder: (context, index) {
                                final log = logs[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.02),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEEF2FF),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              (log.action ?? 'Activity').toUpperCase(),
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF4F46E5),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            log.timeAgo ?? log.createdAt ?? '',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              color: const Color(0xFF94A3B8),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (log.callStatus != null && log.callStatus!.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.phone_in_talk_rounded, size: 14, color: Color(0xFF10B981)),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Call Status: ${log.callStatus!.replaceAll('_', ' ').capitalize}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF10B981),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      if (log.notes != null && log.notes!.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          log.notes!,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: const Color(0xFF334155),
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                      if (log.staffName != null && log.staffName!.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.person_outline_rounded, size: 14, color: Color(0xFF64748B)),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Logged by: ${log.staffName}${log.staffRole != null ? ' (${log.staffRole})' : ''}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: const Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),

                          const SizedBox(height: 20),

                          // ---------------- BOTTOM STATUS CHANGE ACTIONS (Equal Widths) ----------------
                          Row(
                            children: [
                              if (status == 'pending') ...[
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _showStatusConfirmDialog(context, widget.callbackId, 'in_progress'),
                                    icon: const Icon(Icons.play_arrow_rounded, color: Color(0xFF2563EB)),
                                    label: Text(
                                      'In Progress',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF2563EB),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      side: const BorderSide(color: Color(0xFF2563EB)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              if (status != 'completed')
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _showStatusConfirmDialog(context, widget.callbackId, 'completed'),
                                    icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                                    label: Text(
                                      'Mark Completed',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF059669),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
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

  void _showAddNoteDialog(BuildContext context, int callbackId) {
    String selectedCallStatus = 'connected';
    String? updateStatusTo;
    final notesController = TextEditingController();

    final callStatusOptions = [
      {'id': 'connected', 'label': 'Connected'},
      {'id': 'no_answer', 'label': 'No Answer'},
      {'id': 'busy', 'label': 'Busy'},
      {'id': 'call_back_later', 'label': 'Call Back Later'},
      {'id': 'wrong_number', 'label': 'Wrong Number'},
      {'id': 'other', 'label': 'Other'},
    ];

    final updateStatusOptions = [
      {'id': '', 'label': 'Do not change status'},
      {'id': 'in_progress', 'label': 'In Progress'},
      {'id': 'completed', 'label': 'Completed'},
      {'id': 'cancelled', 'label': 'Cancelled'},
    ];

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEF2FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit_note_rounded, color: Color(0xFF4F46E5), size: 22),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Log Call Note',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Call Status',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCallStatus,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: callStatusOptions.map((opt) {
                        return DropdownMenuItem<String>(
                          value: opt['id'],
                          child: Text(opt['label']!, style: GoogleFonts.poppins(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedCallStatus = val);
                        }
                      },
                    ),

                    const SizedBox(height: 14),

                    Text(
                      'Notes / Clarification *',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      style: GoogleFonts.poppins(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Enter call notes or parent clarification...',
                        hintStyle: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF94A3B8)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      'Update Request Status To (Optional)',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: updateStatusTo ?? '',
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: updateStatusOptions.map((opt) {
                        return DropdownMenuItem<String>(
                          value: opt['id'],
                          child: Text(opt['label']!, style: GoogleFonts.poppins(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setDialogState(() => updateStatusTo = (val == '' ? null : val));
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: Text('Cancel', style: GoogleFonts.poppins(color: const Color(0xFF64748B))),
                ),
                Obx(() => ElevatedButton(
                  onPressed: _controller.isStoringNote.value
                      ? null
                      : () async {
                          final text = notesController.text.trim();
                          if (text.isEmpty) {
                            AppSnackbar.showError(
                              title: 'Required',
                              message: 'Please enter call notes.',
                            );
                            return;
                          }
                          final success = await _controller.storeNote(
                            callbackId: callbackId,
                            notes: text,
                            callStatus: selectedCallStatus,
                            updateStatusTo: updateStatusTo,
                          );
                          if (success && dialogCtx.mounted) {
                            Navigator.pop(dialogCtx);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _controller.isStoringNote.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text('Submit Note', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                )),
              ],
            );
          },
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
