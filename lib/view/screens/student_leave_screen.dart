import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/student_leave_model.dart';
import '../../utils/app_error_formatter.dart';
import '../../utils/app_snackbar.dart';
import '../../view_models/get_x/student_leave_controller.dart';
import '../../view_models/get_x/unread_counter_controller.dart';

class StudentLeaveScreen extends StatefulWidget {
  const StudentLeaveScreen({super.key});

  @override
  State<StudentLeaveScreen> createState() => _StudentLeaveScreenState();
}

class _StudentLeaveScreenState extends State<StudentLeaveScreen> {
  final StudentLeaveController _controller = Get.put(StudentLeaveController());

  @override
  void initState() {
    super.initState();
    UnreadCounterController.to.clearStudentLeave();
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    IconButton(
                      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C3E50), size: 18),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 2,
                        shadowColor: Colors.black12,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => Get.back(),
                      tooltip: 'Back',
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'STUDENTS LEAVE',
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
              // TOP SUMMARY OVERVIEW CARD
              // -------------------------------------------------
              Obx(() => _buildSummaryCard()),

              const SizedBox(height: 6),

              // -------------------------------------------------
              // STATUS FILTER BUTTONS (REDUCED RADIUS & DISTINCT COLORS)
              // -------------------------------------------------
              Obx(() => _buildStatusFilterTabs()),

              const SizedBox(height: 6),

              // -------------------------------------------------
              // MAIN LIST / STATES
              // -------------------------------------------------
              Expanded(
                child: Obx(() {
                  if (_controller.isLoading.value && _controller.leavesList.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFFE11D48)),
                    );
                  }

                  if (_controller.errorMessage.value.isNotEmpty && _controller.leavesList.isEmpty) {
                    final isNetErr = AppErrorFormatter.isNetworkError(_controller.errorMessage.value);
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: isNetErr ? const Color(0xFFFFF7ED) : const Color(0xFFFEF2F2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isNetErr ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                                color: isNetErr ? const Color(0xFFEA580C) : const Color(0xFFD32F2F),
                                size: 48,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              isNetErr ? 'No Internet Connection' : 'Oops! Something went wrong',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2C3E50),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _controller.errorMessage.value,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 18),
                            ElevatedButton.icon(
                              onPressed: () => _controller.fetchStudentLeaves(),
                              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                              label: Text('Retry', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE11D48),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final list = _controller.filteredLeaves;

                  if (list.isEmpty) {
                    return Center(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFF1F2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.event_busy_rounded,
                                color: Color(0xFFE11D48),
                                size: 42,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No Student Leaves Found',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'There are no leave requests under this category.',
                              style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: const Color(0xFFE11D48),
                    onRefresh: () async => _controller.fetchStudentLeaves(isManualRefresh: true),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 6, 12, 20),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return _buildStudentLeaveCard(list[index]);
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

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(
            label: 'Pending',
            count: _controller.pendingCount,
            color: const Color(0xFFD97706),
            bgColor: const Color(0xFFFFFBEB),
            icon: Icons.hourglass_top_rounded,
          ),
          _buildStatDivider(),
          _buildStatItem(
            label: 'Approved',
            count: _controller.approvedCount,
            color: const Color(0xFF059669),
            bgColor: const Color(0xFFECFDF5),
            icon: Icons.check_circle_rounded,
          ),
          _buildStatDivider(),
          _buildStatItem(
            label: 'Rejected',
            count: _controller.rejectedCount,
            color: const Color(0xFFDC2626),
            bgColor: const Color(0xFFFEF2F2),
            icon: Icons.cancel_rounded,
          ),
          _buildStatDivider(),
          _buildStatItem(
            label: 'Total',
            count: _controller.totalCount,
            color: const Color(0xFF2563EB),
            bgColor: const Color(0xFFEFF6FF),
            icon: Icons.assignment_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required int count,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 5),
              Text(
                '$count',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 24,
      width: 1,
      color: const Color(0xFFE2E8F0),
      margin: const EdgeInsets.symmetric(horizontal: 2),
    );
  }

  Widget _buildStatusFilterTabs() {
    final filters = [
      {
        'label': 'Pending',
        'key': 'pending',
        'count': _controller.pendingCount,
        'color': const Color(0xFFD97706),
        'bgColor': const Color(0xFFFFFBEB),
      },
      {
        'label': 'Approved',
        'key': 'approved',
        'count': _controller.approvedCount,
        'color': const Color(0xFF059669),
        'bgColor': const Color(0xFFECFDF5),
      },
      {
        'label': 'Rejected',
        'key': 'rejected',
        'count': _controller.rejectedCount,
        'color': const Color(0xFFDC2626),
        'bgColor': const Color(0xFFFEF2F2),
      },
      {
        'label': 'All',
        'key': 'all',
        'count': _controller.totalCount,
        'color': const Color(0xFF2563EB),
        'bgColor': const Color(0xFFEFF6FF),
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: Row(
        children: filters.map((f) {
          final label = f['label'] as String;
          final key = f['key'] as String;
          final count = f['count'] as int;
          final color = f['color'] as Color;
          final bgColor = f['bgColor'] as Color;
          final isSelected = _controller.selectedStatusFilter.value == key;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              showCheckmark: false,
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? Colors.white : color,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withValues(alpha: 0.28) : bgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$count',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
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
                borderRadius: BorderRadius.circular(8), // Reduced radius as requested
                side: BorderSide(
                  color: isSelected ? color : color.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              onSelected: (_) => _controller.changeStatusFilter(key),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStudentLeaveCard(StudentLeaveItem leave) {
    Color statusBg;
    Color statusColor;
    IconData statusIcon;

    switch (leave.status.toLowerCase()) {
      case 'approved':
        statusBg = const Color(0xFFECFDF5);
        statusColor = const Color(0xFF059669);
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'rejected':
        statusBg = const Color(0xFFFEF2F2);
        statusColor = const Color(0xFFDC2626);
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusBg = const Color(0xFFFFFBEB);
        statusColor = const Color(0xFFD97706);
        statusIcon = Icons.hourglass_top_rounded;
    }

    final isPending = leave.status.toLowerCase() == 'pending';
    final canApprove = _controller.canApprove.value || isPending;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Avatar, Student Info & Status Label
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFFFE4E6),
                  child: Text(
                    leave.studentName.isNotEmpty ? leave.studentName[0].toUpperCase() : 'S',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFE11D48),
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        leave.studentName,
                        softWrap: true,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              leave.fullClassSection,
                              softWrap: true,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                          ),
                          if (leave.rollNo != null && leave.rollNo!.isNotEmpty)
                            Text(
                              'Roll No: ${leave.rollNo}',
                              softWrap: true,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          if (leave.admissionNumber != null && leave.admissionNumber!.isNotEmpty)
                            Text(
                              'Adm No: ${leave.admissionNumber}',
                              softWrap: true,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 11, color: statusColor),
                      const SizedBox(width: 3),
                      Text(
                        leave.statusLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),

            // Middle Row: Day Type & Dates (Text wraps cleanly)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildDetailTile(
                    icon: leave.dayType == 'full_day' ? Icons.wb_sunny_rounded : Icons.access_time_rounded,
                    label: 'Leave Type',
                    value: leave.dayTypeLabel,
                    subtitle: leave.dayType == 'half_day' &&
                            leave.halfDayStartTime != null &&
                            leave.halfDayEndTime != null
                        ? '${leave.halfDayStartTime} - ${leave.halfDayEndTime}'
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDetailTile(
                    icon: Icons.calendar_month_rounded,
                    label: 'Duration',
                    value: leave.fromDateFormatted == leave.toDateFormatted
                        ? leave.fromDateFormatted
                        : '${leave.fromDateFormatted} - ${leave.toDateFormatted}',
                    subtitle: '${leave.totalDays} Day${leave.totalDays > 1 ? 's' : ''}',
                  ),
                ),
              ],
            ),

            if (leave.reason != null && leave.reason!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reason for Leave:',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      leave.reason!,
                      softWrap: true,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (leave.attachmentUrl != null && leave.attachmentUrl!.isNotEmpty) ...[
              const SizedBox(height: 6),
              InkWell(
                onTap: () => _launchAttachmentUrl(leave.attachmentUrl!),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.attach_file_rounded, size: 13, color: Color(0xFF2563EB)),
                      const SizedBox(width: 4),
                      Text(
                        'View Attachment',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Action Details (if rejected or approved)
            if (leave.actionByName != null && leave.actionByName!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: leave.status.toLowerCase() == 'approved'
                      ? const Color(0xFFF0FDF4)
                      : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Action by: ${leave.actionByName}${leave.actionByRole != null ? ' (${leave.actionByRole})' : ''}',
                      softWrap: true,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: leave.status.toLowerCase() == 'approved'
                            ? const Color(0xFF166534)
                            : const Color(0xFF991B1B),
                      ),
                    ),
                    if (leave.rejectionReason != null && leave.rejectionReason!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Rejection Reason: ${leave.rejectionReason}',
                        softWrap: true,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: const Color(0xFFDC2626),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (leave.approverRemarks != null && leave.approverRemarks!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Remarks: ${leave.approverRemarks}',
                        softWrap: true,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: const Color(0xFF059669),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (leave.actionAt != null && leave.actionAt!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Time: ${leave.actionAt}',
                        softWrap: true,
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Action Buttons for Pending Status
            if (isPending && canApprove) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showRejectDialog(leave),
                      icon: const Icon(Icons.close_rounded, size: 14, color: Color(0xFFDC2626)),
                      label: Text(
                        'Reject',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFECACA)),
                        backgroundColor: const Color(0xFFFEF2F2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showApproveDialog(leave),
                      icon: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                      label: Text(
                        'Approve',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF64748B)),
        const SizedBox(width: 5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFF64748B)),
              ),
              Text(
                value,
                softWrap: true,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  softWrap: true,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2563EB),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _showApproveDialog(StudentLeaveItem leave) {
    final remarkCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Approve Leave',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
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
                'Are you sure you want to approve leave for ${leave.studentName} (${leave.fullClassSection})?',
                softWrap: true,
                style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF475569)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: remarkCtrl,
                maxLines: 2,
                style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF1E293B)),
                decoration: InputDecoration(
                  hintText: 'Enter approver remarks (optional)...',
                  hintStyle: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
            ),
          ),
          Obx(() => ElevatedButton(
                onPressed: _controller.isActionLoading.value
                    ? null
                    : () async {
                        Navigator.pop(ctx);
                        await _controller.approveLeave(
                          leave.id,
                          remarks: remarkCtrl.text.trim().isNotEmpty ? remarkCtrl.text.trim() : null,
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                child: _controller.isActionLoading.value
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'Approve Leave',
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
              )),
        ],
      ),
    );
  }

  void _showRejectDialog(StudentLeaveItem leave) {
    final remarkCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Reject Leave Request',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
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
                'Enter rejection reason for ${leave.studentName}:',
                softWrap: true,
                style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF475569)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: remarkCtrl,
                maxLines: 2,
                style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF1E293B)),
                decoration: InputDecoration(
                  hintText: 'Enter rejection reason (required)...',
                  hintStyle: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
            ),
          ),
          Obx(() => ElevatedButton(
                onPressed: _controller.isActionLoading.value
                    ? null
                    : () async {
                        final reason = remarkCtrl.text.trim();
                        if (reason.isEmpty) {
                          AppSnackbar.showError(
                            title: 'Reason Required',
                            message: 'Please enter a rejection reason.',
                          );
                          return;
                        }
                        Navigator.pop(ctx);
                        await _controller.rejectLeave(leave.id, reason: reason);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                child: _controller.isActionLoading.value
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'Reject Leave',
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
              )),
        ],
      ),
    );
  }

  Future<void> _launchAttachmentUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        AppSnackbar.showError(
          title: 'Attachment Error',
          message: 'Could not open attachment link.',
        );
      }
    } catch (_) {
      AppSnackbar.showError(
        title: 'Attachment Error',
        message: 'Could not open attachment link.',
      );
    }
  }
}
