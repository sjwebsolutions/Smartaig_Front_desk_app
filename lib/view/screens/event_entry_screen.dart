import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/active_event_model.dart';
import '../../models/event_scan_model.dart';
import '../../utils/app_error_formatter.dart';
import '../../utils/app_snackbar.dart';
import '../../view_models/get_x/active_event_controller.dart';
import '../../view_models/get_x/event_scan_controller.dart';

import 'create_event_pass_screen.dart';

class EventEntryScreen extends StatefulWidget {
  const EventEntryScreen({super.key});

  @override
  State<EventEntryScreen> createState() => _EventEntryScreenState();
}

class _EventEntryScreenState extends State<EventEntryScreen> with TickerProviderStateMixin {
  final ActiveEventController _activeEventController = Get.put(ActiveEventController());
  final EventScanController _eventScanController = Get.put(EventScanController());

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _eventScanController.fetchPassApplications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showUpdateStatusDialog(PassApplicationItem item, {String action = 'approve'}) {
    final remarksCtrl = TextEditingController(
      text: action == 'approve' ? 'Approved by Gate In-Charge' : 'Rejected by Gate In-Charge',
    );
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          action == 'approve' ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          color: action == 'approve' ? const Color(0xFF059669) : const Color(0xFFDC2626),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Update Pass Status',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pass No: ${item.passNumber ?? "N/A"} • Student: ${item.student?.name ?? "N/A"}',
                      style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 14),
                    Text('Remarks', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: remarksCtrl,
                      enabled: !isSubmitting,
                      style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF1E293B)),
                      decoration: InputDecoration(
                        hintText: 'Enter approval or rejection remarks',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(
                              'CANCEL',
                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF64748B)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    setDialogState(() {
                                      isSubmitting = true;
                                    });
                                    try {
                                      HapticFeedback.mediumImpact();
                                      final res = await _eventScanController.updatePassStatus(
                                        passId: item.id,
                                        action: action,
                                        remarks: remarksCtrl.text.trim(),
                                      );
                                      if (ctx.mounted) Navigator.pop(ctx);
                                      if (action == 'approve') {
                                        AppSnackbar.showSuccess(
                                          title: 'Pass Approved',
                                          message: res.message ?? 'Pass status updated to approved.',
                                        );
                                      } else {
                                        AppSnackbar.showWarning(
                                          title: 'Pass Rejected',
                                          message: res.message ?? 'Pass status updated to rejected.',
                                        );
                                      }
                                    } catch (e) {
                                      if (ctx.mounted) {
                                        setDialogState(() {
                                          isSubmitting = false;
                                        });
                                      }
                                      AppSnackbar.showError(
                                        title: 'Update Failed',
                                        message: AppErrorFormatter.format(e),
                                      );
                                    }
                                  },
                            icon: isSubmitting
                                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Icon(
                                    action == 'approve' ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                            label: Text(
                              isSubmitting
                                  ? (action == 'approve' ? 'APPROVING...' : 'REJECTING...')
                                  : (action == 'approve' ? 'APPROVE' : 'REJECT'),
                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: action == 'approve' ? const Color(0xFF059669) : const Color(0xFFDC2626),
                              disabledBackgroundColor: (action == 'approve' ? const Color(0xFF059669) : const Color(0xFFDC2626)).withValues(alpha: 0.6),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFE9D5FF),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        floatingActionButton: _tabController.index == 1
            ? FloatingActionButton.extended(
                backgroundColor: const Color(0xFF4E54C8),
                elevation: 4,
                icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                label: Text(
                  'Create Pass',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                onPressed: () {
                  final events = _activeEventController.activeEvents;
                  final eventId = events.isNotEmpty ? events.first.id : '1';
                  final eventTitle = events.isNotEmpty ? events.first.title : 'Active Event';
                  Get.to(() => CreateEventPassScreen(eventId: eventId, eventTitle: eventTitle));
                },
              )
            : null,
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
                            'EVENT ENTRY',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2C3E50),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 30),
                    ],
                  ),
                ),

                // -------------------------------------------------
                // TAB BAR HEADER (ACTIVE EVENT & PASS APPLICATION)
                // -------------------------------------------------
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: const Color(0xFF4E54C8),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4E54C8).withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: const Color(0xFF64748B),
                    labelStyle: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.bold),
                    unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_rounded, size: 16),
                            SizedBox(width: 6),
                            Text('Active Event'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.badge_rounded, size: 16),
                            SizedBox(width: 6),
                            Text('Pass Application'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // -------------------------------------------------
                // TAB BAR VIEW CONTENT
                // -------------------------------------------------
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // TAB 1: ACTIVE EVENT LIST
                      _buildActiveEventsTab(),

                      // TAB 2: PASS APPLICATION
                      _buildPassApplicationTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // TAB 2: PASS APPLICATION TAB (/events/passes/applications)
  // =========================================================
  Widget _buildPassApplicationTab() {
    return RefreshIndicator(
      color: const Color(0xFF4E54C8),
      onRefresh: () => _eventScanController.fetchPassApplications(isManualRefresh: true),
      child: Obx(() {
        if (_eventScanController.isLoadingApplications.value && _eventScanController.passApplications.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF4E54C8)),
          );
        }

        if (_eventScanController.passApplicationsError.value.isNotEmpty && _eventScanController.passApplications.isEmpty) {
          final isNetErr = AppErrorFormatter.isNetworkError(_eventScanController.passApplicationsError.value);
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
                  const SizedBox(height: 16),
                  Text(
                    isNetErr ? 'No Internet Connection' : 'Failed to Load Pass Applications',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E50),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _eventScanController.passApplicationsError.value,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _eventScanController.fetchPassApplications(isManualRefresh: true),
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                    label: Text('Retry', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
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

        final list = _eventScanController.passApplications;

        if (list.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.badge_outlined, color: Color(0xFF94A3B8), size: 52),
                    const SizedBox(height: 14),
                    Text(
                      'No Pass Applications Found',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'There are no pass applications recorded for this event.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          itemCount: list.length,
          itemBuilder: (context, index) {
            return _buildPassApplicationItemCard(list[index]);
          },
        );
      }),
    );
  }

  Widget _buildPassApplicationItemCard(PassApplicationItem item) {
    final passNo = item.passNumber ?? 'N/A';
    final approvalStatus = (item.approvalStatus ?? 'pending').toLowerCase();
    final checkinStatus = (item.checkinStatus ?? 'pending').toLowerCase();
    final isApproved = approvalStatus == 'approved';
    final isCheckedIn = checkinStatus == 'all_entered' || checkinStatus == 'checked_in';

    final student = item.student;
    final attendees = item.attendees ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Pass No & Status Badges
          Row(
            children: [
              Expanded(
                child: Text(
                  passNo,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4E54C8),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              InkWell(
                onTap: () => _showUpdateStatusDialog(item),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: isApproved ? const Color(0xFFECFDF5) : const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isApproved ? const Color(0xFFA7F3D0) : const Color(0xFFFED7AA),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        (item.approvalStatus ?? 'PENDING').toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: isApproved ? const Color(0xFF059669) : const Color(0xFFD97706),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.edit_note_rounded,
                        size: 12,
                        color: isApproved ? const Color(0xFF059669) : const Color(0xFFD97706),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isCheckedIn ? const Color(0xFFEEF2FF) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isCheckedIn ? const Color(0xFFC7D2FE) : const Color(0xFFCBD5E1),
                  ),
                ),
                child: Text(
                  checkinStatus.replaceAll('_', ' ').toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: isCheckedIn ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          // Student Details Row
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 44,
                  height: 44,
                  color: const Color(0xFFEEF2FF),
                  child: student?.photoUrl != null && student!.photoUrl!.isNotEmpty
                      ? Image.network(
                          student.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => const Icon(Icons.person_rounded, color: Color(0xFF4E54C8), size: 24),
                        )
                      : const Icon(Icons.person_rounded, color: Color(0xFF4E54C8), size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student?.name ?? 'Student',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Class: ${student?.studentClass ?? ''} - ${student?.section ?? ''} • Adm: ${student?.admissionNumber ?? 'N/A'}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (item.createdAt != null && item.createdAt!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Created: ${item.createdAt}',
                    style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF64748B)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          if (item.actionByName != null && item.actionByName!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person_outline_rounded, size: 13, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Issued By: ${item.actionByName}${item.actionByRole != null && item.actionByRole!.isNotEmpty ? " (${item.actionByRole})" : ""}',
                    style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF475569), fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          if (item.adminRemarks != null && item.adminRemarks!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                'Remarks: ${item.adminRemarks}',
                style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF475569)),
              ),
            ),
          ],

          if (attendees.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: attendees.map((att) {
                final attCheckedIn = att.isCheckedIn == true;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: attCheckedIn ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        attCheckedIn ? Icons.check_circle_rounded : Icons.person_outline_rounded,
                        size: 12,
                        color: attCheckedIn ? const Color(0xFF059669) : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${att.name ?? "Attendee"} (${att.personType ?? ""})',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: attCheckedIn ? const Color(0xFF059669) : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 10),

          // Bottom Action Row: Reject & Approve Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showUpdateStatusDialog(item, action: 'reject'),
                  icon: const Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 16),
                  label: Text(
                    'REJECT',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFDC2626)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showUpdateStatusDialog(item, action: 'approve'),
                  icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                  label: Text(
                    'APPROVE',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================
  // TAB 1: ACTIVE EVENT TAB
  // =========================================================
  Widget _buildActiveEventsTab() {
    return RefreshIndicator(
      color: const Color(0xFF4E54C8),
      onRefresh: () => _activeEventController.fetchActiveEvents(isManualRefresh: true),
      child: Obx(() {
        if (_activeEventController.isLoading.value && _activeEventController.activeEvents.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF4E54C8)),
          );
        }

        if (_activeEventController.errorMessage.value.isNotEmpty && _activeEventController.activeEvents.isEmpty) {
          final isNetErr = AppErrorFormatter.isNetworkError(_activeEventController.errorMessage.value);
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
                  const SizedBox(height: 16),
                  Text(
                    isNetErr ? 'No Internet Connection' : 'Failed to Load Active Events',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E50),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _activeEventController.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _activeEventController.fetchActiveEvents(),
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                    label: Text('Retry', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
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

        final events = _activeEventController.activeEvents;

        if (events.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.event_busy_rounded, color: Color(0xFF94A3B8), size: 52),
                    const SizedBox(height: 14),
                    Text(
                      'No Active Events Right Now',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'There are no active events currently available for gate entry.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final item = events[index];
            return _buildActiveEventCard(item);
          },
        );
      }),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xFFE9D5FF),
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Dialog.fullscreen(
          backgroundColor: Colors.transparent,
          child: Scaffold(
            backgroundColor: Colors.transparent,
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
                    // Top App Bar
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
                            onPressed: () => Navigator.pop(ctx),
                            tooltip: 'Back',
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                'IMAGE PREVIEW',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2C3E50),
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 30),
                        ],
                      ),
                    ),

                    // Zoomable Image View
                    Expanded(
                      child: Center(
                        child: InteractiveViewer(
                          panEnabled: true,
                          minScale: 0.8,
                          maxScale: 4.0,
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) => const Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.broken_image_rounded, color: Color(0xFF64748B), size: 64),
                                  SizedBox(height: 12),
                                  Text('Failed to load image', style: TextStyle(color: Color(0xFF2C3E50), fontSize: 14)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bottom Hint Pill
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Pinch or double tap to zoom image',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF475569),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------
  // ACTIVE EVENT CARD (COMPACT HEIGHT)
  // -------------------------------------------------
  Widget _buildActiveEventCard(ActiveEventItem item) {
    final liveTelecast = item.liveTelecast;
    final isLive = liveTelecast?.isLive == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4E54C8).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFEEF2FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4E54C8),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          'ACTIVE EVENT',
                          style: GoogleFonts.poppins(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isLive ? const Color(0xFFFEF2F2) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: isLive ? const Color(0xFFFECACA) : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: isLive ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isLive ? 'LIVE' : 'OFFLINE',
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isLive ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.eventCode != null && item.eventCode!.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Text(
                      item.eventCode!,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Main Content Body
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Image Box (Clickable for Full Screen)
                    if (item.bannerUrl != null && item.bannerUrl!.isNotEmpty) ...[
                      GestureDetector(
                        onTap: () => _showFullScreenImage(context, item.bannerUrl!),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 68,
                                height: 68,
                                color: const Color(0xFF0F172A),
                                child: Image.network(
                                  item.bannerUrl!,
                                  width: 68,
                                  height: 68,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => Container(
                                    width: 68,
                                    height: 68,
                                    color: const Color(0xFFEEF2FF),
                                    child: const Center(
                                      child: Icon(Icons.event_rounded, color: Color(0xFF4E54C8), size: 28),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 3,
                              right: 3,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],

                    // Title & Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title ?? 'Event Title',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                              height: 1.2,
                            ),
                          ),
                          if (item.subTitle != null && item.subTitle!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.subTitle!,
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                color: const Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),

                // Key Information Grid (Compact)
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    if (item.venue != null && item.venue!.isNotEmpty)
                      _buildCompactInfoChip(
                        icon: Icons.location_on_rounded,
                        label: item.venue!,
                        color: const Color(0xFFEA580C),
                        bgColor: const Color(0xFFFFF7ED),
                      ),
                    if (item.startDate != null)
                      _buildCompactInfoChip(
                        icon: Icons.calendar_month_rounded,
                        label: '${item.startDate}${item.endDate != null ? " to ${item.endDate}" : ""}',
                        color: const Color(0xFF2563EB),
                        bgColor: const Color(0xFFEFF6FF),
                      ),
                    if (item.startTime != null)
                      _buildCompactInfoChip(
                        icon: Icons.access_time_rounded,
                        label: '${item.startTime}${item.endTime != null ? " - ${item.endTime}" : ""}',
                        color: const Color(0xFF059669),
                        bgColor: const Color(0xFFECFDF5),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // Event Rules Badges
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (item.maxGuestsPerStudent != null)
                      _buildRuleBadge(
                        icon: Icons.people_outline_rounded,
                        label: 'Max Guests: ${item.maxGuestsPerStudent}',
                        color: const Color(0xFF4F46E5),
                        bgColor: const Color(0xFFEEF2FF),
                      ),
                    _buildRuleBadge(
                      icon: item.requiresApproval == true ? Icons.verified_user_rounded : Icons.do_not_disturb_on_rounded,
                      label: item.requiresApproval == true ? 'Approval Req.' : 'No Approval',
                      color: item.requiresApproval == true ? const Color(0xFF059669) : const Color(0xFF64748B),
                      bgColor: item.requiresApproval == true ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                    ),
                    _buildRuleBadge(
                      icon: item.requirePhoto == true ? Icons.camera_alt_rounded : Icons.no_photography_rounded,
                      label: item.requirePhoto == true ? 'Photo Req.' : 'Photo Optional',
                      color: item.requirePhoto == true ? const Color(0xFF0284C7) : const Color(0xFF64748B),
                      bgColor: item.requirePhoto == true ? const Color(0xFFE0F2FE) : const Color(0xFFF1F5F9),
                    ),
                    _buildRuleBadge(
                      icon: item.requireAadhaar == true ? Icons.badge_rounded : Icons.credit_card_off_rounded,
                      label: item.requireAadhaar == true ? 'Aadhaar Req.' : 'Aadhaar Optional',
                      color: item.requireAadhaar == true ? const Color(0xFFD97706) : const Color(0xFFFFFBEB),
                      bgColor: item.requireAadhaar == true ? const Color(0xFFFFFBEB) : const Color(0xFFF1F5F9),
                    ),
                    _buildRuleBadge(
                      icon: item.allowMultipleCheckins == true ? Icons.repeat_rounded : Icons.looks_one_rounded,
                      label: item.allowMultipleCheckins == true ? 'Multi Check-in' : 'Single Check-in',
                      color: item.allowMultipleCheckins == true ? const Color(0xFF7C3AED) : const Color(0xFF64748B),
                      bgColor: item.allowMultipleCheckins == true ? const Color(0xFFF3E8FF) : const Color(0xFFF1F5F9),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactInfoChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleBadge({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
