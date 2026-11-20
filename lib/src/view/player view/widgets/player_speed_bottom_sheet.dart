import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music/src/controller/audio_controller.dart';
import 'package:music/src/controller/theme_controller.dart';

class PlayerSpeedBottomSheet {
  static void show(
    BuildContext context,
    PlayerController controller,
    ThemeController themeController,
  ) {
    final cardBg = themeController.cardBg;
    final textPrimary = themeController.textPrimary;
    final textSecondary = themeController.textSecondary;
    final accentBlue = themeController.accentBlue;
    final borderColor = themeController.borderColor;

    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Playback Speed",
              style: GoogleFonts.acme(
                fontSize: 20,
                color: textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Select playback speed multiplier",
              style: TextStyle(fontSize: 12, color: textSecondary),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: speeds.map((s) {
                final isSelected = controller.playbackSpeed.value == s;
                return ChoiceChip(
                  label: Text("${s}x"),
                  selected: isSelected,
                  selectedColor: accentBlue,
                  backgroundColor: themeController.cardAltBg,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: isSelected ? accentBlue : borderColor,
                  ),
                  onSelected: (val) {
                    if (val) {
                      HapticFeedback.selectionClick();
                      controller.setPlaybackSpeed(s);
                      Navigator.of(ctx).pop();
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
