import 'package:flutter/material.dart';

/// Concentric vinyl groove circles painter
class VinylGroovesPainter extends CustomPainter {
  final Color grooveColor;
  VinylGroovesPainter({required this.grooveColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = grooveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radii = [50.0, 56.0, 62.0];
    for (final r in radii) {
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant VinylGroovesPainter oldDelegate) => false;
}

/// Animated glowing vinyl disc / soundwave emblem
class VinylEmblemWidget extends StatelessWidget {
  final Animation<double> pulseAnimation;
  final bool isDark;
  final Color accentBlue;
  final Color accentGreen;

  const VinylEmblemWidget({
    super.key,
    required this.pulseAnimation,
    required this.isDark,
    required this.accentBlue,
    required this.accentGreen,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: pulseAnimation.value,
          child: child,
        );
      },
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? const Color(0xff121824) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: accentBlue.withValues(alpha: isDark ? 0.35 : 0.2),
              blurRadius: 36,
              spreadRadius: 4,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: accentGreen.withValues(alpha: isDark ? 0.25 : 0.15),
              blurRadius: 28,
              spreadRadius: 2,
              offset: const Offset(0, -4),
            ),
          ],
          border: Border.all(
            color: accentBlue.withValues(alpha: 0.4),
            width: 2.0,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(140, 140),
              painter: VinylGroovesPainter(
                grooveColor: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.04),
              ),
            ),
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accentBlue.withValues(alpha: 0.5),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                  width: 1.5,
                ),
                image: const DecorationImage(
                  image: AssetImage('assets/applogo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
