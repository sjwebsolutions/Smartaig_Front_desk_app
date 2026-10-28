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
  int _selectedCameraIndex = 0;
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
        // Default to front camera if available for selfie/face photo, or first camera
        int frontIdx = _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.front);
        _selectedCameraIndex = frontIdx != -1 ? frontIdx : 0;

        await _setupController(_cameras[_selectedCameraIndex]);
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

  Future<void> _toggleCamera() async {
    if (_cameras.length <= 1) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    setState(() => _isInitializing = true);
    await _setupController(_cameras[_selectedCameraIndex]);
    if (mounted) {
      setState(() => _isInitializing = false);
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                    onPressed: () => Get.back(),
                    tooltip: 'Cancel',
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.title.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (_cameras.length > 1 && _capturedImage == null)
                    IconButton(
                      icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white, size: 22),
                      onPressed: _toggleCamera,
                      tooltip: 'Switch Camera',
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),

            // Live Camera View / Captured Image Preview with Face Overlay Mask
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_capturedImage != null)
                    Image.file(
                      File(_capturedImage!.path),
                      fit: BoxFit.cover,
                    )
                  else if (_isInitializing || _cameraController == null || !_cameraController!.value.isInitialized)
                    const Center(
                      child: CircularProgressIndicator(color: Color(0xFF818CF8)),
                    )
                  else
                    CameraPreview(_cameraController!),

                  // Face Oval Overlay Mask (Visible on both Live Camera & Preview)
                  CustomPaint(
                    painter: FaceOvalOverlayPainter(),
                  ),

                  // Top Guide Message Badge
                  Positioned(
                    top: 20,
                    left: 20,
                    right: 20,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF818CF8), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.center_focus_strong_rounded, color: Color(0xFF818CF8), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _capturedImage != null
                                  ? 'Face aligned inside oval frame'
                                  : 'Align face inside the oval frame',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
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

            // Bottom Control Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: Colors.black,
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
                            border: Border.all(color: Colors.white, width: 3),
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
                            icon: const Icon(Icons.replay_rounded, color: Colors.white, size: 18),
                            label: Text(
                              'Retake',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white54, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

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
    );
  }
}

class FaceOvalOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFF818CF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final double ovalWidth = size.width * 0.72;
    final double ovalHeight = size.height * 0.52;
    final Rect ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 20),
      width: ovalWidth,
      height: ovalHeight,
    );

    // Draw transparent oval cut-out on dark background
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addOval(ovalRect),
      ),
      backgroundPaint,
    );

    // Draw Oval border
    canvas.drawOval(ovalRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
