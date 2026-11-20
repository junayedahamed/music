import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music/src/controller/equalizer_controller.dart';
import 'package:music/src/controller/theme_controller.dart';

class BassBoostCard extends StatelessWidget {
  final EqualizerController eqController;
  final ThemeController themeController;

  const BassBoostCard({
    super.key,
    required this.eqController,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = themeController.cardBg;
    final textPrimary = themeController.textPrimary;
    final textSecondary = themeController.textSecondary;
    final borderColor = themeController.borderColor;
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
        final bassVal = eqController.bassLevel.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isPlugged
                            ? accentBlue.withValues(alpha: 0.15)
                            : themeController.cardAltBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.surround_sound_rounded,
                        color: isPlugged ? accentBlue : textSecondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Deep Bass Boost",
                          style: GoogleFonts.acme(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isPlugged
                                ? textPrimary
                                : textSecondary.withValues(alpha: 0.5),
                          ),
                        ),
                        Text(
                          "Low-frequency sub-bass amplifier",
                          style: TextStyle(
                            fontSize: 11,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPlugged
                        ? accentBlue.withValues(alpha: 0.15)
                        : themeController.cardAltBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${(bassVal * 100).toInt()}%",
                    style: TextStyle(
                      color: isPlugged ? accentBlue : textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbColor: isPlugged ? accentBlue : Colors.grey,
                activeTrackColor: isPlugged
                    ? accentBlue
                    : borderColor.withValues(alpha: 0.4),
                inactiveTrackColor: borderColor,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayColor: accentBlue.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: isPlugged ? bassVal : 0.0,
                onChanged: isPlugged
                    ? (newVal) => eqController.setBass(newVal)
                    : null,
              ),
            ),
          ],
        );
      }),
    );
  }
}
