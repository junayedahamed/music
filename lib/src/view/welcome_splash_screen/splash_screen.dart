import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music/src/controller/audio_controller.dart';
import 'package:music/src/controller/theme_controller.dart';
import 'package:music/src/view/home/home_view.dart';
import 'package:music/src/view/welcome_splash_screen/widgets/animated_sound_wave_bars.dart';
import 'package:music/src/view/welcome_splash_screen/widgets/vinyl_emblem_widget.dart';

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

    _permission();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _permission() async {
    try {
      await _controller.checkAndRequestPermission();
    } catch (_) {}
    _navigate();
  }

  void _navigate() async {
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
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  VinylEmblemWidget(
                    pulseAnimation: _pulseAnimation,
                    isDark: isDark,
                    accentBlue: accentBlue,
                    accentGreen: accentGreen,
                  ),
                  const SizedBox(height: 36),
                  Text(
                    "MUSIC",
                    style: GoogleFonts.acme(
                      fontSize: 34,
                      letterSpacing: 6.0,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedSoundWaveBars(
                    accentBlue: accentBlue,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
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
