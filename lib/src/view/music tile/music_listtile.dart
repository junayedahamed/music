import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onLongPress,
    this.onMenuShare,
    this.onMenuDelete,
    this.onMenuSelect,
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
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onLongPress;
  final VoidCallback? onMenuShare;
  final VoidCallback? onMenuDelete;
  final VoidCallback? onMenuSelect;

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
            (playerController.hasActiveSong &&
                ((songUri != null && playerController.songUri == songUri) ||
                    (songId != null &&
                        songId! > 0 &&
                        playerController.currentSongId.value == songId)));

        // Highlight text color for current playing/active song
        final titleColor =
            isCurrent ? accentBlue : themeController.textPrimary;
        final subtitleColor = isCurrent
            ? accentBlue.withValues(alpha: 0.85)
            : themeController.textSecondary;

        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isSelected
                  ? accentBlue
                  : (isCurrent
                      ? accentBlue.withValues(alpha: 0.45)
                      : themeController.borderColor),
              width: (isSelected || isCurrent) ? 1.4 : 0.8,
            ),
          ),
          tileColor: isSelected
              ? accentBlue.withValues(alpha: isDark ? 0.16 : 0.12)
              : (isCurrent
                  ? accentBlue.withValues(alpha: isDark ? 0.08 : 0.06)
                  : cardBg),
          onTap: onPressed,
          onLongPress: onLongPress,
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
          trailing: _buildTrailing(context, themeController),
        );
      }),
    );
  }

  Widget _buildTrailing(BuildContext context, ThemeController themeController) {
    final accentBlue = themeController.accentBlue;

    if (isSelectionMode) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? accentBlue : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? accentBlue
                : themeController.textSecondary.withValues(alpha: 0.5),
            width: 2.0,
          ),
        ),
        child: isSelected
            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
            : null,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (trailing != null) trailing!,
        if (onMenuShare != null || onMenuDelete != null || onMenuSelect != null)
          Theme(
            data: Theme.of(context).copyWith(
              cardColor: themeController.cardBg,
            ),
            child: PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: themeController.textSecondary,
                size: 20,
              ),
              color: themeController.cardBg,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: themeController.borderColor),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 170),
              onSelected: (val) {
                if (val == "share") onMenuShare?.call();
                if (val == "select") onMenuSelect?.call();
                if (val == "delete") onMenuDelete?.call();
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: "share",
                  child: Row(
                    children: [
                      Icon(Icons.share_rounded,
                          size: 18, color: themeController.textPrimary),
                      const SizedBox(width: 12),
                      Text("Share",
                          style: TextStyle(
                              color: themeController.textPrimary,
                              fontSize: 13.5)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: "select",
                  onTap: onMenuSelect,
                  child: Row(
                    children: [
                      Icon(Icons.checklist_rounded,
                          size: 18, color: themeController.textPrimary),
                      const SizedBox(width: 12),
                      Text("Select",
                          style: TextStyle(
                              color: themeController.textPrimary,
                              fontSize: 13.5)),
                    ],
                  ),
                ),
                const PopupMenuDivider(height: 1),
                PopupMenuItem(
                  value: "delete",
                  child: Row(
                    children: const [
                      Icon(Icons.delete_forever_rounded,
                          size: 18, color: Colors.redAccent),
                      SizedBox(width: 12),
                      Text("Delete from Device",
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
