import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../Widgets/custom_shimmer.dart';
import '../../models/event_scan_model.dart';
import '../../utils/app_error_formatter.dart';
import '../../utils/app_snackbar.dart';
import '../../view_models/get_x/event_scan_controller.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with TickerProviderStateMixin {
  final EventScanController _controller = Get.put(EventScanController());
  final TextEditingController _searchController = TextEditingController();

  late TabController _tabController;
  late MobileScannerController _scannerController;

  late AnimationController _laserAnimController;
  late Animation<double> _laserAnimation;

  bool _isProcessingScan = false;
  String? _lastScannedCode;
  DateTime? _lastScannedTime;

  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
      formats: const [BarcodeFormat.all],
    );

    _laserAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _laserAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _laserAnimController.dispose();
    _scannerController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessingScan) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    String? rawValue;
    for (final barcode in barcodes) {
      final val = (barcode.rawValue ?? barcode.displayValue)?.trim();
      if (val != null && val.isNotEmpty) {
        rawValue = val;
        break;
      }
    }

    if (rawValue == null || rawValue.isEmpty) return;

    final now = DateTime.now();
    if (_lastScannedCode == rawValue &&
        _lastScannedTime != null &&
        now.difference(_lastScannedTime!).inSeconds < 2) {
      return;
    }

    setState(() {
      _isProcessingScan = true;
      _lastScannedCode = rawValue;
      _lastScannedTime = now;
    });

    HapticFeedback.mediumImpact();

    await _processPassCode(rawValue);
  }

  Future<void> _processPassCode(String passCode) async {
    try {
      debugPrint('🔍 [EventsScreen] Processing scanned pass payload: $passCode');
      final res = await _controller.scanEventPass(passCode);
      debugPrint('📥 [EventsScreen] Received scan response: $res');
      final scanResult = PassScanResultModel.fromJson(res);

      if (mounted) {
        final isAlreadyCheckedIn = scanResult.isAlreadyCheckedIn == true;
        final isSuccess = scanResult.success == true && !isAlreadyCheckedIn;
        final isWarning = isAlreadyCheckedIn || (scanResult.warning != null && scanResult.warning!.isNotEmpty);

        final msg = scanResult.warning ??
            scanResult.message ??
            (isAlreadyCheckedIn
                ? 'Pass is already checked in.'
                : 'Pass scanned successfully!');

        if (isWarning) {
          AppSnackbar.showWarning(
            title: isAlreadyCheckedIn ? 'Already Checked In' : 'Pass Warning',
            message: msg,
          );
        } else if (isSuccess) {
          AppSnackbar.showSuccess(
            title: 'Pass Verified',
            message: msg,
          );
        } else {
          AppSnackbar.showInfo(
            title: 'Pass Processed',
            message: msg,
          );
        }

        _showPassScanResultFullScreenModal(scanResult, passCode: passCode);
      }
    } catch (e) {
      debugPrint('❌ [EventsScreen] Scan processing error: $e');
      final errorMsg = AppErrorFormatter.format(e);
      if (mounted) {
        AppSnackbar.showError(
          title: 'Scan Failed',
          message: errorMsg,
        );
      }
      await Future.delayed(const Duration(milliseconds: 2000));
      _resetScannerForNextScan();
    }
  }

  void _showPassScanResultFullScreenModal(PassScanResultModel result, {required String passCode}) {
    final isAlreadyCheckedIn = result.isAlreadyCheckedIn == true;
    final isSuccess = result.success == true && !isAlreadyCheckedIn;
    final isWarning = isAlreadyCheckedIn || (result.warning != null && result.warning!.isNotEmpty);

    final passInfo = result.data?.pass;
    final eventInfo = result.data?.event;
    final studentInfo = result.data?.student;
    final approvedAttendees = result.data?.approvedAttendees ?? [];

    final displayPassNo = passInfo?.passNumber ?? passCode;

    final primaryColor = isWarning
        ? const Color(0xFFD97706)
        : (isSuccess ? const Color(0xFF059669) : const Color(0xFFDC2626));

    final headerBgColor = isWarning
        ? const Color(0xFFFFF7ED)
        : (isSuccess ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2));

    final headerIcon = isWarning
        ? Icons.warning_amber_rounded
        : (isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded);

    final headerTitle = isAlreadyCheckedIn
        ? 'Pass Already Checked In'
        : (isSuccess ? 'Pass Verified & Admitted' : 'Scan Response');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black87,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height,
        width: double.infinity,
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
        child: Column(
          children: [
            // FULL SCREEN TOP HEADER BAR
            Container(
              padding: EdgeInsets.fromLTRB(
                12,
                MediaQuery.of(context).padding.top > 0 ? MediaQuery.of(context).padding.top + 6 : 16,
                12,
                6,
              ),
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: headerBgColor,
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          'Pass: $displayPassNo',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4E54C8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF2C3E50)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _resetScannerForNextScan();
                    },
                  ),
                ],
              ),
            ),

            // FULL SCREEN CONTENT BODY
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // WARNING ALERT BANNER
                    if (result.warning != null && result.warning!.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFED7AA), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEA580C).withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFEDD5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.warning_amber_rounded, size: 22, color: Color(0xFFEA580C)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Duplicate Scan Warning',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF9A3412),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    result.warning!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF9A3412),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ] else if (result.message != null && result.message!.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isWarning ? const Color(0xFFFFF7ED) : const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isWarning ? const Color(0xFFFED7AA) : const Color(0xFFA7F3D0),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isWarning ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
                              size: 20,
                              color: isWarning ? const Color(0xFFEA580C) : const Color(0xFF059669),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                result.message!,
                                style: GoogleFonts.poppins(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: isWarning ? const Color(0xFF9A3412) : const Color(0xFF047857),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // PASS & EVENT DETAILS CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
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
                                'Pass Details',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF64748B),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              if (passInfo?.checkinStatus != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isAlreadyCheckedIn ? const Color(0xFFFEF3C7) : const Color(0xFFD1FAE5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    passInfo!.checkinStatus!.replaceAll('_', ' ').toUpperCase(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isAlreadyCheckedIn ? const Color(0xFFB45309) : const Color(0xFF047857),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const Divider(height: 20, color: Color(0xFFF1F5F9)),
                          Text(
                            displayPassNo,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4E54C8),
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (eventInfo?.title != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.event_rounded, size: 16, color: Color(0xFF64748B)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    eventInfo!.title!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (eventInfo?.venue != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFF64748B)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    eventInfo!.venue!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // STUDENT INFO CARD
                    if (studentInfo != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
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
                            Text(
                              'Student Information',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF64748B),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Divider(height: 20, color: Color(0xFFF1F5F9)),
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    color: const Color(0xFFEEF2FF),
                                    child: (studentInfo.photoUrl != null && studentInfo.photoUrl!.isNotEmpty)
                                        ? Image.network(
                                            studentInfo.photoUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (ctx, err, stack) => const Icon(Icons.person_rounded, color: Color(0xFF4E54C8), size: 32),
                                          )
                                        : const Icon(Icons.person_rounded, color: Color(0xFF4E54C8), size: 32),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        studentInfo.studentName ?? 'Student',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Wrap(
                                        spacing: 8,
                                        children: [
                                          if (studentInfo.classSection != null)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF1F5F9),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                studentInfo.classSection!,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF475569),
                                                ),
                                              ),
                                            ),
                                          if (studentInfo.admissionNumber != null)
                                            Text(
                                              'Adm No: ${studentInfo.admissionNumber}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: const Color(0xFF64748B),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (studentInfo.fatherName != null || studentInfo.motherName != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (studentInfo.fatherName != null && studentInfo.fatherName!.isNotEmpty)
                                      Row(
                                        children: [
                                          const Icon(Icons.person_outline_rounded, size: 15, color: Color(0xFF64748B)),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              'Father: ${studentInfo.fatherName} ${studentInfo.fatherMobile != null ? "(${studentInfo.fatherMobile})" : ""}',
                                              style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF334155)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (studentInfo.motherName != null && studentInfo.motherName!.isNotEmpty) ...[
                                      if (studentInfo.fatherName != null && studentInfo.fatherName!.isNotEmpty)
                                        const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.person_outline_rounded, size: 15, color: Color(0xFF64748B)),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              'Mother: ${studentInfo.motherName} ${studentInfo.motherMobile != null ? "(${studentInfo.motherMobile})" : ""}',
                                              style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF334155)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // APPROVED ATTENDEES LIST
                    if (approvedAttendees.isNotEmpty) ...[
                      Text(
                        'Approved Attendees (${approvedAttendees.length})',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...approvedAttendees.map((att) {
                        final attCheckedIn = att.isCheckedIn == true;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  color: const Color(0xFFEEF2FF),
                                  child: (att.photoUrl != null && att.photoUrl!.isNotEmpty)
                                      ? Image.network(
                                          att.photoUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, stack) => const Icon(Icons.person_rounded, color: Color(0xFF4F46E5), size: 24),
                                        )
                                      : const Icon(Icons.person_rounded, color: Color(0xFF4F46E5), size: 24),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            att.name ?? 'Attendee',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF1E293B),
                                            ),
                                          ),
                                        ),
                                        if (att.personType != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEEF2FF),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              att.personType!,
                                              style: GoogleFonts.poppins(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF4F46E5),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Wrap(
                                      spacing: 10,
                                      children: [
                                        if (att.mobileNo != null && att.mobileNo!.isNotEmpty)
                                          Text(
                                            'Mob: ${att.mobileNo}',
                                            style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                                          ),
                                        if (att.maskedAadhaar != null && att.maskedAadhaar!.isNotEmpty)
                                          Text(
                                            'Aadhaar: ${att.maskedAadhaar}',
                                            style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                                          ),
                                      ],
                                    ),
                                    if (attCheckedIn && att.checkedInAt != null) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF059669)),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Checked in at ${att.checkedInAt}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF059669),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // BOTTOM ACTION BUTTON: OK ONLY (No white card container)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _resetScannerForNextScan();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                  ),
                  child: Text(
                    'OK',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetScannerForNextScan() {
    if (mounted) {
      setState(() {
        _isProcessingScan = false;
        _lastScannedCode = null;
        _lastScannedTime = null;
      });
    }
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
                          'EVENTS & SCANS',
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
              // TAB BAR HEADER
              // -------------------------------------------------
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
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
                  labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_scanner_rounded, size: 18),
                          SizedBox(width: 6),
                          Text('Pass Scan'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.badge_rounded, size: 18),
                          SizedBox(width: 6),
                          Text('View Gate Pass'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // -------------------------------------------------
              // TAB BAR VIEW
              // -------------------------------------------------
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Scanner View
                    _buildScannerTab(),

                    // Tab 2: Today's Scans List View
                    _buildTodayScansTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // TAB 1: SCANNER TAB
  // =========================================================
  Widget _buildScannerTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 4),

          // SCAN HINT TEXT ABOVE SCANNER
          Text(
            'Point camera at the Event Pass QR / Barcode',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C3E50),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Pass scan will be validated automatically upon detection',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // SCANNER CARD
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 320, maxHeight: 320),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.22),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // LIVE CAMERA PREVIEW
                      Positioned.fill(
                        child: MobileScanner(
                          controller: _scannerController,
                          onDetect: _onDetect,
                          errorBuilder: (context, error) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.camera_alt_outlined, color: Colors.white60, size: 48),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Camera Permission Needed',
                                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // LASER ANIMATION LINE
                      Positioned(
                        left: 20,
                        right: 20,
                        top: 20,
                        bottom: 20,
                        child: AnimatedBuilder(
                          animation: _laserAnimation,
                          builder: (context, child) {
                            return Align(
                              alignment: Alignment(0, _laserAnimation.value * 2 - 1),
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF38BDF8),
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF38BDF8).withValues(alpha: 0.8),
                                      blurRadius: 10,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // OVERLAY SCAN FRAME CORNERS
                      Center(
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white54, width: 1.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),

                      // SCANNING IN PROGRESS SPINNER
                      if (_isProcessingScan)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black54,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(color: Colors.white),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Processing Event Pass...',
                                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // TORCH / FLASHLIGHT BUTTON AT TOP RIGHT OF PREVIEW
                      Positioned(
                        top: 12,
                        right: 12,
                        child: IconButton(
                          icon: Icon(
                            _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                            color: _isTorchOn ? Colors.amber : Colors.white,
                            size: 22,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black45,
                            shape: const CircleBorder(),
                          ),
                          onPressed: () async {
                            await _scannerController.toggleTorch();
                            setState(() {
                              _isTorchOn = !_isTorchOn;
                            });
                          },
                          tooltip: 'Toggle Flashlight',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // CANCEL BUTTON
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: ElevatedButton.icon(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.cancel_rounded, color: Colors.white, size: 22),
                label: Text(
                  'CANCEL',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 1.1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 4,
                  shadowColor: const Color(0xFFDC2626).withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // =========================================================
  // TAB 2: TODAY'S SCANS LIST TAB
  // =========================================================
  Widget _buildTodayScansTab() {
    return Obx(() {
      if (_controller.isLoading.value && _controller.scansList.isEmpty) {
        return const DashboardShimmerSkeleton();
      }

      if (_controller.errorMessage.value.isNotEmpty && _controller.scansList.isEmpty) {
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
                const SizedBox(height: 16),
                Text(
                  isNetErr ? 'No Internet Connection' : 'Oops! Something went wrong',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
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
                  onPressed: () => _controller.fetchTodayScans(),
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                  label: Text(
                    isNetErr ? 'Retry Connection' : 'Retry',
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E54C8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final scans = _controller.filteredScans;

      return RefreshIndicator(
        color: const Color(0xFF4E54C8),
        onRefresh: () => _controller.fetchTodayScans(isManualRefresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----------------- STAT CARD BANNER -----------------
              _buildStatCard(),
              const SizedBox(height: 10),

              // ----------------- SEARCH BAR -----------------
              _buildSearchAndFilters(),
              const SizedBox(height: 12),

              // ----------------- LIST OR EMPTY STATE -----------------
              if (scans.isEmpty)
                _buildEmptyState()
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: scans.length,
                  itemBuilder: (context, index) {
                    return _buildScanItemCard(scans[index]);
                  },
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    });
  }

  // -------------------------------------------------
  // STAT CARD BANNER
  // -------------------------------------------------
  Widget _buildStatCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: Color(0xFF059669),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Valid Scans Today',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Obx(() => Text(
                      '${_controller.totalValidScansToday.value}',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                        height: 1.1,
                      ),
                    )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.event_rounded, size: 14, color: Color(0xFF4F46E5)),
                const SizedBox(width: 5),
                Text(
                  'Today',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4F46E5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // SEARCH BAR
  // -------------------------------------------------
  Widget _buildSearchAndFilters() {
    return Container(
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
        onChanged: (val) => _controller.searchQuery.value = val,
        style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF1E293B)),
        decoration: InputDecoration(
          hintText: 'Search by student name, pass no, admission no...',
          hintStyle: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF94A3B8)),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
          suffixIcon: Obx(() {
            if (_controller.searchQuery.value.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF64748B)),
                onPressed: () {
                  _searchController.clear();
                  _controller.searchQuery.value = '';
                },
              );
            }
            return const SizedBox.shrink();
          }),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  // -------------------------------------------------
  // SCAN ITEM CARD
  // -------------------------------------------------
  Widget _buildScanItemCard(EventScanItem item) {
    final status = (item.scanStatus ?? '').toLowerCase();
    final isValid = status == 'valid_entry' || status == 'valid' || status == 'success';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Pass Number & Scan Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.passNumber ?? 'N/A',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4E54C8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (item.eventTitle != null && item.eventTitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.eventTitle!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF475569),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isValid ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isValid ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isValid ? const Color(0xFF059669) : const Color(0xFFDC2626),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isValid ? 'Valid Entry' : (item.scanStatus ?? 'Unknown'),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isValid ? const Color(0xFF059669) : const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          // Student Info Row
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(Icons.person_rounded, color: Color(0xFF4E54C8), size: 20),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.studentName ?? 'Student',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 6,
                      runSpacing: 2,
                      children: [
                        if (item.admissionNo != null && item.admissionNo!.isNotEmpty)
                          Text(
                            'Adm: ${item.admissionNo}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (item.classSection != null && item.classSection!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.classSection!,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Scan Message (if present)
          if (item.scanMessage != null && item.scanMessage!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.scanMessage!,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF334155),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 8),

          // Footer Row: Gate Name, Scanned By & Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (item.gateName != null && item.gateName!.isNotEmpty)
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.door_sliding_rounded, size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.gateName!,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    item.scannedAt ?? item.scannedAtFull ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // EMPTY STATE
  // -------------------------------------------------
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFEEF2FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_seat_rounded,
              color: Color(0xFF4F46E5),
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Event Scans Today',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _controller.searchQuery.value.isNotEmpty
                ? 'No scan records match your search filter.'
                : 'There are no event pass scans recorded for today yet.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
