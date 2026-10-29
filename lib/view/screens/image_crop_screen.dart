import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

enum HandleType {
  none,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  top,
  bottom,
  left,
  right,
  center,
}

class ImageCropScreen extends StatefulWidget {
  final File imageFile;
  final String title;

  const ImageCropScreen({
    super.key,
    required this.imageFile,
    this.title = 'Crop Photo',
  });

  @override
  State<ImageCropScreen> createState() => _ImageCropScreenState();
}

class _ImageCropScreenState extends State<ImageCropScreen> {
  ui.Image? _decodedImage;
  bool _isLoading = true;
  bool _isCropping = false;
  int _quarterTurns = 0;

  Size _lastDisplaySize = Size.zero;
  Rect _cropRect = Rect.zero;
  HandleType _activeHandle = HandleType.none;
  String _aspectRatioMode = '1:1'; // 'Free', '1:1', '3:4', '4:3'

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final bytes = await widget.imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      if (mounted) {
        setState(() {
          _decodedImage = frame.image;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading image for crop: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _rotateImage() {
    setState(() {
      _quarterTurns = (_quarterTurns + 1) % 4;
      _cropRect = Rect.zero; // Reset crop box for new rotation
    });
  }

  void _setAspectRatio(String mode) {
    setState(() {
      _aspectRatioMode = mode;
      if (_lastDisplaySize == Size.zero) return;

      final Size displaySize = _lastDisplaySize;
      final double minDim = displaySize.width < displaySize.height ? displaySize.width : displaySize.height;

      double cropW = displaySize.width;
      double cropH = displaySize.height;

      if (mode == '1:1') {
        cropW = minDim;
        cropH = minDim;
      } else if (mode == '3:4') {
        cropW = minDim * 0.75;
        cropH = cropW * 4 / 3;
        if (cropH > displaySize.height) {
          cropH = displaySize.height;
          cropW = cropH * 3 / 4;
        }
      } else if (mode == '4:3') {
        cropH = minDim * 0.65;
        cropW = cropH * 4 / 3;
        if (cropW > displaySize.width) {
          cropW = displaySize.width;
          cropH = cropW * 3 / 4;
        }
      } else if (mode == 'Free') {
        cropW = displaySize.width;
        cropH = displaySize.height;
      }

      final double left = (displaySize.width - cropW) / 2;
      final double top = (displaySize.height - cropH) / 2;
      _cropRect = Rect.fromLTWH(left, top, cropW, cropH);
    });
  }

  void _initCropRectIfNeeded(Size displaySize) {
    _lastDisplaySize = displaySize;
    if (_cropRect == Rect.zero || _cropRect.width > displaySize.width || _cropRect.height > displaySize.height) {
      final double minDim = displaySize.width < displaySize.height ? displaySize.width : displaySize.height;
      final double cropW = minDim * 0.85;
      final double cropH = cropW;
      final double left = (displaySize.width - cropW) / 2;
      final double top = (displaySize.height - cropH) / 2;
      _cropRect = Rect.fromLTWH(left, top, cropW, cropH);
    }
  }

  HandleType _hitTest(Offset pos, Rect rect) {
    const double touchRadius = 28.0;

    if ((pos - rect.topLeft).distance <= touchRadius) return HandleType.topLeft;
    if ((pos - rect.topRight).distance <= touchRadius) return HandleType.topRight;
    if ((pos - rect.bottomLeft).distance <= touchRadius) return HandleType.bottomLeft;
    if ((pos - rect.bottomRight).distance <= touchRadius) return HandleType.bottomRight;

    if (pos.dy >= rect.top - touchRadius && pos.dy <= rect.top + touchRadius && pos.dx >= rect.left && pos.dx <= rect.right) {
      return HandleType.top;
    }
    if (pos.dy >= rect.bottom - touchRadius && pos.dy <= rect.bottom + touchRadius && pos.dx >= rect.left && pos.dx <= rect.right) {
      return HandleType.bottom;
    }
    if (pos.dx >= rect.left - touchRadius && pos.dx <= rect.left + touchRadius && pos.dy >= rect.top && pos.dy <= rect.bottom) {
      return HandleType.left;
    }
    if (pos.dx >= rect.right - touchRadius && pos.dx <= rect.right + touchRadius && pos.dy >= rect.top && pos.dy <= rect.bottom) {
      return HandleType.right;
    }

    if (rect.contains(pos)) return HandleType.center;

    return HandleType.none;
  }

  void _onPanStart(DragStartDetails details) {
    _activeHandle = _hitTest(details.localPosition, _cropRect);
  }

  void _onPanUpdate(DragUpdateDetails details, Size displaySize) {
    if (_activeHandle == HandleType.none) return;

    final dx = details.delta.dx;
    final dy = details.delta.dy;
    const minSize = 60.0;

    double left = _cropRect.left;
    double top = _cropRect.top;
    double right = _cropRect.right;
    double bottom = _cropRect.bottom;

    switch (_activeHandle) {
      case HandleType.topLeft:
        left += dx;
        top += dy;
        break;
      case HandleType.topRight:
        right += dx;
        top += dy;
        break;
      case HandleType.bottomLeft:
        left += dx;
        bottom += dy;
        break;
      case HandleType.bottomRight:
        right += dx;
        bottom += dy;
        break;
      case HandleType.top:
        top += dy;
        break;
      case HandleType.bottom:
        bottom += dy;
        break;
      case HandleType.left:
        left += dx;
        break;
      case HandleType.right:
        right += dx;
        break;
      case HandleType.center:
        left += dx;
        right += dx;
        top += dy;
        bottom += dy;
        break;
      case HandleType.none:
        break;
    }

    // Fixed aspect ratio handling if 1:1 selected
    if (_aspectRatioMode == '1:1' && _activeHandle != HandleType.center) {
      final w = right - left;
      final h = bottom - top;
      final side = w > h ? w : h;

      if (_activeHandle == HandleType.bottomRight) {
        right = left + side;
        bottom = top + side;
      } else if (_activeHandle == HandleType.topLeft) {
        left = right - side;
        top = bottom - side;
      } else if (_activeHandle == HandleType.topRight) {
        right = left + side;
        top = bottom - side;
      } else if (_activeHandle == HandleType.bottomLeft) {
        left = right - side;
        bottom = top + side;
      }
    }

    // Clamp inside display area
    if (left < 0) {
      if (_activeHandle == HandleType.center) right -= left;
      left = 0;
    }
    if (top < 0) {
      if (_activeHandle == HandleType.center) bottom -= top;
      top = 0;
    }
    if (right > displaySize.width) {
      if (_activeHandle == HandleType.center) left -= (right - displaySize.width);
      right = displaySize.width;
    }
    if (bottom > displaySize.height) {
      if (_activeHandle == HandleType.center) top -= (bottom - displaySize.height);
      bottom = displaySize.height;
    }

    if (right - left < minSize) {
      if (_activeHandle == HandleType.left || _activeHandle == HandleType.topLeft || _activeHandle == HandleType.bottomLeft) {
        left = right - minSize;
      } else {
        right = left + minSize;
      }
    }
    if (bottom - top < minSize) {
      if (_activeHandle == HandleType.top || _activeHandle == HandleType.topLeft || _activeHandle == HandleType.topRight) {
        top = bottom - minSize;
      } else {
        bottom = top + minSize;
      }
    }

    setState(() {
      _cropRect = Rect.fromLTRB(left, top, right, bottom);
    });
  }

  Future<void> _cropAndSave(Size displaySize) async {
    if (_isCropping || _decodedImage == null) return;
    setState(() => _isCropping = true);

    try {
      ui.Image srcImage = _decodedImage!;

      // Handle image rotation
      if (_quarterTurns % 4 != 0) {
        final int turns = _quarterTurns % 4;
        final bool swap = turns == 1 || turns == 3;
        final int targetW = swap ? srcImage.height : srcImage.width;
        final int targetH = swap ? srcImage.width : srcImage.height;

        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, targetW.toDouble(), targetH.toDouble()));

        canvas.translate(targetW / 2, targetH / 2);
        canvas.rotate(turns * 1.5707963267948966);
        canvas.translate(-srcImage.width / 2, -srcImage.height / 2);
        canvas.drawImage(srcImage, Offset.zero, Paint()..filterQuality = ui.FilterQuality.high);

        final picture = recorder.endRecording();
        srcImage = await picture.toImage(targetW, targetH);
      }

      final double scaleX = srcImage.width / displaySize.width;
      final double scaleY = srcImage.height / displaySize.height;

      final double srcLeft = (_cropRect.left * scaleX).clamp(0.0, srcImage.width.toDouble());
      final double srcTop = (_cropRect.top * scaleY).clamp(0.0, srcImage.height.toDouble());
      final double srcWidth = (_cropRect.width * scaleX).clamp(1.0, srcImage.width - srcLeft);
      final double srcHeight = (_cropRect.height * scaleY).clamp(1.0, srcImage.height - srcTop);

      final srcRect = Rect.fromLTWH(srcLeft, srcTop, srcWidth, srcHeight);
      final dstRect = Rect.fromLTWH(0, 0, srcWidth, srcHeight);

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, dstRect);
      final paint = Paint()..filterQuality = ui.FilterQuality.high;

      canvas.drawImageRect(srcImage, srcRect, dstRect, paint);

      final picture = recorder.endRecording();
      final ui.Image croppedUiImage = await picture.toImage(srcWidth.toInt(), srcHeight.toInt());
      final byteData = await croppedUiImage.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        Get.back();
        return;
      }

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = Directory.systemTemp;
      final filePath = '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.png';
      final croppedFile = File(filePath);
      await croppedFile.writeAsBytes(pngBytes);

      Get.back(result: XFile(croppedFile.path));
    } catch (e) {
      debugPrint('Error cropping image: $e');
      Get.back();
    } finally {
      if (mounted) {
        setState(() => _isCropping = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

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
              // Top Bar
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

              // Subtitle Guidance
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Drag corners to resize or move crop box',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475569),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 10),

              // Image Crop Interactive Area
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final double rawW = _decodedImage!.width.toDouble();
                          final double rawH = _decodedImage!.height.toDouble();

                          final bool swap = _quarterTurns % 2 != 0;
                          final double imgW = swap ? rawH : rawW;
                          final double imgH = swap ? rawW : rawH;

                          final double containerW = constraints.maxWidth - 32;
                          final double containerH = constraints.maxHeight - 16;

                          final double imgAspect = imgW / imgH;
                          final double containerAspect = containerW / containerH;

                          double displayW, displayH;
                          if (imgAspect > containerAspect) {
                            displayW = containerW;
                            displayH = containerW / imgAspect;
                          } else {
                            displayH = containerH;
                            displayW = containerH * imgAspect;
                          }

                          final displaySize = Size(displayW, displayH);
                          _initCropRectIfNeeded(displaySize);

                          return Center(
                            child: Container(
                              width: displayW,
                              height: displayH,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  children: [
                                    // Display Image
                                    Positioned.fill(
                                      child: RotatedBox(
                                        quarterTurns: _quarterTurns,
                                        child: Image.file(
                                          widget.imageFile,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),

                                    // Draggable Crop Box Overlay
                                    Positioned.fill(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onPanStart: _onPanStart,
                                        onPanUpdate: (details) => _onPanUpdate(details, displaySize),
                                        child: CustomPaint(
                                          painter: CropOverlayPainter(
                                            cropRect: _cropRect,
                                            displaySize: displaySize,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 10),

              // Ratio Presets & Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildRatioChip('1:1', '1:1', () => _setAspectRatio('1:1')),
                      _buildRatioChip('3:4', '3:4', () => _setAspectRatio('3:4')),
                      _buildRatioChip('Free', 'Free', () => _setAspectRatio('Free')),
                      InkWell(
                        onTap: _rotateImage,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.rotate_right_rounded, color: Color(0xFF4F46E5), size: 20),
                              Text(
                                'Rotate',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Bottom Action Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF4F46E5), width: 1.8),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isCropping
                            ? null
                            : () {
                                final double containerW = screenSize.width - 32;
                                final double containerH = screenSize.height * 0.55;
                                final double rawW = _decodedImage?.width.toDouble() ?? 100;
                                final double rawH = _decodedImage?.height.toDouble() ?? 100;
                                final bool swap = _quarterTurns % 2 != 0;
                                final double imgW = swap ? rawH : rawW;
                                final double imgH = swap ? rawW : rawH;
                                final double imgAspect = imgW / imgH;
                                final double containerAspect = containerW / containerH;

                                double displayW, displayH;
                                if (imgAspect > containerAspect) {
                                  displayW = containerW;
                                  displayH = containerW / imgAspect;
                                } else {
                                  displayH = containerH;
                                  displayW = containerH * imgAspect;
                                }

                                _cropAndSave(Size(displayW, displayH));
                              },
                        icon: _isCropping
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.crop_rounded, color: Colors.white, size: 20),
                        label: Text(
                          _isCropping ? 'Cropping...' : 'Save',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
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

  Widget _buildRatioChip(String label, String mode, VoidCallback onTap) {
    final bool isSelected = _aspectRatioMode == mode;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}

class CropOverlayPainter extends CustomPainter {
  final Rect cropRect;
  final Size displaySize;

  CropOverlayPainter({
    required this.cropRect,
    required this.displaySize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (cropRect == Rect.zero) return;

    // 1. Semi-transparent dark background outside cropRect
    final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.55);

    // Top block
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, cropRect.top), bgPaint);
    // Bottom block
    canvas.drawRect(Rect.fromLTRB(0, cropRect.bottom, size.width, size.height), bgPaint);
    // Left block
    canvas.drawRect(Rect.fromLTRB(0, cropRect.top, cropRect.left, cropRect.bottom), bgPaint);
    // Right block
    canvas.drawRect(Rect.fromLTRB(cropRect.right, cropRect.top, size.width, cropRect.bottom), bgPaint);

    // 2. White border for crop rect
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(cropRect, borderPaint);

    // 3. Grid lines inside cropRect (Rule of thirds)
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final w = cropRect.width;
    final h = cropRect.height;

    canvas.drawLine(Offset(cropRect.left + w / 3, cropRect.top), Offset(cropRect.left + w / 3, cropRect.bottom), gridPaint);
    canvas.drawLine(Offset(cropRect.left + (w / 3) * 2, cropRect.top), Offset(cropRect.left + (w / 3) * 2, cropRect.bottom), gridPaint);
    canvas.drawLine(Offset(cropRect.left, cropRect.top + h / 3), Offset(cropRect.right, cropRect.top + h / 3), gridPaint);
    canvas.drawLine(Offset(cropRect.left, cropRect.top + (h / 3) * 2), Offset(cropRect.right, cropRect.top + (h / 3) * 2), gridPaint);

    // 4. Corner Handles (L-shaped thick accents)
    final cornerPaint = Paint()
      ..color = const Color(0xFF4F46E5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    const cornerLength = 22.0;

    // Top-Left
    canvas.drawLine(cropRect.topLeft, cropRect.topLeft + const Offset(cornerLength, 0), cornerPaint);
    canvas.drawLine(cropRect.topLeft, cropRect.topLeft + const Offset(0, cornerLength), cornerPaint);

    // Top-Right
    canvas.drawLine(cropRect.topRight, cropRect.topRight + const Offset(-cornerLength, 0), cornerPaint);
    canvas.drawLine(cropRect.topRight, cropRect.topRight + const Offset(0, cornerLength), cornerPaint);

    // Bottom-Left
    canvas.drawLine(cropRect.bottomLeft, cropRect.bottomLeft + const Offset(cornerLength, 0), cornerPaint);
    canvas.drawLine(cropRect.bottomLeft, cropRect.bottomLeft + const Offset(0, -cornerLength), cornerPaint);

    // Bottom-Right
    canvas.drawLine(cropRect.bottomRight, cropRect.bottomRight + const Offset(-cornerLength, 0), cornerPaint);
    canvas.drawLine(cropRect.bottomRight, cropRect.bottomRight + const Offset(0, -cornerLength), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CropOverlayPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect || oldDelegate.displaySize != displaySize;
  }
}
