import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfinityLoader extends StatefulWidget {
  final String text;
  final double width;
  final double height;
  final Color primaryColor;
  final Color secondaryColor;
  final Color textColor;

  const InfinityLoader({
    super.key,
    this.text = 'Loading...',
    this.width = 120,
    this.height = 60,
    this.primaryColor = const Color(0xFF4F46E5), // Vibrant Electric Indigo
    this.secondaryColor = const Color(0xFF0284C7), // Vibrant Cyan Blue
    this.textColor = const Color(0xFF2C3E50),
  });

  @override
  State<InfinityLoader> createState() => _InfinityLoaderState();
}

class _InfinityLoaderState extends State<InfinityLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size(widget.width, widget.height),
              painter: _InfinityPainter(
                progress: _controller.value,
                primaryColor: widget.primaryColor,
                secondaryColor: widget.secondaryColor,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          widget.text,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: widget.textColor,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

class _InfinityPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color secondaryColor;

  _InfinityPainter({
    required this.progress,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scaleX = (size.width / 2) * 0.85;
    final scaleY = (size.height / 2) * 0.85;

    // 1. Draw Background Track
    final trackPath = Path();
    const steps = 120;
    for (int i = 0; i <= steps; i++) {
      final t = (i / steps) * 2 * math.pi;
      final point = _getLemniscatePoint(t, center, scaleX, scaleY);
      if (i == 0) {
        trackPath.moveTo(point.dx, point.dy);
      } else {
        trackPath.lineTo(point.dx, point.dy);
      }
    }

    final trackPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(trackPath, trackPaint);

    // 2. Draw Animated Glowing Gradient Trail
    final headT = progress * 2 * math.pi;
    const trailSteps = 50;
    const trailSpan = math.pi * 1.1; // Length of glowing tail

    for (int i = trailSteps; i >= 0; i--) {
      final stepFraction = i / trailSteps;
      final t = headT - (stepFraction * trailSpan);
      final point = _getLemniscatePoint(t, center, scaleX, scaleY);

      final fade = 1.0 - stepFraction; // 1.0 at head, 0.0 at tail end
      final alpha = (fade * fade).clamp(0.0, 1.0); // Quadratic fade

      if (alpha <= 0.01) continue;

      // Smooth color transition along the loop (Indigo -> Cyan)
      final normalizedT = (t % (2 * math.pi)) / (2 * math.pi);
      final currentColor = Color.lerp(primaryColor, secondaryColor, (math.sin(normalizedT * math.pi * 2) + 1) / 2)!;

      // Outer Glow Aura
      final auraPaint = Paint()
        ..color = currentColor.withValues(alpha: 0.5 * alpha)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6.0 * alpha + 1.0);

      canvas.drawCircle(point, 4.5 * alpha + 1.5, auraPaint);

      // Core Light
      final corePaint = Paint()
        ..color = Color.lerp(currentColor, Colors.white, fade * 0.7)!.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(point, 2.2 * alpha + 0.5, corePaint);
    }

    // 3. Draw Leading Head Sparkle Point
    final headPoint = _getLemniscatePoint(headT, center, scaleX, scaleY);

    final headGlowPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    canvas.drawCircle(headPoint, 8.0, headGlowPaint);

    final headCenterPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(headPoint, 3.5, headCenterPaint);
  }

  Offset _getLemniscatePoint(double t, Offset center, double scaleX, double scaleY) {
    final denom = 1 + math.sin(t) * math.sin(t);
    final x = (scaleX * math.cos(t)) / denom;
    final y = (scaleY * math.sin(t) * math.cos(t)) / denom;
    return Offset(center.dx + x, center.dy + y);
  }

  @override
  bool shouldRepaint(covariant _InfinityPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}
