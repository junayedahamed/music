import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music/src/controller/audio_controller.dart';

class PlayerControlsRow extends StatelessWidget {
  final PlayerController controller;
  final Color accentBlue;
  final Color textPrimary;
  final Color textSecondary;

  const PlayerControlsRow({
    super.key,
    required this.controller,
    required this.accentBlue,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isPlaying = controller.isplaying.value;
      final isShuffle = controller.isShuffle.value;
      final hasPrev = controller.hasPrevious;
      final hasNext = controller.hasNext;
      final loop = controller.loopMode.value;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            tooltip: "Shuffle",
            onPressed: () {
              HapticFeedback.lightImpact();
              controller.toggleShuffle();
            },
            icon: Icon(
              Icons.shuffle_rounded,
              size: 24,
              color: isShuffle ? accentBlue : textSecondary.withValues(alpha: 0.5),
            ),
          ),
          IconButton(
            tooltip: "Previous Track",
            onPressed: hasPrev
                ? () {
                    HapticFeedback.mediumImpact();
                    controller.playprevious();
                  }
                : null,
            icon: Icon(
              Icons.skip_previous_rounded,
              size: 38,
              color: hasPrev ? textPrimary : textSecondary.withValues(alpha: 0.25),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              controller.pause();
            },
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentBlue, const Color(0xff0081cb)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accentBlue.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 36,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            tooltip: "Next Track",
            onPressed: hasNext
                ? () {
                    HapticFeedback.mediumImpact();
                    controller.playnext();
                  }
                : null,
            icon: Icon(
              Icons.skip_next_rounded,
              size: 38,
              color: hasNext ? textPrimary : textSecondary.withValues(alpha: 0.25),
            ),
          ),
          IconButton(
            tooltip: "Repeat Mode",
            onPressed: () {
              HapticFeedback.lightImpact();
              controller.toggleLoopMode();
            },
            icon: Icon(
              loop == LoopMode.one
                  ? Icons.repeat_one_rounded
                  : Icons.repeat_rounded,
              size: 24,
              color: loop != LoopMode.off
                  ? accentBlue
                  : textSecondary.withValues(alpha: 0.5),
            ),
          ),
        ],
      );
    });
  }
}
