import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:music/src/controller/audio_controller.dart';
import 'package:music/src/controller/theme_controller.dart';
import 'package:music/src/view/player%20view/audio_wave_visualizer.dart';
import 'package:music/src/view/player%20view/player_buttons.dart';
import 'package:music/src/view/player%20view/player_view.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class BottomMusicView extends StatelessWidget {
  BottomMusicView({super.key, required this.songs});

  final playercontroller = Get.find<PlayerController>();
  final List<SongModel> songs;

  @override
  Widget build(BuildContext context) {
    final themeController = Get.put(ThemeController());

    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final cardBg = themeController.cardBg;
      final textPrimary = themeController.textPrimary;
      final borderColor = themeController.borderColor;
      final accentBlue = themeController.accentBlue;
      final accentGreen = themeController.accentGreen;

      return Material(
        color: Colors.transparent,
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: cardBg,
            border: Border.all(
              color: borderColor,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title and music icon row
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Get.to(
                      () => Player(
                        songs: playercontroller.currentPlaylist.isNotEmpty
                            ? playercontroller.currentPlaylist
                            : songs,
                      ),
                      transition: Transition.fadeIn,
                      duration: const Duration(milliseconds: 150),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [accentGreen, const Color(0xff059669)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: MiniMusicVisualizer(
                            isPlaying: playercontroller.isplaying.value,
                            color: Colors.white,
                            height: 18.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              playercontroller.songname.value,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (playercontroller.isplaying.value)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: AudioWaveVisualizer(
                                  isPlaying: true,
                                  height: 10,
                                  barCount: 6,
                                  activeColor: accentBlue,
                                  secondaryColor: accentGreen,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Controller skip next, progress and play/pause
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: CircularStepProgressIndicator(
                        totalSteps: playercontroller.max.value.toInt() > 0
                            ? playercontroller.max.value.toInt()
                            : 100,
                        currentStep: playercontroller.value.value.toInt().clamp(
                            0,
                            playercontroller.max.value.toInt() > 0
                                ? playercontroller.max.value.toInt()
                                : 100),
                        selectedColor: accentBlue,
                        unselectedColor: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : const Color(0xffe2e8f0),
                        selectedStepSize: 3,
                        unselectedStepSize: 2,
                        width: 40,
                        child: PlayerButtons(
                          myicon: Icon(
                            playercontroller.isplaying.value
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: textPrimary,
                            size: 22,
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            playercontroller.pause();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    PlayerButtons(
                      myicon: Icon(
                        Icons.skip_next_rounded,
                        color: textPrimary,
                        size: 26,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        playercontroller.playnext();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
