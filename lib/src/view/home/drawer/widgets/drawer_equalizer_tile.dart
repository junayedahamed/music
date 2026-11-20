import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music/src/controller/equalizer_controller.dart';
import 'package:music/src/controller/theme_controller.dart';
import 'package:music/src/view/home/equalizer/equalizer_screen.dart';

class DrawerEqualizerTile extends StatelessWidget {
  final EqualizerController eqController;
  final ThemeController themeController;

  const DrawerEqualizerTile({
    super.key,
    required this.eqController,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isPlugged = eqController.isHeadphonePlugged.value;
      final preset = eqController.currentPreset.value;
      final isDark = themeController.isDarkMode.value;
      final cardBg = themeController.cardBg;
      final textPrimary = themeController.textPrimary;
      final textSecondary = themeController.textSecondary;
      final borderColor = themeController.borderColor;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "AUDIO STUDIO",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textSecondary.withValues(alpha: 0.6),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.of(context).pop();
                Get.to(() => const EqualizerScreen());
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isPlugged
                        ? const Color(0xff00b0ff).withValues(alpha: 0.4)
                        : borderColor,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isPlugged
                              ? const [Color(0xff00b0ff), Color(0xff0081cb)]
                              : [
                                  isDark ? Colors.white24 : const Color(0xffd1d5db),
                                  isDark ? Colors.white10 : const Color(0xffe5e7eb)
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.equalizer_rounded,
                        color: isPlugged
                            ? Colors.black
                            : (isDark ? Colors.white60 : Colors.black54),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Bass & Equalizer",
                                style: GoogleFonts.acme(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (!isPlugged)
                                const Icon(Icons.lock_rounded,
                                    color: Color(0xffffb74d), size: 14),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isPlugged
                                ? "Active: $preset profile • Tap to adjust"
                                : "🔒 Tap to enable / plug in headphones",
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isPlugged
                                  ? const Color(0xff00b0ff)
                                  : const Color(0xffffb74d),
                              fontWeight: isPlugged
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: textSecondary.withValues(alpha: 0.5), size: 14),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
