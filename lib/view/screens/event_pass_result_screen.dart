import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/event_scan_model.dart';
import '../../utils/app_error_formatter.dart';
import '../../utils/app_snackbar.dart';
import '../../view_models/get_x/event_scan_controller.dart';

class EventPassResultScreen extends StatefulWidget {
  final PassScanResultModel scanResult;
  final String passCode;

  const EventPassResultScreen({
    super.key,
    required this.scanResult,
    required this.passCode,
  });

  @override
  State<EventPassResultScreen> createState() => _EventPassResultScreenState();
}

class _EventPassResultScreenState extends State<EventPassResultScreen> {
  late final EventScanController _controller;

  final Set<dynamic> _alreadyCheckedInIds = {};
  final Set<dynamic> _selectedAttendeeIds = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<EventScanController>()) {
      _controller = Get.find<EventScanController>();
    } else {
      _controller = Get.put(EventScanController());
    }

    final approved = widget.scanResult.data?.approvedAttendees ?? [];
    for (var att in approved) {
      final key = att.id ?? att.name ?? att.hashCode;
      final bool hasCheckedInAt = att.checkedInAt != null &&
          att.checkedInAt!.trim().isNotEmpty &&
          att.checkedInAt!.trim().toLowerCase() != 'null';
      final isChecked = att.isCheckedIn == true || hasCheckedInAt;
      if (isChecked) {
        _alreadyCheckedInIds.add(key);
      }
    }
  }

  Future<void> _submitCheckIn() async {
    if (_selectedAttendeeIds.isEmpty || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final passId = widget.scanResult.data?.pass?.id;
      final passNo = widget.scanResult.data?.pass?.passNumber ?? widget.passCode;

      final approved = widget.scanResult.data?.approvedAttendees ?? [];
      final List<dynamic> idsToSubmit = [];
      for (var att in approved) {
        final key = att.id ?? att.name ?? att.hashCode;
        if (_selectedAttendeeIds.contains(key)) {
          idsToSubmit.add(att.id ?? key);
        }
      }

      final res = await _controller.checkInAttendees(
        passId: passId,
        passNumber: passNo,
        attendeeIds: idsToSubmit.isNotEmpty ? idsToSubmit : _selectedAttendeeIds.toList(),
      );

      if (mounted) {
        final successMsg = res.message ?? 'Admission successfully recorded for ${_selectedAttendeeIds.length} attendee(s).';
        AppSnackbar.showSuccess(
          title: 'Admission Recorded',
          message: successMsg,
        );

        setState(() {
          _alreadyCheckedInIds.addAll(_selectedAttendeeIds);
          _selectedAttendeeIds.clear();
        });

        _refreshPassData();
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(
          title: 'Check-In Failed',
          message: AppErrorFormatter.format(e),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _refreshPassData() async {
    try {
      final passNo = widget.scanResult.data?.pass?.passNumber ?? widget.passCode;
      final res = await _controller.scanEventPass(passNo);
      final updatedResult = PassScanResultModel.fromJson(res);
      if (mounted && updatedResult.data != null) {
        setState(() {
          final approved = updatedResult.data?.approvedAttendees ?? [];
          for (var att in approved) {
            final key = att.id ?? att.name ?? att.hashCode;
            final bool hasCheckedInAt = att.checkedInAt != null &&
                att.checkedInAt!.trim().isNotEmpty &&
                att.checkedInAt!.trim().toLowerCase() != 'null';
            final isChecked = att.isCheckedIn == true || hasCheckedInAt;
            if (isChecked) {
              _alreadyCheckedInIds.add(key);
            }
          }
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isAlreadyCheckedIn = widget.scanResult.isAlreadyCheckedIn == true;
    final isSuccess = widget.scanResult.success == true && !isAlreadyCheckedIn;

    final passInfo = widget.scanResult.data?.pass;
    final eventInfo = widget.scanResult.data?.event;
    final studentInfo = widget.scanResult.data?.student;
    final approvedAttendees = widget.scanResult.data?.approvedAttendees ?? [];

    final displayPassNo = passInfo?.passNumber ?? widget.passCode;

    final primaryColor = isAlreadyCheckedIn
        ? const Color(0xFFEA580C)
        : (isSuccess ? const Color(0xFF059669) : const Color(0xFF4F46E5));

    final headerBgColor = isAlreadyCheckedIn
        ? const Color(0xFFFFF7ED)
        : (isSuccess ? const Color(0xFFECFDF5) : const Color(0xFFEEF2FF));

    final headerIcon = isAlreadyCheckedIn
        ? Icons.history_rounded
        : (isSuccess ? Icons.check_circle_rounded : Icons.badge_rounded);

    final headerTitle = isAlreadyCheckedIn
        ? 'Pass Already Checked In'
        : (isSuccess ? 'Pass Verified' : 'Pass Details');

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFE9D5FF),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFD1E9FF),
                Color(0xFFE9D5FF),
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
                            'PASS RESULT',
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

                // -------------------------------------------------
                // MAIN ESSENTIAL CONTENT
                // -------------------------------------------------
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. TOP PASS STATUS HEADER BANNER
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: headerBgColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isAlreadyCheckedIn
                                  ? const Color(0xFFFED7AA)
                                  : (isSuccess ? const Color(0xFFA7F3D0) : const Color(0xFFC7D2FE)),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(headerIcon, color: primaryColor, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      headerTitle,
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                    Text(
                                      displayPassNo,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF4E54C8),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (passInfo?.checkinStatus != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isAlreadyCheckedIn ? const Color(0xFFFEF3C7) : const Color(0xFFD1FAE5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    passInfo!.checkinStatus!.replaceAll('_', ' ').toUpperCase(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isAlreadyCheckedIn ? const Color(0xFFB45309) : const Color(0xFF047857),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // 2. ESSENTIAL STUDENT & EVENT CARD
                        if (studentInfo != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: 52,
                                    height: 52,
                                    color: const Color(0xFFEEF2FF),
                                    child: (studentInfo.photoUrl != null && studentInfo.photoUrl!.isNotEmpty)
                                        ? Image.network(
                                            studentInfo.photoUrl!,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (ctx, child, progress) {
                                              if (progress == null) return child;
                                              return const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4E54C8))));
                                            },
                                            errorBuilder: (ctx, err, stack) => const Icon(
                                              Icons.person_rounded,
                                              color: Color(0xFF4E54C8),
                                              size: 28,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.person_rounded,
                                            color: Color(0xFF4E54C8),
                                            size: 28,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        studentInfo.studentName ?? 'Student',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1E293B),
                                        ),
                                      ),
                                      Text(
                                        'Class: ${studentInfo.studentClass ?? studentInfo.classSection ?? ""} - ${studentInfo.section ?? ""} • Adm: ${studentInfo.admissionNumber ?? "N/A"}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11.5,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                      if (eventInfo?.title != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          'Event: ${eventInfo!.title}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF4E54C8),
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
                          ),
                          const SizedBox(height: 10),

                          // 2.5. DATE & TIME CARD
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEFF6FF),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.calendar_month_rounded, color: Color(0xFF2563EB), size: 16),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Event Date',
                                              style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              eventInfo?.startDate ?? passInfo?.firstCheckinAt ?? 'Today',
                                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(height: 28, width: 1, color: const Color(0xFFE2E8F0)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFECFDF5),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.access_time_rounded, color: Color(0xFF059669), size: 16),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Event Time',
                                              style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              eventInfo?.startTime ?? 'Current Time',
                                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],

                        // 3. ESSENTIAL COMBINED ATTENDEES CARD
                        if (approvedAttendees.isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Attendees (${approvedAttendees.length})',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                    if (_selectedAttendeeIds.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEEF2FF),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${_selectedAttendeeIds.length} Selected',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF4F46E5),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                                ),

                                // All Attendees List inside single container
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: approvedAttendees.length,
                                  separatorBuilder: (ctx, idx) => const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                                  ),
                                  itemBuilder: (context, index) {
                                    final att = approvedAttendees[index];
                                    final key = att.id ?? att.name ?? att.hashCode;
                                    final isAlreadyDone = _alreadyCheckedInIds.contains(key);
                                    final isSelected = _selectedAttendeeIds.contains(key);

                                    return Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            width: 44,
                                            height: 44,
                                            color: isAlreadyDone
                                                ? const Color(0xFFECFDF5)
                                                : (isSelected ? const Color(0xFFEEF2FF) : const Color(0xFFF8FAFC)),
                                            child: (att.photoUrl != null && att.photoUrl!.isNotEmpty)
                                                ? Image.network(
                                                    att.photoUrl!,
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (ctx, child, progress) {
                                                      if (progress == null) return child;
                                                      return const Center(child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4E54C8))));
                                                    },
                                                    errorBuilder: (ctx, err, stack) => Icon(
                                                      Icons.person_rounded,
                                                      color: isAlreadyDone
                                                          ? const Color(0xFF059669)
                                                          : (isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B)),
                                                      size: 22,
                                                    ),
                                                  )
                                                : Icon(
                                                    Icons.person_rounded,
                                                    color: isAlreadyDone
                                                        ? const Color(0xFF059669)
                                                        : (isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B)),
                                                    size: 22,
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      '${att.name ?? "Attendee"} (${att.personType ?? ""})',
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.bold,
                                                        color: const Color(0xFF1E293B),
                                                      ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    behavior: HitTestBehavior.opaque,
                                                    onTap: isAlreadyDone
                                                        ? null
                                                        : () {
                                                            setState(() {
                                                              if (isSelected) {
                                                                _selectedAttendeeIds.remove(key);
                                                              } else {
                                                                _selectedAttendeeIds.add(key);
                                                              }
                                                            });
                                                          },
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(2.0),
                                                      child: AnimatedContainer(
                                                        duration: const Duration(milliseconds: 180),
                                                        width: 22,
                                                        height: 22,
                                                        decoration: BoxDecoration(
                                                          color: isAlreadyDone
                                                              ? const Color(0xFF059669)
                                                              : (isSelected ? const Color(0xFF4F46E5) : Colors.transparent),
                                                          borderRadius: BorderRadius.circular(6),
                                                          border: Border.all(
                                                            color: isAlreadyDone
                                                                ? const Color(0xFF059669)
                                                                : (isSelected ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8)),
                                                            width: 1.8,
                                                          ),
                                                        ),
                                                        child: (isAlreadyDone || isSelected)
                                                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 15)
                                                            : null,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (att.mobileNo != null && att.mobileNo!.isNotEmpty)
                                                Text(
                                                  'Mob: ${att.mobileNo}',
                                                  style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                                                ),
                                              const SizedBox(height: 4),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: isAlreadyDone
                                                      ? const Color(0xFFECFDF5)
                                                      : (isSelected ? const Color(0xFFEEF2FF) : const Color(0xFFFFF7ED)),
                                                  borderRadius: BorderRadius.circular(5),
                                                ),
                                                child: Text(
                                                  isAlreadyDone
                                                      ? 'Checked In'
                                                      : (isSelected ? 'Selected for Check-In' : 'Pending'),
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: isAlreadyDone
                                                        ? const Color(0xFF059669)
                                                        : (isSelected ? const Color(0xFF4F46E5) : const Color(0xFFEA580C)),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),

                                if (_selectedAttendeeIds.isNotEmpty) ...[
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 44,
                                    child: ElevatedButton.icon(
                                      onPressed: _isSubmitting ? null : _submitCheckIn,
                                      icon: _isSubmitting
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                            )
                                          : const Icon(
                                              Icons.check_circle_rounded,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                      label: Text(
                                        _isSubmitting
                                            ? 'RECORDING...'
                                            : 'SUBMIT CHECK-IN (${_selectedAttendeeIds.length})',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF4F46E5),
                                        disabledBackgroundColor: const Color(0xFF4F46E5).withValues(alpha: 0.4),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        elevation: 2,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // -------------------------------------------------
                // BOTTOM OK BUTTON
                // -------------------------------------------------
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                      label: Text(
                        'OK',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.6,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
