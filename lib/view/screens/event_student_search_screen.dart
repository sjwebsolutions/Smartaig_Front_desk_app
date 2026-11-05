import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/event_scan_model.dart';
import '../../utils/app_error_formatter.dart';
import '../../utils/app_snackbar.dart';
import '../../view_models/get_x/event_scan_controller.dart';
import 'event_pass_result_screen.dart';

class EventStudentSearchScreen extends StatefulWidget {
  final dynamic eventId;
  final String? eventTitle;

  const EventStudentSearchScreen({
    super.key,
    required this.eventId,
    this.eventTitle,
  });

  @override
  State<EventStudentSearchScreen> createState() => _EventStudentSearchScreenState();
}

class _EventStudentSearchScreenState extends State<EventStudentSearchScreen> {
  final EventScanController _controller = Get.put(EventScanController());
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller.searchedStudents.clear();
    _controller.searchStudentError.value = '';
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      final clean = query.trim();
      if (clean.isEmpty) {
        _controller.searchedStudents.clear();
        _controller.searchStudentError.value = '';
        return;
      }
      _controller.searchStudentsForEvent(
        eventId: widget.eventId ?? '1',
        query: clean,
      );
    });
  }

  void _performSearch(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    final clean = query.trim();
    if (clean.isEmpty) {
      _controller.searchedStudents.clear();
      _controller.searchStudentError.value = '';
      return;
    }
    _searchFocusNode.unfocus();
    _controller.searchStudentsForEvent(
      eventId: widget.eventId ?? '1',
      query: clean,
    );
  }

  Future<void> _verifyPass(String passCode) async {
    try {
      HapticFeedback.mediumImpact();
      final res = await _controller.scanEventPass(passCode);
      final scanResult = PassScanResultModel.fromJson(res);
      Get.to(() => EventPassResultScreen(
        scanResult: scanResult,
        passCode: passCode,
      ));
    } catch (e) {
      AppSnackbar.showError(
        title: 'Pass Verification Failed',
        message: AppErrorFormatter.format(e),
      );
    }
  }

  void _showIssueWalkInDialog(EventSearchStudentItem student) {
    String personType = 'father';
    final nameCtrl = TextEditingController(
      text: student.fatherName != null && student.fatherName!.isNotEmpty
          ? student.fatherName
          : student.studentName,
    );
    final mobileCtrl = TextEditingController(
      text: student.fatherMobile != null && student.fatherMobile!.isNotEmpty
          ? student.fatherMobile
          : student.whatsappNo,
    );
    final whatsappCtrl = TextEditingController(text: student.whatsappNo ?? '');
    final aadhaarCtrl = TextEditingController(
      text: student.fatherAadhaar != null && student.fatherAadhaar!.isNotEmpty
          ? student.fatherAadhaar
          : student.studentAadhaar,
    );
    final remarksCtrl = TextEditingController(text: 'Walk-in entry issued at gate');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.badge_rounded, color: Color(0xFF4E54C8), size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Issue Walk-in Gate Pass',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Student: ${student.studentName} (${student.className} - ${student.sectionName})',
                      style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 14),

                    // Person Type
                    Text('Person Type', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: personType,
                          isExpanded: true,
                          style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF1E293B), fontWeight: FontWeight.w600),
                          items: const [
                            DropdownMenuItem(value: 'father', child: Text('Father')),
                            DropdownMenuItem(value: 'mother', child: Text('Mother')),
                            DropdownMenuItem(value: 'guardian', child: Text('Guardian')),
                            DropdownMenuItem(value: 'student', child: Text('Student')),
                            DropdownMenuItem(value: 'guest', child: Text('Guest')),
                            DropdownMenuItem(value: 'other', child: Text('Other')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() {
                                personType = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Attendee Name
                    Text('Attendee Name *', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
                    const SizedBox(height: 4),
                    TextField(
                      controller: nameCtrl,
                      style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF1E293B)),
                      decoration: InputDecoration(
                        hintText: 'Enter attendee name',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Mobile No
                    Text('Mobile Number *', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
                    const SizedBox(height: 4),
                    TextField(
                      controller: mobileCtrl,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF1E293B)),
                      decoration: InputDecoration(
                        hintText: 'Enter 10 digit mobile number',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Remarks
                    Text('Remarks', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
                    const SizedBox(height: 4),
                    TextField(
                      controller: remarksCtrl,
                      style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF1E293B)),
                      decoration: InputDecoration(
                        hintText: 'e.g. Walk-in entry issued at gate',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Submit Button
                    Obx(() {
                      final isSubmitting = _controller.isIssuingWalkInPass.value;
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final name = nameCtrl.text.trim();
                                  final mobile = mobileCtrl.text.trim();
                                  if (name.isEmpty || mobile.isEmpty) {
                                    AppSnackbar.showWarning(
                                      title: 'Input Required',
                                      message: 'Please fill attendee name and mobile number.',
                                    );
                                    return;
                                  }

                                  try {
                                    HapticFeedback.mediumImpact();
                                    final res = await _controller.issueWalkInPass(
                                      eventId: widget.eventId ?? '1',
                                      studentId: student.id,
                                      autoApprove: true,
                                      autoCheckin: true,
                                      gateName: 'main gate',
                                      remarks: remarksCtrl.text.trim(),
                                      personType: personType,
                                      attendeeName: name,
                                      mobileNo: mobile,
                                      whatsappNo: whatsappCtrl.text.trim(),
                                      aadhaarNumber: aadhaarCtrl.text.trim(),
                                      existingPhotoPath: student.fatherPhotoUrl ?? student.studentPhotoUrl,
                                    );

                                    if (ctx.mounted) {
                                      Navigator.pop(ctx);
                                    }

                                    AppSnackbar.showSuccess(
                                      title: 'Pass Issued',
                                      message: res.message ?? 'Walk-in pass issued successfully!',
                                    );

                                    if (res.data?.passNumber != null) {
                                      _verifyPass(res.data!.passNumber!);
                                    }
                                  } catch (e) {
                                    AppSnackbar.showError(
                                      title: 'Issue Walk-in Pass Failed',
                                      message: AppErrorFormatter.format(e),
                                    );
                                  }
                                },
                          icon: isSubmitting
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                          label: Text(
                            isSubmitting ? 'ISSUING WALK-IN PASS...' : 'CONFIRM & ISSUE WALK-IN PASS',
                            style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4E54C8),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      );
                    }),
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
                // TOP APP BAR
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
                            widget.eventTitle != null && widget.eventTitle!.isNotEmpty
                                ? widget.eventTitle!.toUpperCase()
                                : 'SEARCH STUDENT PASS',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2C3E50),
                              letterSpacing: 1.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 30),
                    ],
                  ),
                ),

                // SEARCH BAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      textInputAction: TextInputAction.search,
                      onChanged: _onSearchChanged,
                      onSubmitted: (val) => _performSearch(val),
                      style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                      decoration: InputDecoration(
                        hintText: 'Type student name or admission no...',
                        hintStyle: GoogleFonts.poppins(fontSize: 12.5, color: const Color(0xFF94A3B8), fontWeight: FontWeight.normal),
                        prefixIcon: const Icon(Icons.person_search_rounded, color: Color(0xFF4E54C8), size: 20),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search_rounded, color: Color(0xFF4E54C8), size: 20),
                          onPressed: () => _performSearch(_searchController.text),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                ),

                // SEARCH RESULTS LIST
                Expanded(
                  child: Obx(() {
                    if (_controller.isSearchingStudents.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(color: Color(0xFF4E54C8)),
                        ),
                      );
                    }

                    if (_controller.searchStudentError.value.isNotEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 48),
                              const SizedBox(height: 12),
                              Text(
                                _controller.searchStudentError.value,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final list = _controller.searchedStudents;

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
                                const Icon(Icons.person_search_rounded, color: Color(0xFF94A3B8), size: 52),
                                const SizedBox(height: 14),
                                Text(
                                  'Search Event Students',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Type student name or admission number in the search bar above to verify pass entry.',
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
                        final student = list[index];
                        final hasPass = student.passExists == true && student.passNumber != null;

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
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      color: const Color(0xFFEEF2FF),
                                      child: student.studentPhotoUrl != null && student.studentPhotoUrl!.isNotEmpty
                                          ? Image.network(
                                              student.studentPhotoUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (ctx, err, stack) => const Icon(Icons.person, color: Color(0xFF4E54C8), size: 26),
                                            )
                                          : const Icon(Icons.person, color: Color(0xFF4E54C8), size: 26),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          student.studentName ?? 'Student',
                                          style: GoogleFonts.poppins(fontSize: 14.5, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                                        ),
                                        Text(
                                          'Class: ${student.className ?? ''} - ${student.sectionName ?? ''} • Adm No: ${student.admissionNumber ?? 'N/A'}',
                                          style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF64748B)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (student.fatherName != null && student.fatherName!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Father: ${student.fatherName} ${student.fatherMobile != null && student.fatherMobile!.isNotEmpty ? "(${student.fatherMobile})" : ""}',
                                  style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF475569)),
                                ),
                              ],
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: hasPass ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: hasPass ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA),
                                      ),
                                    ),
                                    child: Text(
                                      hasPass ? 'Pass: ${student.passNumber}' : 'No Pass Issued',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: hasPass ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                      ),
                                    ),
                                  ),
                                  if (hasPass)
                                    ElevatedButton.icon(
                                      onPressed: () => _verifyPass(student.passNumber!),
                                      icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                                      label: Text(
                                        'VERIFY PASS',
                                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF4E54C8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      ),
                                    )
                                  else
                                    ElevatedButton.icon(
                                      onPressed: () => _showIssueWalkInDialog(student),
                                      icon: const Icon(Icons.add_card_rounded, color: Colors.white, size: 16),
                                      label: Text(
                                        'ISSUE WALK-IN PASS',
                                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFEA580C),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
