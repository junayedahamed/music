import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music/src/controller/playlist_controller.dart';
import 'package:music/src/controller/theme_controller.dart';
import 'package:music/src/view/home/playlist/playlist_detail_screen.dart';
import 'package:music/src/view/home/playlist/widgets/create_playlist_dialog.dart';

class DrawerPlaylistSection extends StatelessWidget {
  final PlaylistController playlistController;
  final ThemeController themeController;

  const DrawerPlaylistSection({
    super.key,
    required this.playlistController,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cardBg = themeController.cardBg;
      final cardAltBg = themeController.cardAltBg;
      final textPrimary = themeController.textPrimary;
      final textSecondary = themeController.textSecondary;
      final borderColor = themeController.borderColor;
      final accentGreen = themeController.accentGreen;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "PLAYLISTS",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: textSecondary.withValues(alpha: 0.6),
                  letterSpacing: 1.0,
                ),
              ),
              GestureDetector(
                onTap: () =>
                    CreatePlaylistDialog.show(context, themeController),
                child: Row(
                  children: [
                    Icon(Icons.add_rounded, color: accentGreen, size: 16),
                    const SizedBox(width: 3),
                    Text(
                      "New",
                      style: TextStyle(
                        color: accentGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => CreatePlaylistDialog.show(context, themeController),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accentGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                          Icon(Icons.add_rounded, color: accentGreen, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Create Own Playlist",
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Select songs from your device library",
                            style:
                                TextStyle(color: textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: textSecondary.withValues(alpha: 0.5), size: 14),
                  ],
                ),
              ),
            ),
          ),
          if (playlistController.playlists.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...playlistController.playlists.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.of(context).pop();
                      Get.to(
                          () => PlaylistDetailScreen(playlistName: entry.key));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: cardAltBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.queue_music_rounded,
                              color: accentGreen, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "${entry.value.length} songs",
                                  style: TextStyle(
                                      color: textSecondary, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline_rounded,
                                color: textSecondary.withValues(alpha: 0.6),
                                size: 18),
                            onPressed: () {
                              playlistController.deletePlaylist(entry.key);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ],
      );
    });
  }
}
