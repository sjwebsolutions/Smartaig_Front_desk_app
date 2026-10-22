import 'package:flutter/material.dart';

class CustomShimmer extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  const CustomShimmer({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFCBD5E1),
    this.highlightColor = const Color(0xFFFFFFFF),
  });

  @override
  State<CustomShimmer> createState() => _CustomShimmerState();
}

class _CustomShimmerState extends State<CustomShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-2.0 + (_controller.value * 4.0), -0.2),
              end: Alignment(-1.0 + (_controller.value * 4.0), 0.2),
              colors: [
                widget.baseColor.withValues(alpha: 0.35),
                widget.highlightColor,
                widget.baseColor.withValues(alpha: 0.35),
              ],
              stops: const [0.1, 0.5, 0.9],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? color;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 10.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? const Color(0xFFCBD5E1),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class DashboardShimmerSkeleton extends StatelessWidget {
  const DashboardShimmerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top App Bar Skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ShimmerBox(width: 38, height: 38, borderRadius: 19),
                const ShimmerBox(width: 130, height: 20, borderRadius: 8),
                const ShimmerBox(width: 38, height: 38, borderRadius: 19),
              ],
            ),
            const SizedBox(height: 14),

            // 2. Profile / Welcome Card Skeleton
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const ShimmerBox(width: 52, height: 52, borderRadius: 26),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ShimmerBox(width: 150, height: 16, borderRadius: 6),
                        SizedBox(height: 8),
                        ShimmerBox(width: 190, height: 12, borderRadius: 6),
                      ],
                    ),
                  ),
                  const ShimmerBox(width: 24, height: 24, borderRadius: 12),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Today Stats Row Skeleton
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ShimmerBox(width: 32, height: 32, borderRadius: 16),
                        SizedBox(height: 10),
                        ShimmerBox(width: 36, height: 22, borderRadius: 6),
                        SizedBox(height: 6),
                        ShimmerBox(width: 60, height: 10, borderRadius: 4),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ShimmerBox(width: 32, height: 32, borderRadius: 16),
                        SizedBox(height: 10),
                        ShimmerBox(width: 36, height: 22, borderRadius: 6),
                        SizedBox(height: 6),
                        ShimmerBox(width: 60, height: 10, borderRadius: 4),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ShimmerBox(width: 32, height: 32, borderRadius: 16),
                        SizedBox(height: 10),
                        ShimmerBox(width: 36, height: 22, borderRadius: 6),
                        SizedBox(height: 6),
                        ShimmerBox(width: 60, height: 10, borderRadius: 4),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 4. Section Header Skeleton
            const ShimmerBox(width: 120, height: 16, borderRadius: 6),
            const SizedBox(height: 12),

            // 5. 2x2 Modules Grid Skeleton
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: List.generate(
                4,
                (index) => Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white, width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ShimmerBox(width: 40, height: 40, borderRadius: 12),
                          ShimmerBox(width: 28, height: 18, borderRadius: 9),
                        ],
                      ),
                      Spacer(),
                      ShimmerBox(width: 110, height: 14, borderRadius: 6),
                      SizedBox(height: 6),
                      ShimmerBox(width: 75, height: 10, borderRadius: 4),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 6. Recent Requests Section Skeleton
            const ShimmerBox(width: 150, height: 16, borderRadius: 6),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 1.2),
              ),
              child: Row(
                children: [
                  const ShimmerBox(width: 42, height: 42, borderRadius: 21),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ShimmerBox(width: 130, height: 14, borderRadius: 5),
                        SizedBox(height: 6),
                        ShimmerBox(width: 90, height: 10, borderRadius: 4),
                      ],
                    ),
                  ),
                  const ShimmerBox(width: 60, height: 22, borderRadius: 11),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 1.2),
              ),
              child: Row(
                children: [
                  const ShimmerBox(width: 42, height: 42, borderRadius: 21),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ShimmerBox(width: 140, height: 14, borderRadius: 5),
                        SizedBox(height: 6),
                        ShimmerBox(width: 100, height: 10, borderRadius: 4),
                      ],
                    ),
                  ),
                  const ShimmerBox(width: 60, height: 22, borderRadius: 11),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
