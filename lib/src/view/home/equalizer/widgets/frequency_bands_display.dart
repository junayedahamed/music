import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music/src/controller/equalizer_controller.dart';
import 'package:music/src/controller/theme_controller.dart';

class FrequencyBandsDisplay extends StatelessWidget {
  final EqualizerController eqController;
  final ThemeController themeController;

  const FrequencyBandsDisplay({
    super.key,
    required this.eqController,
    required this.themeController,
  });

  static const List<Map<String, String>> _bands = [
    {"label": "60 Hz", "sub": "Bass"},
    {"label": "230 Hz", "sub": "Low-Mid"},
    {"label": "910 Hz", "sub": "Mid"},
    {"label": "3.6 kHz", "sub": "High-Mid"},
    {"label": "14 kHz", "sub": "Treble"},
  ];

  @override
  Widget build(BuildContext context) {
    final cardBg = themeController.cardBg;
    final textPrimary = themeController.textPrimary;
    final textSecondary = themeController.textSecondary;
    final borderColor = themeController.borderColor;
    final accentGreen = themeController.accentGreen;
    final accentBlue = themeController.accentBlue;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Obx(() {
        final isPlugged = eqController.isHeadphonePlugged.value;
        final preset = eqController.currentPreset.value.toLowerCase();

        List<double> levels;
        switch (preset) {
          case "rock":
            levels = [0.7, 0.4, -0.2, 0.5, 0.8];
            break;
          case "jazz":
            levels = [0.4, 0.2, 0.0, 0.3, 0.5];
            break;
          case "pop":
            levels = [-0.2, 0.3, 0.6, 0.3, -0.2];
            break;
          case "classical":
            levels = [0.5, 0.3, -0.2, 0.4, 0.6];
            break;
          case "bass boost":
            levels = [0.95, 0.7, 0.1, 0.0, 0.1];
            break;
          default:
            levels = [0.0, 0.0, 0.0, 0.0, 0.0];
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.graphic_eq_rounded, color: accentGreen, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Frequency Response Curve",
                  style: GoogleFonts.acme(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isPlugged
                        ? textPrimary
                        : textSecondary.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_bands.length, (i) {
                final band = _bands[i];
                final level = isPlugged ? levels[i] : 0.0;
                final barHeight = 40.0 + (level * 25.0);

                return Column(
                  children: [
                    Text(
                      "${(level * 12).toInt()} dB",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isPlugged
                            ? (level > 0 ? accentGreen : textSecondary)
                            : textSecondary.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 14,
                      height: 90,
                      decoration: BoxDecoration(
                        color: themeController.cardAltBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 14,
                        height: barHeight.clamp(8.0, 90.0),
                        decoration: BoxDecoration(
                          color: isPlugged
                              ? accentBlue
                              : textSecondary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: isPlugged
                              ? [
                                  BoxShadow(
                                    color: accentBlue.withValues(alpha: 0.5),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      band["label"]!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isPlugged
                            ? textPrimary
                            : textSecondary.withValues(alpha: 0.4),
                      ),
                    ),
                    Text(
                      band["sub"]!,
                      style: TextStyle(
                        fontSize: 9,
                        color: textSecondary.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        );
      }),
    );
  }
}
