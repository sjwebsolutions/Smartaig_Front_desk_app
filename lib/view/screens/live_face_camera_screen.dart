import 'dart:io';
import 'dart:ui' as ui;
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

  Future<XFile> _cropImageToBoxAspect(XFile photo, double targetAspectRatio) async {
    try {
      final bytes = await File(photo.path).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frameInfo = await codec.getNextFrame();
      final image = frameInfo.image;

      final double imgW = image.width.toDouble();
      final double imgH = image.height.toDouble();
      final double imgAspect = imgW / imgH;

      double cropW, cropH, cropX, cropY;

      if (imgAspect > targetAspectRatio) {
        cropH = imgH;
        cropW = imgH * targetAspectRatio;
        cropX = (imgW - cropW) / 2;
        cropY = 0;
      } else {
        cropW = imgW;
        cropH = imgW / targetAspectRatio;
        cropX = 0;
        cropY = (imgH - cropH) / 2;
      }

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, cropW, cropH));
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(cropX, cropY, cropW, cropH),
        Rect.fromLTWH(0, 0, cropW, cropH),
        Paint()..filterQuality = FilterQuality.high,
      );

      final picture = recorder.endRecording();
      final croppedUiImage = await picture.toImage(cropW.toInt(), cropH.toInt());
      final byteData = await croppedUiImage.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) return photo;

      final tempDir = await Directory.systemTemp.createTemp();
      final croppedFile = File('${tempDir.path}/cropped_face_${DateTime.now().millisecondsSinceEpoch}.png');
      await croppedFile.writeAsBytes(byteData.buffer.asUint8List());

      return XFile(croppedFile.path);
    } catch (e) {
      debugPrint('Error cropping photo: $e');
      return photo;
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isCapturing) {
      return;
    }

    try {
      setState(() => _isCapturing = true);

      final mediaQuery = MediaQuery.of(context);
      final boxWidth = mediaQuery.size.width - 32;
      final boxHeight = mediaQuery.size.height * 0.32;
      final targetAspectRatio = boxWidth / boxHeight;

      final photo = await _cameraController!.takePicture();

      final croppedPhoto = await _cropImageToBoxAspect(photo, targetAspectRatio);

      if (mounted) {
        setState(() {
          _capturedImage = croppedPhoto;
        });
      }
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

              // Top Guide Message Badge (Outside Camera Box)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 2, bottom: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person_pin_rounded, color: Color(0xFF4F46E5), size: 18),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _capturedImage != null
                              ? 'Face aligned inside silhouette'
                              : 'Align face & shoulders inside outline',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C3E50),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Live Camera Card Container behind Person Dummy with Reduced Height & Bold Border Line
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      height: screenHeight * 0.36,
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Bottom Control Bar
              Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 14, right: 14),
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
    final double cy = h * 0.50; /// person ke uper space kam
    const double scaleX = 0.95; /// person ka width kam
    const double scaleY = 1.25;

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
      ..moveTo(cx, cy - h * 0.22 * scaleY)
      ..cubicTo(cx + w * 0.06 * scaleX, cy - h * 0.25 * scaleY,
          cx + w * 0.13 * scaleX, cy - h * 0.22 * scaleY,
          cx + w * 0.16 * scaleX, cy - h * 0.18 * scaleY)
      ..lineTo(cx + w * 0.12 * scaleX, cy - h * 0.19 * scaleY)
      ..cubicTo(cx + w * 0.20 * scaleX, cy - h * 0.17 * scaleY,
          cx + w * 0.22 * scaleX, cy - h * 0.10 * scaleY,
          cx + w * 0.21 * scaleX, cy - h * 0.05 * scaleY)
    // Right ear
      ..cubicTo(cx + w * 0.27 * scaleX, cy - h * 0.06 * scaleY,
          cx + w * 0.26 * scaleX, cy + h * 0.02 * scaleY,
          cx + w * 0.20 * scaleX, cy + h * 0.03 * scaleY)
    // Right jaw
      ..cubicTo(cx + w * 0.17 * scaleX, cy + h * 0.11 * scaleY,
          cx + w * 0.09 * scaleX, cy + h * 0.16 * scaleY,
          cx, cy + h * 0.16 * scaleY)
    // Left jaw
      ..cubicTo(cx - w * 0.09 * scaleX, cy + h * 0.16 * scaleY,
          cx - w * 0.17 * scaleX, cy + h * 0.11 * scaleY,
          cx - w * 0.20 * scaleX, cy + h * 0.03 * scaleY)
    // Left ear
      ..cubicTo(cx - w * 0.26 * scaleX, cy + h * 0.02 * scaleY,
          cx - w * 0.27 * scaleX, cy - h * 0.06 * scaleY,
          cx - w * 0.21 * scaleX, cy - h * 0.05 * scaleY)
      ..cubicTo(cx - w * 0.22 * scaleX, cy - h * 0.10 * scaleY,
          cx - w * 0.19 * scaleX, cy - h * 0.17 * scaleY,
          cx - w * 0.12 * scaleX, cy - h * 0.19 * scaleY)
      ..lineTo(cx - w * 0.16 * scaleX, cy - h * 0.18 * scaleY)
      ..cubicTo(cx - w * 0.11 * scaleX, cy - h * 0.23 * scaleY,
          cx - w * 0.04 * scaleX, cy - h * 0.23 * scaleY,
          cx, cy - h * 0.22 * scaleY);

    // Neck and shoulders
    final Path body = Path()
      ..moveTo(cx - w * 0.13 * scaleX, cy + h * 0.13 * scaleY)
      ..cubicTo(cx - w * 0.13 * scaleX, cy + h * 0.20 * scaleY,
          cx - w * 0.16 * scaleX, cy + h * 0.22 * scaleY,
          cx - w * 0.25 * scaleX, cy + h * 0.25 * scaleY)
      ..cubicTo(cx - w * 0.38 * scaleX, cy + h * 0.30 * scaleY,
          cx - w * 0.43 * scaleX, cy + h * 0.33 * scaleY,
          cx - w * 0.43 * scaleX, cy + h * 0.38 * scaleY);

    body
      ..moveTo(cx + w * 0.13 * scaleX, cy + h * 0.13 * scaleY)
      ..cubicTo(cx + w * 0.13 * scaleX, cy + h * 0.20 * scaleY,
          cx + w * 0.16 * scaleX, cy + h * 0.22 * scaleY,
          cx + w * 0.25 * scaleX, cy + h * 0.25 * scaleY)
      ..cubicTo(cx + w * 0.38 * scaleX, cy + h * 0.30 * scaleY,
          cx + w * 0.43 * scaleX, cy + h * 0.33 * scaleY,
          cx + w * 0.43 * scaleX, cy + h * 0.38 * scaleY);

    // T-shirt neckline
    final Path neckline = Path()
      ..moveTo(cx - w * 0.20 * scaleX, cy + h * 0.27 * scaleY)
      ..quadraticBezierTo(cx, cy + h * 0.37 * scaleY,
          cx + w * 0.20 * scaleX, cy + h * 0.27 * scaleY);

    // Bottom horizontal base line
    final Path bottomLine = Path()
      ..moveTo(cx - w * 0.43 * scaleX, cy + h * 0.38 * scaleY)
      ..lineTo(cx + w * 0.43 * scaleX, cy + h * 0.38 * scaleY);

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
