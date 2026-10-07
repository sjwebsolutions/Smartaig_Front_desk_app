import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfinityLoader extends StatefulWidget {
  final String text;
  final double width;
  final double height;
  final Color glowColor;

  const InfinityLoader({
    super.key,
    this.text = 'Loading...',
    this.width = 120,
    this.height = 60,
    this.glowColor = const Color(0xFF8B5CF6),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFF090714),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.glowColor.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.glowColor.withValues(alpha: 0.2),
            blurRadius: 25,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.width, widget.height),
                painter: _InfinityPainter(
                  progress: _controller.value,
                  glowColor: widget.glowColor,
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          Text(
            widget.text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFCBD5E1),
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfinityPainter extends CustomPainter {
  final double progress;
  final Color glowColor;

  _InfinityPainter({
    required this.progress,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scaleX = (size.width / 2) * 0.85;
    final scaleY = (size.height / 2) * 0.85;

    // 1. Draw Background Track
    final trackPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

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
    canvas.drawPath(trackPath, trackPaint);

    // 2. Draw Animated Glowing Trail
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

      // Outer Glow Aura
      final auraPaint = Paint()
        ..color = glowColor.withValues(alpha: 0.45 * alpha)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6.0 * alpha + 1.0);

      canvas.drawCircle(point, 4.5 * alpha + 1.5, auraPaint);

      // Core Light
      final corePaint = Paint()
        ..color = Color.lerp(glowColor, Colors.white, fade * 0.8)!.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(point, 2.2 * alpha + 0.5, corePaint);
    }

    // 3. Draw Leading Head Sparkle Point
    final headPoint = _getLemniscatePoint(headT, center, scaleX, scaleY);

    final headGlowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    canvas.drawCircle(headPoint, 7.5, headGlowPaint);

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
    return oldDelegate.progress != progress || oldDelegate.glowColor != glowColor;
  }
}
