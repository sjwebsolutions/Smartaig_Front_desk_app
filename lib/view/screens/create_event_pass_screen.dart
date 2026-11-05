import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/active_event_model.dart';
import '../../models/event_scan_model.dart';
import '../../utils/app_error_formatter.dart';
import '../../utils/app_snackbar.dart';
import '../../view_models/get_x/active_event_controller.dart';
import '../../view_models/get_x/event_scan_controller.dart';
import 'event_pass_result_screen.dart';
import 'image_crop_screen.dart';

class AadhaarInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final clean = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (clean.length > 12) return oldValue;

    final buffer = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(clean[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

String _formatAadhaarString(String rawDigits) {
  final clean = rawDigits.replaceAll(RegExp(r'\D'), '');
  final limited = clean.length > 12 ? clean.substring(0, 12) : clean;
  final buffer = StringBuffer();
  for (int i = 0; i < limited.length; i++) {
    if (i > 0 && i % 4 == 0) buffer.write(' ');
    buffer.write(limited[i]);
  }
  return buffer.toString();
}

class AttendeeFormData {
  String personType;
  TextEditingController nameController;
  TextEditingController mobileController;
  TextEditingController whatsappController;
  TextEditingController aadhaarController;
  File? photoFile;
  String? existingPhotoUrl;
  bool isNameReadOnly;
  bool isMobileReadOnly;
  bool isWhatsappReadOnly;
  bool isPhotoReadOnly;

  AttendeeFormData({
    this.personType = 'father',
    String name = '',
    String mobile = '',
    String whatsapp = '',
    String aadhaar = '',
    this.photoFile,
    this.existingPhotoUrl,
    this.isNameReadOnly = false,
    this.isMobileReadOnly = false,
    this.isWhatsappReadOnly = false,
    this.isPhotoReadOnly = false,
  })  : nameController = TextEditingController(text: name),
        mobileController = TextEditingController(text: mobile),
        whatsappController = TextEditingController(text: whatsapp),
        aadhaarController = TextEditingController(text: _formatAadhaarString(aadhaar));

  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    whatsappController.dispose();
    aadhaarController.dispose();
  }
}

class CreateEventPassScreen extends StatefulWidget {
  final dynamic eventId;
  final String? eventTitle;

  const CreateEventPassScreen({
    super.key,
    this.eventId,
    this.eventTitle,
  });

  @override
  State<CreateEventPassScreen> createState() => _CreateEventPassScreenState();
}

class _CreateEventPassScreenState extends State<CreateEventPassScreen> {
  final EventScanController _eventScanController = Get.put(EventScanController());
  final ActiveEventController _activeEventController = Get.put(ActiveEventController());

  dynamic _selectedEventId;
  ActiveEventItem? _selectedEventItem;

  final TextEditingController _studentSearchController = TextEditingController();
  final FocusNode _studentSearchFocusNode = FocusNode();
  EventSearchStudentItem? _selectedStudent;

  bool _autoApprove = true;
  bool _autoCheckin = true;
  final TextEditingController _gateNameController = TextEditingController(text: 'main gate');
  final TextEditingController _remarksController = TextEditingController(text: 'Walk-in entry issued at gate');

  final List<AttendeeFormData> _attendees = [AttendeeFormData()];
  final int _maxAttendees = 2;

  @override
  void initState() {
    super.initState();
    _eventScanController.searchedStudents.clear();
    _eventScanController.searchStudentError.value = '';

    final events = _activeEventController.activeEvents;
    if (events.isNotEmpty) {
      if (widget.eventId != null) {
        final found = events.firstWhereOrNull((e) => e.id.toString() == widget.eventId.toString());
        _selectedEventItem = found ?? events.first;
      } else {
        _selectedEventItem = events.first;
      }
      _selectedEventId = _selectedEventItem?.id;
    } else {
      _selectedEventId = widget.eventId ?? '1';
    }
  }

  @override
  void dispose() {
    _studentSearchController.dispose();
    _studentSearchFocusNode.dispose();
    _gateNameController.dispose();
    _remarksController.dispose();
    for (var att in _attendees) {
      att.dispose();
    }
    super.dispose();
  }

  void _onStudentSearchChanged(String query) {
    if (query.trim().isEmpty) {
      _eventScanController.searchedStudents.clear();
      _eventScanController.searchStudentError.value = '';
      return;
    }
    _eventScanController.searchStudentsForEvent(
      eventId: _selectedEventId ?? '1',
      query: query.trim(),
    );
  }

  void _selectStudent(EventSearchStudentItem student) {
    setState(() {
      _selectedStudent = student;
      _eventScanController.searchedStudents.clear();
      _studentSearchController.text = '${student.studentName ?? ""} (${student.admissionNumber ?? ""})';
      _studentSearchFocusNode.unfocus();

      // Prefill attendee #1 based on current personType or default 'father'
      if (_attendees.isNotEmpty) {
        _updateAttendeeForPersonType(0, _attendees[0].personType);
      }
    });
  }

  void _updateAttendeeForPersonType(int index, String newType) {
    setState(() {
      final att = _attendees[index];
      att.personType = newType;

      if (_selectedStudent != null) {
        final st = _selectedStudent!;
        if (newType == 'mother') {
          final mName = st.motherName ?? '';
          att.nameController.text = mName.isNotEmpty ? mName : (st.studentName ?? '');
          att.isNameReadOnly = mName.isNotEmpty;

          final rawMobile = st.motherMobile ?? st.whatsappNo ?? '';
          final mDigits = rawMobile.replaceAll(RegExp(r'\D'), '');
          att.mobileController.text = mDigits.length > 10 ? mDigits.substring(mDigits.length - 10) : mDigits;
          att.isMobileReadOnly = att.mobileController.text.isNotEmpty;

          final wDigits = (st.whatsappNo ?? '').replaceAll(RegExp(r'\D'), '');
          att.whatsappController.text = wDigits.length > 10 ? wDigits.substring(wDigits.length - 10) : wDigits;
          att.isWhatsappReadOnly = att.whatsappController.text.isNotEmpty;

          final aDigits = (st.motherAadhaar != null && st.motherAadhaar!.isNotEmpty)
              ? st.motherAadhaar!.replaceAll(RegExp(r'\D'), '')
              : (st.studentAadhaar ?? '').replaceAll(RegExp(r'\D'), '');
          att.aadhaarController.text = _formatAadhaarString(aDigits);

          att.existingPhotoUrl = st.motherPhotoUrl ?? st.studentPhotoUrl;
          att.isPhotoReadOnly = (st.motherPhotoUrl != null && st.motherPhotoUrl!.isNotEmpty);
        } else if (newType == 'father') {
          final fName = st.fatherName ?? '';
          att.nameController.text = fName.isNotEmpty ? fName : (st.studentName ?? '');
          att.isNameReadOnly = fName.isNotEmpty;

          final rawMobile = st.fatherMobile ?? st.whatsappNo ?? '';
          final mDigits = rawMobile.replaceAll(RegExp(r'\D'), '');
          att.mobileController.text = mDigits.length > 10 ? mDigits.substring(mDigits.length - 10) : mDigits;
          att.isMobileReadOnly = att.mobileController.text.isNotEmpty;

          final wDigits = (st.whatsappNo ?? '').replaceAll(RegExp(r'\D'), '');
          att.whatsappController.text = wDigits.length > 10 ? wDigits.substring(wDigits.length - 10) : wDigits;
          att.isWhatsappReadOnly = att.whatsappController.text.isNotEmpty;

          final aDigits = (st.fatherAadhaar != null && st.fatherAadhaar!.isNotEmpty)
              ? st.fatherAadhaar!.replaceAll(RegExp(r'\D'), '')
              : (st.studentAadhaar ?? '').replaceAll(RegExp(r'\D'), '');
          att.aadhaarController.text = _formatAadhaarString(aDigits);

          att.existingPhotoUrl = st.fatherPhotoUrl ?? st.studentPhotoUrl;
          att.isPhotoReadOnly = (st.fatherPhotoUrl != null && st.fatherPhotoUrl!.isNotEmpty);
        } else if (newType == 'student') {
          att.nameController.text = st.studentName ?? '';
          att.isNameReadOnly = (st.studentName != null && st.studentName!.isNotEmpty);

          final rawMobile = st.whatsappNo ?? st.fatherMobile ?? '';
          final mDigits = rawMobile.replaceAll(RegExp(r'\D'), '');
          att.mobileController.text = mDigits.length > 10 ? mDigits.substring(mDigits.length - 10) : mDigits;
          att.isMobileReadOnly = att.mobileController.text.isNotEmpty;

          final wDigits = (st.whatsappNo ?? '').replaceAll(RegExp(r'\D'), '');
          att.whatsappController.text = wDigits.length > 10 ? wDigits.substring(wDigits.length - 10) : wDigits;
          att.isWhatsappReadOnly = att.whatsappController.text.isNotEmpty;

          final aDigits = (st.studentAadhaar ?? '').replaceAll(RegExp(r'\D'), '');
          att.aadhaarController.text = _formatAadhaarString(aDigits);

          att.existingPhotoUrl = st.studentPhotoUrl;
          att.isPhotoReadOnly = (st.studentPhotoUrl != null && st.studentPhotoUrl!.isNotEmpty);
        } else {
          att.nameController.clear();
          att.mobileController.clear();
          att.whatsappController.clear();
          att.aadhaarController.clear();
          att.photoFile = null;
          att.existingPhotoUrl = null;

          att.isNameReadOnly = false;
          att.isMobileReadOnly = false;
          att.isWhatsappReadOnly = false;
          att.isPhotoReadOnly = false;
        }
      } else {
        att.isNameReadOnly = false;
        att.isMobileReadOnly = false;
        att.isWhatsappReadOnly = false;
        att.isPhotoReadOnly = false;
      }
    });
  }

  void _addAttendee() {
    if (_attendees.length < _maxAttendees) {
      setState(() {
        final newAtt = AttendeeFormData(personType: 'mother');
        _attendees.add(newAtt);
        _updateAttendeeForPersonType(_attendees.length - 1, 'mother');
      });
    }
  }

  void _removeAttendee(int index) {
    if (_attendees.length > 1) {
      setState(() {
        _attendees[index].dispose();
        _attendees.removeAt(index);
      });
    }
  }

  void _showPhotoSourceBottomSheet(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                const SizedBox(height: 16),
                Text(
                  'Select Photo Source',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E2B58),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickAttendeePhoto(index, ImageSource.camera);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFC7D2FE)),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.camera_alt_rounded, color: Color(0xFF1E2B58), size: 32),
                              const SizedBox(height: 8),
                              Text(
                                'Camera',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E2B58),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickAttendeePhoto(index, ImageSource.gallery);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.photo_library_rounded, color: Color(0xFF2563EB), size: 32),
                              const SizedBox(height: 8),
                              Text(
                                'Gallery',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAttendeePhoto(int index, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 90,
      );
      if (picked != null) {
        final rawFile = File(picked.path);
        final croppedResult = await Get.to<dynamic>(() => ImageCropScreen(
          imageFile: rawFile,
          title: 'Crop Attendee Photo',
        ));

        if (croppedResult != null) {
          File? finalFile;
          if (croppedResult is XFile) {
            finalFile = File(croppedResult.path);
          } else if (croppedResult is File) {
            finalFile = croppedResult;
          } else if (croppedResult is String) {
            finalFile = File(croppedResult);
          }

          if (finalFile != null) {
            setState(() {
              _attendees[index].photoFile = finalFile;
            });
          }
        }
      }
    } catch (e) {
      AppSnackbar.showWarning(
        title: 'Photo Picker Error',
        message: 'Could not access photo source. Please check permissions.',
      );
    }
  }

  Future<void> _submitCreatePass() async {
    if (_selectedStudent == null) {
      AppSnackbar.showWarning(
        title: 'Student Required',
        message: 'Please search and select a student first.',
      );
      return;
    }

    if (_attendees.isEmpty) {
      AppSnackbar.showWarning(
        title: 'Attendee Required',
        message: 'Please add at least one attendee.',
      );
      return;
    }

    final att1 = _attendees[0];
    final name = att1.nameController.text.trim();
    final mobile = att1.mobileController.text.trim();
    final aadhaarClean = att1.aadhaarController.text.replaceAll(RegExp(r'\D'), '');

    if (name.isEmpty) {
      AppSnackbar.showWarning(
        title: 'Name Required',
        message: 'Please enter attendee #1 full name.',
      );
      return;
    }

    if (mobile.length != 10) {
      AppSnackbar.showWarning(
        title: 'Invalid Mobile Number',
        message: 'Mobile number for attendee #1 must be exactly 10 digits.',
      );
      return;
    }

    if (aadhaarClean.isNotEmpty && aadhaarClean.length != 12) {
      AppSnackbar.showWarning(
        title: 'Invalid Aadhaar Number',
        message: 'Aadhaar number for attendee #1 must be exactly 12 digits.',
      );
      return;
    }

    try {
      HapticFeedback.mediumImpact();
      final res = await _eventScanController.issueWalkInPass(
        eventId: _selectedEventId ?? '1',
        studentId: _selectedStudent!.id,
        autoApprove: _autoApprove,
        autoCheckin: _autoCheckin,
        gateName: _gateNameController.text.trim(),
        remarks: _remarksController.text.trim(),
        personType: att1.personType,
        attendeeName: name,
        mobileNo: mobile,
        whatsappNo: att1.whatsappController.text.trim(),
        aadhaarNumber: aadhaarClean,
        photoFile: att1.photoFile?.path,
        existingPhotoPath: att1.existingPhotoUrl,
      );

      AppSnackbar.showSuccess(
        title: 'Pass Created',
        message: res.message ?? 'Walk-in pass created successfully!',
      );

      if (mounted) {
        Get.back();
        if (res.data?.passNumber != null) {
          final scanRes = await _eventScanController.scanEventPass(res.data!.passNumber!);
          final scanResult = PassScanResultModel.fromJson(scanRes);
          Get.to(() => EventPassResultScreen(
            scanResult: scanResult,
            passCode: res.data!.passNumber!,
          ));
        }
      }
    } catch (e) {
      AppSnackbar.showError(
        title: 'Create Pass Failed',
        message: AppErrorFormatter.format(e),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFE8DCFF),
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
                Color(0xFFD4E5FF),
                Color(0xFFE8DCFF),
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
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E2B58), size: 18),
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
                            'EVENT CREATE ENTRY',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E2B58),
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                    ],
                  ),
                ),

                // SCROLLABLE FORM BODY
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. SELECT EVENT
                        _buildSection1SelectEvent(),
                        const SizedBox(height: 12),

                        // 2. SELECT STUDENT
                        _buildSection2SelectStudent(),
                        const SizedBox(height: 12),

                        // 3. PASS SETTINGS
                        _buildSection3PassSettings(),
                        const SizedBox(height: 12),

                        // 4. ATTENDEES
                        _buildSection4Attendees(),
                        const SizedBox(height: 16),

                        // BOTTOM CREATE ENTRY BUTTON
                        _buildCreateEntryButton(),
                        const SizedBox(height: 20),
                      ],
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

  // =========================================================
  // SECTION 1: SELECT EVENT
  // =========================================================
  Widget _buildSection1SelectEvent() {
    final activeEvents = _activeEventController.activeEvents;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, color: Color(0xFF1E2B58), size: 18),
              const SizedBox(width: 8),
              Text(
                '1. SELECT EVENT',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E2B58),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<dynamic>(
                value: _selectedEventId,
                isExpanded: true,
                borderRadius: BorderRadius.circular(12),
                dropdownColor: Colors.white,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF1E2B58), size: 24),
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E2B58),
                ),
                items: activeEvents.isNotEmpty
                    ? activeEvents.map((item) {
                        return DropdownMenuItem<dynamic>(
                          value: item.id,
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF1E2B58)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item.title ?? 'Active Event',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E2B58),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList()
                    : [
                        DropdownMenuItem<dynamic>(
                          value: _selectedEventId ?? '1',
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF1E2B58)),
                              const SizedBox(width: 10),
                              Text(
                                widget.eventTitle ?? 'Active Event',
                                style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.bold, color: const Color(0xFF1E2B58)),
                              ),
                            ],
                          ),
                        ),
                      ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedEventId = val;
                      final found = activeEvents.firstWhereOrNull((e) => e.id.toString() == val.toString());
                      _selectedEventItem = found;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SECTION 2: SELECT STUDENT
  // =========================================================
  Widget _buildSection2SelectStudent() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, color: Color(0xFF1E2B58), size: 18),
              const SizedBox(width: 8),
              Text(
                '2. SELECT STUDENT',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E2B58),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Search Field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: TextField(
              controller: _studentSearchController,
              focusNode: _studentSearchFocusNode,
              onChanged: _onStudentSearchChanged,
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E2B58)),
              decoration: InputDecoration(
                hintText: 'Type student name, student ID, admis...',
                hintStyle: GoogleFonts.poppins(fontSize: 12.5, color: const Color(0xFF94A3B8), fontWeight: FontWeight.normal),
                isDense: true,
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                suffixIcon: _selectedStudent != null
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 18),
                        onPressed: () {
                          setState(() {
                            _selectedStudent = null;
                            _studentSearchController.clear();
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: InputBorder.none,
              ),
            ),
          ),

          // Dropdown Search Results
          Obx(() {
            if (_eventScanController.isSearchingStudents.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator(color: Color(0xFF1E2B58))),
              );
            }

            final results = _eventScanController.searchedStudents;
            if (results.isEmpty) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.only(top: 8),
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: results.length,
                separatorBuilder: (ctx, idx) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
                itemBuilder: (ctx, index) {
                  final st = results[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      st.studentName ?? 'Student',
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E2B58)),
                    ),
                    subtitle: Text(
                      'Class: ${st.className ?? ""} - ${st.sectionName ?? ""} • Adm: ${st.admissionNumber ?? "N/A"}',
                      style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                    ),
                    onTap: () => _selectStudent(st),
                  );
                },
              ),
            );
          }),

          // Selected Student Banner
          if (_selectedStudent != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFC7D2FE)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 40,
                      height: 40,
                      color: const Color(0xFFC7D2FE),
                      child: _selectedStudent!.studentPhotoUrl != null && _selectedStudent!.studentPhotoUrl!.isNotEmpty
                          ? Image.network(
                              _selectedStudent!.studentPhotoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => const Icon(Icons.person, color: Color(0xFF1E2B58), size: 22),
                            )
                          : const Icon(Icons.person, color: Color(0xFF1E2B58), size: 22),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedStudent!.studentName ?? 'Student',
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E2B58)),
                        ),
                        Text(
                          'Father: ${_selectedStudent!.fatherName ?? "N/A"} • Mobile: ${_selectedStudent!.fatherMobile ?? "N/A"}',
                          style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF475569)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =========================================================
  // SECTION 3: PASS SETTINGS
  // =========================================================
  Widget _buildSection3PassSettings() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: Color(0xFF1E2B58), size: 18),
              const SizedBox(width: 8),
              Text(
                '3. PASS SETTINGS',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E2B58),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Auto Approve Switch Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Auto Approve Pass',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E2B58),
                  ),
                ),
                Switch(
                  value: _autoApprove,
                  activeThumbColor: Colors.white,
                  activeTrackColor: const Color(0xFF1E2B58),
                  onChanged: (val) {
                    setState(() {
                      _autoApprove = val;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Auto Check-in Switch Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Auto Check-in Pass',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E2B58),
                  ),
                ),
                Switch(
                  value: _autoCheckin,
                  activeThumbColor: Colors.white,
                  activeTrackColor: const Color(0xFF1E2B58),
                  onChanged: (val) {
                    setState(() {
                      _autoCheckin = val;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Gate Name Outlined Field
          InputDecorator(
            decoration: InputDecoration(
              labelText: 'Gate Name',
              labelStyle: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.meeting_room_rounded, color: Color(0xFF1E2B58), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _gateNameController,
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E2B58)),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Remarks Outlined Field
          InputDecorator(
            decoration: InputDecoration(
              labelText: 'Remarks',
              labelStyle: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.edit_note_rounded, color: Color(0xFF1E2B58), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _remarksController,
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E2B58)),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SECTION 4: ATTENDEES
  // =========================================================
  Widget _buildSection4Attendees() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people_alt_rounded, color: Color(0xFF1E2B58), size: 18),
              const SizedBox(width: 8),
              Text(
                '4. ATTENDEES (${_attendees.length} / $_maxAttendees)',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E2B58),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Attendees List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _attendees.length,
            itemBuilder: (context, index) {
              return _buildSingleAttendeeCard(index);
            },
          ),

          if (_attendees.length < _maxAttendees) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addAttendee,
                icon: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF1E2B58), size: 18),
                label: Text(
                  'ADD ANOTHER ATTENDEE (MAX $_maxAttendees)',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E2B58),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF1E2B58), width: 1.2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSingleAttendeeCard(int index) {
    final att = _attendees[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attendee #${index + 1}',
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E2B58),
                ),
              ),
              if (_attendees.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 20),
                  onPressed: () => _removeAttendee(index),
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Person Type Dropdown (Outlined Label)
          InputDecorator(
            decoration: InputDecoration(
              labelText: 'Person Type *',
              labelStyle: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.badge_outlined, color: Color(0xFF1E2B58), size: 18),
                const SizedBox(width: 8),
                const Icon(Icons.face_rounded, color: Color(0xFF1E2B58), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: att.personType,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(12),
                      dropdownColor: Colors.white,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF1E2B58), size: 20),
                      style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF1E2B58), fontWeight: FontWeight.bold),
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
                          _updateAttendeeForPersonType(index, val);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Full Name Input (Read-only if fetched from DB)
          TextField(
            controller: att.nameController,
            readOnly: att.isNameReadOnly,
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E2B58)),
            decoration: InputDecoration(
              hintText: 'Full Name *',
              hintStyle: GoogleFonts.poppins(fontSize: 12.5, color: const Color(0xFF94A3B8)),
              isDense: true,
              fillColor: att.isNameReadOnly ? const Color(0xFFF1F5F9) : Colors.white,
              filled: true,
              prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF1E2B58), size: 19),
              suffixIcon: att.isNameReadOnly ? const Icon(Icons.lock_outline_rounded, color: Color(0xFF94A3B8), size: 16) : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Mobile No (10 Digits) (Read-only if fetched from DB)
          TextField(
            controller: att.mobileController,
            readOnly: att.isMobileReadOnly,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E2B58)),
            decoration: InputDecoration(
              hintText: 'Mobile No (10 Digits) *',
              hintStyle: GoogleFonts.poppins(fontSize: 12.5, color: const Color(0xFF94A3B8)),
              isDense: true,
              counterText: '',
              fillColor: att.isMobileReadOnly ? const Color(0xFFF1F5F9) : Colors.white,
              filled: true,
              prefixIcon: const Icon(Icons.smartphone_rounded, color: Color(0xFF1E2B58), size: 19),
              suffixIcon: att.isMobileReadOnly ? const Icon(Icons.lock_outline_rounded, color: Color(0xFF94A3B8), size: 16) : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // WhatsApp No (10 Digits)
          TextField(
            controller: att.whatsappController,
            readOnly: att.isWhatsappReadOnly,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E2B58)),
            decoration: InputDecoration(
              hintText: 'WhatsApp No (10 Digits)',
              hintStyle: GoogleFonts.poppins(fontSize: 12.5, color: const Color(0xFF94A3B8)),
              isDense: true,
              counterText: '',
              fillColor: att.isWhatsappReadOnly ? const Color(0xFFF1F5F9) : Colors.white,
              filled: true,
              prefixIcon: const Padding(
                padding: EdgeInsets.all(12),
                child: FaIcon(FontAwesomeIcons.whatsapp, color: Color(0xFF25D366), size: 18),
              ),
              suffixIcon: att.isWhatsappReadOnly ? const Icon(Icons.lock_outline_rounded, color: Color(0xFF94A3B8), size: 16) : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Aadhaar No (12 Digits with 4-Digit Gaps: 1113 2222 2273)
          TextField(
            controller: att.aadhaarController,
            keyboardType: TextInputType.number,
            maxLength: 14,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              AadhaarInputFormatter(),
            ],
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E2B58)),
            decoration: InputDecoration(
              hintText: 'Aadhaar No (12 Digits)',
              hintStyle: GoogleFonts.poppins(fontSize: 12.5, color: const Color(0xFF94A3B8)),
              isDense: true,
              counterText: '',
              prefixIcon: const Icon(Icons.credit_card_rounded, color: Color(0xFF1E2B58), size: 19),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Photo Capture Row
          Row(
            children: [
              // Photo Thumbnail Box
              GestureDetector(
                onTap: att.isPhotoReadOnly ? null : () => _showPhotoSourceBottomSheet(index),
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: att.photoFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: Image.file(att.photoFile!, fit: BoxFit.cover, width: 68, height: 68),
                        )
                      : (att.existingPhotoUrl != null && att.existingPhotoUrl!.isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: Image.network(
                                att.existingPhotoUrl!,
                                fit: BoxFit.cover,
                                width: 68,
                                height: 68,
                                errorBuilder: (c, e, s) => const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.camera_alt_rounded, color: Color(0xFF1E2B58), size: 22),
                                    SizedBox(height: 2),
                                    Text('Photo', style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt_rounded, color: Color(0xFF1E2B58), size: 22),
                                SizedBox(height: 2),
                                Text('Photo', style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                              ],
                            ),
                ),
              ),
              const SizedBox(width: 10),

              // Capture Photo Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: att.isPhotoReadOnly ? null : () => _showPhotoSourceBottomSheet(index),
                  icon: Icon(
                    att.isPhotoReadOnly ? Icons.lock_outline_rounded : (att.photoFile != null ? Icons.camera_alt_rounded : Icons.camera_alt_outlined),
                    color: att.isPhotoReadOnly ? const Color(0xFF94A3B8) : const Color(0xFF1E2B58),
                    size: 18,
                  ),
                  label: Text(
                    att.isPhotoReadOnly
                        ? 'Photo Loaded from DB'
                        : (att.photoFile != null ? 'Retake Photo' : 'Capture Attendee Photo'),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: att.isPhotoReadOnly ? const Color(0xFF94A3B8) : const Color(0xFF1E2B58),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    side: BorderSide(color: att.isPhotoReadOnly ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1)),
                    backgroundColor: att.isPhotoReadOnly ? const Color(0xFFF8FAFC) : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
  // BOTTOM CREATE ENTRY BUTTON
  // =========================================================
  Widget _buildCreateEntryButton() {
    return Obx(() {
      final isSubmitting = _eventScanController.isIssuingWalkInPass.value;
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: isSubmitting ? null : _submitCreatePass,
          icon: isSubmitting
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 22),
          label: Text(
            isSubmitting ? 'CREATING ENTRY...' : 'CREATE ENTRY',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.8,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E2B58),
            disabledBackgroundColor: const Color(0xFF1E2B58).withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            shadowColor: const Color(0xFF1E2B58).withValues(alpha: 0.3),
          ),
        ),
      );
    });
  }
}
