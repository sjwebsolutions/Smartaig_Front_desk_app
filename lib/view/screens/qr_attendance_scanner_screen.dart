import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../view_models/get_x/scan_attendance_controller.dart';

class QrAttendanceScannerScreen extends StatefulWidget {
  const QrAttendanceScannerScreen({super.key});

  @override
  State<QrAttendanceScannerScreen> createState() => _QrAttendanceScannerScreenState();
}

class _QrAttendanceScannerScreenState extends State<QrAttendanceScannerScreen>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController _scannerController;
  final ScanAttendanceController _attendanceController =
      Get.isRegistered<ScanAttendanceController>()
          ? Get.find<ScanAttendanceController>()
          : Get.put(ScanAttendanceController());

  late AnimationController _animController;
  late Animation<double> _laserAnimation;

  bool _isProcessing = false;
  String? _lastScannedCode;
  DateTime? _lastScannedTime;

  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue?.trim();
    if (rawValue == null || rawValue.isEmpty) return;

    // Prevent immediate duplicate scans within 3 seconds for the exact same payload
    final now = DateTime.now();
    if (_lastScannedCode == rawValue &&
        _lastScannedTime != null &&
        now.difference(_lastScannedTime!).inSeconds < 3) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _lastScannedCode = rawValue;
      _lastScannedTime = now;
    });

    HapticFeedback.mediumImpact();

    try {
      await _attendanceController.scanQrAttendance(rawValue);
    } catch (e) {
      debugPrint('⚠️ [QrScannerScreen onDetect error]: $e');
    } finally {
      // Allow next scan after 2 seconds
      await Future.delayed(const Duration(milliseconds: 2000));
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
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
              Color(0xFFD1E9FF), // Light Blue (same as all screens)
              Color(0xFFE9D5FF), // Light Purple (same as all screens)
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. TOP APP BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    IconButton(
                      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF2C3E50),
                        size: 18,
                      ),
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
                          'SCAN ATTENDANCE',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C3E50),
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balances back icon to keep title centered
                  ],
                ),
              ),

            SizedBox(height: 50,),

              // 2. SQUARE CAMERA SCANNER CARD
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
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
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Please allow camera permission in settings.',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            // SCANNER VIEW HIGHLIGHT & LASER OVERLAY
                            Positioned.fill(
                              child: _buildScannerOverlay(),
                            ),

                            // TORCH BUTTON (INSIDE SCANNER TOP-RIGHT)
                            Positioned(
                              top: 14,
                              right: 14,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    await _scannerController.toggleTorch();
                                    setState(() {
                                      _isTorchOn = !_isTorchOn;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _isTorchOn
                                          ? const Color(0xFFFACC15).withValues(alpha: 0.95)
                                          : Colors.black.withValues(alpha: 0.6),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _isTorchOn ? const Color(0xFFFACC15) : Colors.white70,
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        if (_isTorchOn)
                                          BoxShadow(
                                            color: const Color(0xFFFACC15).withValues(alpha: 0.6),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                      ],
                                    ),
                                    child: Icon(
                                      _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                                      color: _isTorchOn ? Colors.black : Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // PROCESSING LOADER OVERLAY
                            if (_isProcessing)
                              Positioned.fill(
                                child: Container(
                                  color: Colors.black54,
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(
                                          width: 32,
                                          height: 32,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            color: Color(0xFF22C55E),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Marking Attendance...',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
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

              const SizedBox(height: 16),

              // INSTRUCTION SUBTITLE
              Text(
                'Align QR code inside the frame to scan',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF475569),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),

            SizedBox(height: 20,),
              // 3. RED CANCEL BUTTON (PLACED HIGHER UP WITH ICON BEFORE TEXT)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626), // Vibrant Red
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: const Color(0xFFDC2626).withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cancel_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 36), // Higher position from bottom
            ],
          ),
        ),
      ),
    );
  }

  // Scanner Viewfinder Overlay with Animated Laser Line
  Widget _buildScannerOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxSize = constraints.maxWidth;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Top-Left Corner
            Positioned(
              top: 16,
              left: 16,
              child: _buildCorner(isTop: true, isLeft: true),
            ),
            // Top-Right Corner
            Positioned(
              top: 16,
              right: 16,
              child: _buildCorner(isTop: true, isLeft: false),
            ),
            // Bottom-Left Corner
            Positioned(
              bottom: 16,
              left: 16,
              child: _buildCorner(isTop: false, isLeft: true),
            ),
            // Bottom-Right Corner
            Positioned(
              bottom: 16,
              right: 16,
              child: _buildCorner(isTop: false, isLeft: false),
            ),

            // Animated Laser Line
            AnimatedBuilder(
              animation: _laserAnimation,
              builder: (context, child) {
                return Positioned(
                  top: _laserAnimation.value * (boxSize - 60) + 30,
                  left: 24,
                  right: 24,
                  child: Container(
                    height: 2.5,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Colors.transparent,
                          Color(0xFF22C55E),
                          Color(0xFF4ADE80),
                          Color(0xFF22C55E),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF22C55E).withValues(alpha: 0.8),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCorner({required bool isTop, required bool isLeft}) {
    const size = 30.0;
    const thickness = 4.0;
    const radius = 16.0;
    const color = Color(0xFF22C55E);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: color, width: thickness) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: color, width: thickness) : BorderSide.none,
          left: isLeft ? const BorderSide(color: color, width: thickness) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: color, width: thickness) : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: isTop && isLeft ? const Radius.circular(radius) : Radius.zero,
          topRight: isTop && !isLeft ? const Radius.circular(radius) : Radius.zero,
          bottomLeft: !isTop && isLeft ? const Radius.circular(radius) : Radius.zero,
          bottomRight: !isTop && !isLeft ? const Radius.circular(radius) : Radius.zero,
        ),
      ),
    );
  }
}
