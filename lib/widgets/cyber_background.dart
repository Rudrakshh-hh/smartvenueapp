import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CyberBackground extends StatefulWidget {
  final Widget child;

  const CyberBackground({super.key, required this.child});

  @override
  State<CyberBackground> createState() => _CyberBackgroundState();
}

class _CyberBackgroundState extends State<CyberBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Base Theme Background Color
        Container(color: isDark ? AppTheme.darkBg : AppTheme.lightBg),

        // Animated Painter for Ambient Sci-Fi Glow & Grid
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _CyberGridPainter(
                progress: _controller.value,
                isDark: isDark,
              ),
              child: const SizedBox.expand(),
            );
          },
        ),

        // Glowing Orbs in Background
        Positioned(
          top: -100,
          right: -80,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.cyanPrimary.withValues(
                alpha: isDark ? 0.08 : 0.12,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.cyanPrimary.withValues(
                    alpha: isDark ? 0.12 : 0.18,
                  ),
                  blurRadius: 100,
                  spreadRadius: 40,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 120,
          left: -100,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.purpleAccent.withValues(
                alpha: isDark ? 0.08 : 0.12,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.purpleAccent.withValues(
                    alpha: isDark ? 0.12 : 0.18,
                  ),
                  blurRadius: 120,
                  spreadRadius: 50,
                ),
              ],
            ),
          ),
        ),

        // Child Content
        SafeArea(child: widget.child),
      ],
    );
  }
}

class _CyberGridPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _CyberGridPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppTheme.cyanPrimary.withValues(alpha: isDark ? 0.035 : 0.08)
      ..strokeWidth = 1.0;

    const double step = 40.0;

    // Draw vertical grid lines
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Draw horizontal grid lines
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw glowing dynamic pulse line sweeping vertically
    final pulseY = (progress * size.height);
    final pulsePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppTheme.cyanPrimary.withValues(alpha: 0.0),
          AppTheme.cyanPrimary.withValues(alpha: isDark ? 0.15 : 0.25),
          AppTheme.cyanPrimary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, pulseY - 20, size.width, 40));

    canvas.drawRect(Rect.fromLTWH(0, pulseY - 20, size.width, 40), pulsePaint);
  }

  @override
  bool shouldRepaint(covariant _CyberGridPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isDark != isDark;
}
