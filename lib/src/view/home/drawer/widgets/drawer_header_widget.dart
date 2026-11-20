import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music/src/controller/equalizer_controller.dart';
import 'package:music/src/controller/theme_controller.dart';

class DrawerHeaderWidget extends StatelessWidget {
  final EqualizerController eqController;
  final ThemeController themeController;

  const DrawerHeaderWidget({
    super.key,
    required this.eqController,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final cardBg = themeController.cardBg;
      final textPrimary = themeController.textPrimary;
      final textSecondary = themeController.textSecondary;
      final borderColor = themeController.borderColor;
      final isPlugged = eqController.isHeadphonePlugged.value;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          border: Border(
            bottom: BorderSide(
              color: borderColor,
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xff00b0ff), Color(0xff60E95D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff00b0ff).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.music_note_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Music Player",
                        style: GoogleFonts.acme(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Audio Studio & Sound Engine",
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      themeController.toggleTheme();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xfff3f4f8),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.15)
                              : const Color(0xffd1d5db),
                          width: 1.2,
                        ),
                      ),
                      child: Icon(
                        isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        color: isDark
                            ? const Color(0xffffd54f)
                            : const Color(0xff374151),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                eqController.toggleHeadphoneOverride();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isPlugged
                      ? const Color(0xff00b0ff).withValues(alpha: 0.14)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : const Color(0xfff3f4f8)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isPlugged
                        ? const Color(0xff00b0ff).withValues(alpha: 0.5)
                        : borderColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPlugged
                          ? Icons.headphones_rounded
                          : Icons.headset_off_rounded,
                      color: isPlugged
                          ? const Color(0xff00b0ff)
                          : textSecondary.withValues(alpha: 0.7),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isPlugged
                          ? "Earphone Connected (Active)"
                          : "Earphone Disconnected (Tap to toggle)",
                      style: TextStyle(
                        color: isPlugged
                            ? const Color(0xff00b0ff)
                            : textSecondary,
                        fontSize: 11.5,
                        fontWeight:
                            isPlugged ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
