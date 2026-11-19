import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music/src/controller/audio_controller.dart';
import 'package:music/src/controller/theme_controller.dart';
import 'package:music/src/view/home/home_view.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreenMusic extends StatefulWidget {
  const SplashScreenMusic({super.key});

  @override
  State<SplashScreenMusic> createState() => _SplashScreenMusicState();
}

class _SplashScreenMusicState extends State<SplashScreenMusic>
    with SingleTickerProviderStateMixin {
  late final PlayerController _controller;
  late final ThemeController _themeController;
  late final AnimationController _animController;
  late final Animation<double> _pulseAnimation;
  // late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _themeController = Get.put(ThemeController());
    _controller = Get.put(PlayerController());

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    // _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    //   CurvedAnimation(
    //     parent: _animController,
    //     curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    //   ),
    // );

    _permission();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _permission() async {
    try {
      final audioGranted = await Permission.audio.isGranted;
      final storageGranted = await Permission.storage.isGranted;
      if (audioGranted || storageGranted) {
        _navigate();
        return;
      }
    } catch (_) {}

    await _controller.checkAndRequestPermission();
    _navigate();
  }

  void _navigate() async {
    // Snappy, professional splash delay (300ms instead of 1600ms)
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = _themeController.isDarkMode.value;
      final scaffoldBg = _themeController.scaffoldBg;
      final textPrimary = _themeController.textPrimary;
      final textSecondary = _themeController.textSecondary;
      final accentBlue = _themeController.accentBlue;
      final accentGreen = _themeController.accentGreen;

      return Scaffold(
        backgroundColor: scaffoldBg,
        body: Stack(
          children: [
            // Ambient background radial glow
            Positioned(
              top: MediaQuery.of(context).size.height * 0.25,
              left: MediaQuery.of(context).size.width * 0.1,
              right: MediaQuery.of(context).size.width * 0.1,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 260 * _pulseAnimation.value,
                    height: 260 * _pulseAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: isDark
                            ? [
                                accentBlue.withValues(alpha: 0.18),
                                Colors.transparent,
                              ]
                            : [
                                accentBlue.withValues(alpha: 0.12),
                                Colors.transparent,
                              ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Center Branding & Audio Icon
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated glowing vinyl disc / soundwave emblem
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
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
                            color: accentBlue.withValues(
                                alpha: isDark ? 0.35 : 0.2),
                            blurRadius: 36,
                            spreadRadius: 4,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: accentGreen.withValues(
                                alpha: isDark ? 0.25 : 0.15),
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
                          // Concentric vinyl groove circles
                          CustomPaint(
                            size: const Size(140, 140),
                            painter: _VinylGroovesPainter(
                              grooveColor: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.black.withValues(alpha: 0.04),
                            ),
                          ),

                          // Inner gradient disc with music note
                          Container(
                            width: 82,
                            height: 82,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [accentBlue, const Color(0xff0081cb)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accentBlue.withValues(alpha: 0.5),
                                  blurRadius: 18,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.music_note_rounded,
                                size: 44,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Brand Title
                  Text(
                    "JUNA PLAY",
                    style: GoogleFonts.acme(
                      fontSize: 32,
                      letterSpacing: 4.5,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Sound equalizer wave animation bars
                  _AnimatedSoundWaveBars(
                      accentBlue: accentBlue, isDark: isDark),

                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    "OFFLINE AUDIO STUDIO",
                    style: TextStyle(
                      fontSize: 11.5,
                      letterSpacing: 2.8,
                      fontWeight: FontWeight.w600,
                      color: textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom loading status & version
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  SizedBox(
                    width: 32,
                    height: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        backgroundColor:
                            accentBlue.withValues(alpha: isDark ? 0.15 : 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(accentBlue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "High Fidelity Audio Engine",
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 0.5,
                      color: textSecondary.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// Custom painter for sleek concentric vinyl grooves
class _VinylGroovesPainter extends CustomPainter {
  final Color grooveColor;
  _VinylGroovesPainter({required this.grooveColor});

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
  bool shouldRepaint(covariant _VinylGroovesPainter oldDelegate) => false;
}

/// Animated 5-bar soundwave visualizer below the logo
class _AnimatedSoundWaveBars extends StatefulWidget {
  final Color accentBlue;
  final bool isDark;
  const _AnimatedSoundWaveBars(
      {required this.accentBlue, required this.isDark});

  @override
  State<_AnimatedSoundWaveBars> createState() => _AnimatedSoundWaveBarsState();
}

class _AnimatedSoundWaveBarsState extends State<_AnimatedSoundWaveBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final t = (_waveController.value + index * 0.2) % 1.0;
            final height = 4.0 + 12.0 * math.sin(t * math.pi);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: 3.5,
              height: height,
              decoration: BoxDecoration(
                color: widget.accentBlue.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}
