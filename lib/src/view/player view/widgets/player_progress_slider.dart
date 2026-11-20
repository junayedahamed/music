import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music/src/controller/audio_controller.dart';

class PlayerProgressSlider extends StatelessWidget {
  final PlayerController controller;
  final bool isDark;
  final Color accentBlue;
  final Color textSecondary;

  const PlayerProgressSlider({
    super.key,
    required this.controller,
    required this.isDark,
    required this.accentBlue,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final maxVal = controller.max.value > 0 ? controller.max.value : 1.0;
      final curVal = controller.value.value.clamp(0.0, maxVal);
      final posText = controller.position.value;
      final durText = controller.duration.value;

      return Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: accentBlue,
              inactiveTrackColor: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : const Color(0xffe2e8f0),
              thumbColor: accentBlue,
              overlayColor: accentBlue.withValues(alpha: 0.2),
            ),
            child: Slider(
              min: 0,
              max: maxVal,
              value: curVal,
              onChanged: (value) {
                controller.changedurationToseconds(value.toInt());
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  posText,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  durText,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
