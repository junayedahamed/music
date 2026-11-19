import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:music/src/controller/audio_controller.dart';
import 'package:music/src/controller/theme_controller.dart';

class MusicListtile extends StatelessWidget {
  const MusicListtile({
    super.key,
    required this.musicName,
    required this.artistName,
    required this.onPressed,
    required this.leading,
    this.trailing,
    this.songUri,
    this.songId,
    this.isCurrentSong,
    this.isPlaying,
  });

  final String musicName;
  final VoidCallback onPressed;
  final String artistName;
  final Widget leading;
  final Widget? trailing;
  final String? songUri;
  final int? songId;
  final bool? isCurrentSong;
  final bool? isPlaying;

  @override
  Widget build(BuildContext context) {
    final themeController = Get.put(ThemeController());
    final playerController = Get.find<PlayerController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Obx(() {
        final isDark = themeController.isDarkMode.value;
        final cardBg = themeController.cardBg;
        final accentBlue = themeController.accentBlue;

        // Check if this tile is the currently active/playing song
        final bool isCurrent = isCurrentSong ??
            ((songUri != null && playerController.songUri == songUri) ||
                (songId != null &&
                    playerController.currentSongId.value == songId));

        // Different text colors for current playing/active song vs other songs
        final titleColor =
            isCurrent ? accentBlue : themeController.textPrimary;
        final subtitleColor = isCurrent
            ? accentBlue.withValues(alpha: 0.85)
            : themeController.textSecondary;

        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isCurrent
                  ? accentBlue.withValues(alpha: 0.45)
                  : themeController.borderColor,
              width: isCurrent ? 1.2 : 0.8,
            ),
          ),
          tileColor: isCurrent
              ? (isDark
                  ? accentBlue.withValues(alpha: 0.08)
                  : accentBlue.withValues(alpha: 0.06))
              : cardBg,
          onTap: onPressed,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: leading,
          title: Text(
            musicName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
              color: titleColor,
            ),
          ),
          subtitle: Text(
            artistName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: subtitleColor,
              fontWeight: isCurrent ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          trailing: trailing,
        );
      }),
    );
  }
}
