import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LiveFaceCameraScreen extends StatefulWidget {
  final String title;

  const LiveFaceCameraScreen({
    super.key,
    required this.title,
  });

  @override
  State<LiveFaceCameraScreen> createState() => _LiveFaceCameraScreenState();
}

class _LiveFaceCameraScreenState extends State<LiveFaceCameraScreen> {
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  bool _isInitializing = true;
  bool _isCapturing = false;
  XFile? _capturedImage;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        // Strictly select Back Camera
        int backIdx = _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.back);
        int selectedIndex = backIdx != -1 ? backIdx : 0;

        await _setupController(_cameras[selectedIndex]);
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _setupController(CameraDescription camera) async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }

    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _cameraController!.initialize();
    } catch (e) {
      debugPrint('Error setting up camera controller: $e');
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isCapturing) {
      return;
    }

    try {
      setState(() => _isCapturing = true);
      final photo = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = photo;
      });
    } catch (e) {
      debugPrint('Error taking picture: $e');
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  void _resetCapturedPhoto() {
    setState(() {
      _capturedImage = null;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

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
              // Top App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
                          widget.title.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C3E50),
                            letterSpacing: 0.8,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 32),
                  ],
                ),
              ),

              // Live Camera Card Container behind Person Dummy with Reduced Height & Bold Border Line
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      height: screenHeight * 0.54,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF4F46E5),
                          width: 3.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.5),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (_capturedImage != null)
                              Image.file(
                                File(_capturedImage!.path),
                                fit: BoxFit.cover,
                              )
                            else if (_isInitializing || _cameraController == null || !_cameraController!.value.isInitialized)
                              Container(
                                color: Colors.black,
                                child: const Center(
                                  child: CircularProgressIndicator(color: Color(0xFF818CF8)),
                                ),
                              )
                            else
                              SizedBox.expand(
                                child: FittedBox(
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                    width: _cameraController!.value.previewSize?.height ?? 100,
                                    height: _cameraController!.value.previewSize?.width ?? 100,
                                    child: CameraPreview(_cameraController!),
                                  ),
                                ),
                              ),

                            // BOLD Head & Shoulders Silhouette Overlay & 2 Vertical / 2 Horizontal Grid Lines
                            CustomPaint(
                              painter: FaceHeadShouldersOverlayPainter(),
                            ),

                            // Top Guide Message Badge
                            Positioned(
                              top: 14,
                              left: 12,
                              right: 12,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white, width: 1.5),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.person_pin_rounded, color: Colors.white, size: 18),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          _capturedImage != null
                                              ? 'Face aligned inside silhouette'
                                              : 'Align face & shoulders inside outline',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
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

              // Bottom Control Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: _capturedImage == null
                    ? Center(
                        child: GestureDetector(
                          onTap: _isCapturing ? null : _takePicture,
                          child: Container(
                            width: 72,
                            height: 72,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF4F46E5), width: 3.5),
                              color: Colors.white,
                            ),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFF4F46E5),
                                shape: BoxShape.circle,
                              ),
                              child: _isCapturing
                                  ? const Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                      ),
                                    )
                                  : const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 30),
                            ),
                          ),
                        ),
                      )
                    : Row(
                        children: [
                          // Retake
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _resetCapturedPhoto,
                              icon: const Icon(Icons.replay_rounded, color: Color(0xFF4F46E5), size: 18),
                              label: Text(
                                'Retake',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF4F46E5),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: Color(0xFF4F46E5), width: 2.0),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Use Photo
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Get.back(result: _capturedImage);
                              },
                              icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                              label: Text(
                                'Use Photo',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FaceHeadShouldersOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h * 0.42;

    // BOLD Outline Paint
    final Paint outlinePaint = Paint()
      ..color = const Color(0xFF29B6F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // BOLD Shadow Paint
    final Paint shadowPaint = Paint()
      ..color = const Color(0xFF071B35).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // BOLD Grid Paint
    final Paint gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // -------------------------------------------------------------
    // 2 VERTICAL & 2 HORIZONTAL BOLD GRID LINES
    // -------------------------------------------------------------
    // 2 Vertical Lines
    canvas.drawLine(Offset(w / 3, 0), Offset(w / 3, h), gridPaint);
    canvas.drawLine(Offset((w / 3) * 2, 0), Offset((w / 3) * 2, h), gridPaint);

    // 2 Horizontal Lines
    canvas.drawLine(Offset(0, h / 3), Offset(w, h / 3), gridPaint);
    canvas.drawLine(Offset(0, (h / 3) * 2), Offset(w, (h / 3) * 2), gridPaint);

    // Head outline
    final Path head = Path()
      ..moveTo(cx, cy - h * 0.22)
      ..cubicTo(cx + w * 0.06, cy - h * 0.25,
          cx + w * 0.13, cy - h * 0.22,
          cx + w * 0.16, cy - h * 0.18)
      ..lineTo(cx + w * 0.12, cy - h * 0.19)
      ..cubicTo(cx + w * 0.20, cy - h * 0.17,
          cx + w * 0.22, cy - h * 0.10,
          cx + w * 0.21, cy - h * 0.05)
    // Right ear
      ..cubicTo(cx + w * 0.27, cy - h * 0.06,
          cx + w * 0.26, cy + h * 0.02,
          cx + w * 0.20, cy + h * 0.03)
    // Right jaw
      ..cubicTo(cx + w * 0.17, cy + h * 0.11,
          cx + w * 0.09, cy + h * 0.16,
          cx, cy + h * 0.16)
    // Left jaw
      ..cubicTo(cx - w * 0.09, cy + h * 0.16,
          cx - w * 0.17, cy + h * 0.11,
          cx - w * 0.20, cy + h * 0.03)
    // Left ear
      ..cubicTo(cx - w * 0.26, cy + h * 0.02,
          cx - w * 0.27, cy - h * 0.06,
          cx - w * 0.21, cy - h * 0.05)
      ..cubicTo(cx - w * 0.22, cy - h * 0.10,
          cx - w * 0.19, cy - h * 0.17,
          cx - w * 0.12, cy - h * 0.19)
      ..lineTo(cx - w * 0.16, cy - h * 0.18)
      ..cubicTo(cx - w * 0.11, cy - h * 0.23,
          cx - w * 0.04, cy - h * 0.23,
          cx, cy - h * 0.22);

    // Neck and shoulders
    final Path body = Path()
      ..moveTo(cx - w * 0.13, cy + h * 0.13)
      ..cubicTo(cx - w * 0.13, cy + h * 0.20,
          cx - w * 0.16, cy + h * 0.22,
          cx - w * 0.25, cy + h * 0.25)
      ..cubicTo(cx - w * 0.38, cy + h * 0.30,
          cx - w * 0.43, cy + h * 0.33,
          cx - w * 0.43, cy + h * 0.38);

    body
      ..moveTo(cx + w * 0.13, cy + h * 0.13)
      ..cubicTo(cx + w * 0.13, cy + h * 0.20,
          cx + w * 0.16, cy + h * 0.22,
          cx + w * 0.25, cy + h * 0.25)
      ..cubicTo(cx + w * 0.38, cy + h * 0.30,
          cx + w * 0.43, cy + h * 0.33,
          cx + w * 0.43, cy + h * 0.38);

    // T-shirt neckline
    final Path neckline = Path()
      ..moveTo(cx - w * 0.20, cy + h * 0.27)
      ..quadraticBezierTo(cx, cy + h * 0.37,
          cx + w * 0.20, cy + h * 0.27);

    // Bottom horizontal base line
    final Path bottomLine = Path()
      ..moveTo(cx - w * 0.43, cy + h * 0.38)
      ..lineTo(cx + w * 0.43, cy + h * 0.38);

    for (final path in [head, body, neckline, bottomLine]) {
      canvas.drawPath(path, shadowPaint);
      canvas.drawPath(path, outlinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant FaceHeadShouldersOverlayPainter oldDelegate) {
    return false;
  }
}
