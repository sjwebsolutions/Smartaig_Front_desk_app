import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class FaceGuidePreviewScreen extends StatefulWidget {
  final XFile initialImage;
  final String title;

  const FaceGuidePreviewScreen({
    super.key,
    required this.initialImage,
    required this.title,
  });

  @override
  State<FaceGuidePreviewScreen> createState() => _FaceGuidePreviewScreenState();
}

class _FaceGuidePreviewScreenState extends State<FaceGuidePreviewScreen> {
  late XFile _currentImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _currentImage = widget.initialImage;
  }

  Future<void> _retakePhoto() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (picked != null) {
        setState(() {
          _currentImage = picked;
        });
      }
    } catch (_) {}
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
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Image Preview with Face Oval Mask Overlay
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Captured Image
                  Image.file(
                    File(_currentImage.path),
                    fit: BoxFit.cover,
                  ),

                  // Face Oval Overlay Mask
                  CustomPaint(
                    painter: FaceOvalOverlayPainter(),
                  ),

                  // Guide Message Banner at top of Oval
                  Positioned(
                    top: 24,
                    left: 20,
                    right: 20,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black70,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF818CF8), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.center_focus_strong_rounded, color: Color(0xFF818CF8), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Center face inside the oval frame',
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

            // Bottom Actions Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              color: Colors.black,
              child: Row(
                children: [
                  // Retake Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _retakePhoto,
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

                  // Confirm / Use Photo Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back(result: _currentImage);
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
      color = Colors.black.withValues(alpha: 0.55)
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

    final Path path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(ovalRect);

    // Draw transparent oval cut-out on dark background
    canvas.drawPath(
      Path.combine(PathOperation.difference, Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)), Path()..addOval(ovalRect)),
      backgroundPaint,
    );

    // Draw Oval border
    canvas.drawOval(ovalRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
