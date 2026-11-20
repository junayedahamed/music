import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music/src/controller/audio_controller.dart';
import 'package:music/src/controller/theme_controller.dart';
import 'package:music/src/view/player%20view/beat_waveform_circle.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlayerArtworkView extends StatelessWidget {
  final SongModel? song;
  final int songId;
  final bool isDark;
  final Color cardBg;
  final Color borderColor;
  final Color accentBlue;
  final Color accentGreen;
  final PlayerController controller;
  final ThemeController themeController;

  const PlayerArtworkView({
    super.key,
    required this.song,
    required this.songId,
    required this.isDark,
    required this.cardBg,
    required this.borderColor,
    required this.accentBlue,
    required this.accentGreen,
    required this.controller,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Hero(
          tag: "album_art_${song?.id ?? 'default'}",
          child: Container(
            width: MediaQuery.of(context).size.width * 0.72,
            height: MediaQuery.of(context).size.width * 0.72,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.6)
                      : Colors.black.withValues(alpha: 0.12),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
                BoxShadow(
                  color: accentBlue.withValues(alpha: 0.15),
                  blurRadius: 40,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(
                color: borderColor,
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: (song != null || songId > 0)
                  ? QueryArtworkWidget(
                      id: song?.id ?? songId,
                      type: ArtworkType.AUDIO,
                      artworkWidth: double.infinity,
                      artworkHeight: double.infinity,
                      artworkFit: BoxFit.cover,
                      nullArtworkWidget: _buildFallback(),
                    )
                  : _buildFallback(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xff1f212c), const Color(0xff0d0f15)]
              : [const Color(0xffe2e8f0), const Color(0xffcbd5e1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Obx(
          () => BeatWaveformCircle(
            isPlaying: controller.isplaying.value,
            size: 110,
            primaryColor: accentBlue,
            secondaryColor: accentGreen,
          ),
        ),
      ),
    );
  }
}
