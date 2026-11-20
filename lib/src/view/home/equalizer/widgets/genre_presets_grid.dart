import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music/src/controller/equalizer_controller.dart';
import 'package:music/src/controller/theme_controller.dart';

class GenrePresetsGrid extends StatelessWidget {
  final EqualizerController eqController;
  final ThemeController themeController;

  const GenrePresetsGrid({
    super.key,
    required this.eqController,
    required this.themeController,
  });

  static const Map<String, IconData> _presetIcons = {
    "Normal": Icons.music_note_rounded,
    "Jazz": Icons.nightlife_rounded,
    "Rock": Icons.electric_bolt_rounded,
    "Pop": Icons.mic_external_on_rounded,
    "Classical": Icons.piano_rounded,
    "Bass Boost": Icons.speaker_group_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final cardBg = themeController.cardBg;
    final textPrimary = themeController.textPrimary;
    final textSecondary = themeController.textSecondary;
    final borderColor = themeController.borderColor;
    final accentBlue = themeController.accentBlue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.tune_rounded, color: accentBlue, size: 20),
            const SizedBox(width: 8),
            Text(
              "Genre Sound Profiles",
              style: GoogleFonts.acme(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Switch equalizer tone based on music genre",
          style: TextStyle(fontSize: 12, color: textSecondary),
        ),
        const SizedBox(height: 14),
        Obx(() {
          final isPlugged = eqController.isHeadphonePlugged.value;
          final activePreset = eqController.currentPreset.value;

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: eqController.presets.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.3,
            ),
            itemBuilder: (context, index) {
              final preset = eqController.presets[index];
              final isSelected =
                  activePreset.toLowerCase() == preset.toLowerCase();
              final icon = _presetIcons[preset] ?? Icons.music_note_rounded;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    if (!isPlugged) {
                      HapticFeedback.heavyImpact();
                      Get.snackbar(
                        "Headphones Required",
                        "Plug in earphones to activate '$preset' preset.",
                        backgroundColor: cardBg,
                        colorText: textPrimary,
                        icon: const Icon(Icons.headset_off_rounded,
                            color: Color(0xffffb74d)),
                        duration: const Duration(seconds: 2),
                      );
                      return;
                    }
                    HapticFeedback.selectionClick();
                    eqController.setPreset(preset);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isPlugged
                          ? (isSelected
                              ? accentBlue.withValues(alpha: 0.18)
                              : cardBg)
                          : cardBg.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isPlugged
                            ? (isSelected ? accentBlue : borderColor)
                            : borderColor.withValues(alpha: 0.4),
                        width: isSelected ? 1.8 : 1.0,
                      ),
                      boxShadow: isPlugged && isSelected
                          ? [
                              BoxShadow(
                                color: accentBlue.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: isPlugged && isSelected
                                ? accentBlue
                                : themeController.cardAltBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isPlugged ? icon : Icons.lock_outline_rounded,
                            size: 18,
                            color: isPlugged
                                ? (isSelected ? Colors.white : textSecondary)
                                : textSecondary.withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            preset,
                            style: TextStyle(
                              color: isPlugged
                                  ? (isSelected ? accentBlue : textPrimary)
                                  : textSecondary.withValues(alpha: 0.5),
                              fontSize: 13.5,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (isPlugged && isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: accentBlue,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }
}
