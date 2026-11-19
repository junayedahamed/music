import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:music/src/controller/audio_controller.dart';
import 'package:music/src/controller/playlist_controller.dart';
import 'package:music/src/controller/theme_controller.dart';
import 'package:music/src/view/home/playlist/create_playlist_screen.dart';
import 'package:music/src/view/music%20tile/music_listtile.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final String playlistName;

  const PlaylistDetailScreen({super.key, required this.playlistName});

  @override
  Widget build(BuildContext context) {
    final playlistController = Get.find<PlaylistController>();
    final playerController = Get.find<PlayerController>();
    final themeController = Get.put(ThemeController());

    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final scaffoldBg = themeController.scaffoldBg;
      final textPrimary = themeController.textPrimary;
      final textSecondary = themeController.textSecondary;
      final accentGreen = themeController.accentGreen;
      final accentBlue = themeController.accentBlue;

      return Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          backgroundColor: scaffoldBg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: textPrimary, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            playlistName,
            style: GoogleFonts.acme(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.playlist_add_rounded,
                  color: accentBlue, size: 26),
              tooltip: "Add More Songs",
              onPressed: () {
                final currentIds =
                    playlistController.getPlaylistSongIds(playlistName);
                Get.to(() => CreatePlaylistScreen(
                      playlistName: playlistName,
                      initialSelectedIds: currentIds,
                    ));
              },
            ),
          ],
        ),
        body: Obx(() {
          final songIds = playlistController.getPlaylistSongIds(playlistName);
          final allSongs = playerController.allsongs;
          final playlistSongs =
              allSongs.where((song) => songIds.contains(song.id)).toList();

          if (playlistSongs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.queue_music_rounded,
                      size: 64,
                      color: textSecondary.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(
                    "No songs in this playlist yet",
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.to(() => CreatePlaylistScreen(
                            playlistName: playlistName,
                            initialSelectedIds: songIds,
                          ));
                    },
                    icon: const Icon(Icons.add_rounded, color: Colors.black),
                    label: const Text("Add Songs",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Play all header banner
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Text(
                      "${playlistSongs.length} Songs",
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        playerController.playOrNavigate(
                          playlistSongs.first,
                          0,
                          playlistSongs,
                        );
                      },
                      icon: const Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 20),
                      label: const Text("Play All",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentBlue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Song list
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: playlistSongs.length,
                  itemBuilder: (context, index) {
                    final song = playlistSongs[index];

                    return Obx(() {
                      final isPlaying =
                          playerController.playindex.value == index &&
                              playerController.isplaying.value;

                      return MusicListtile(
                        leading: QueryArtworkWidget(
                          id: song.id,
                          type: ArtworkType.AUDIO,
                          nullArtworkWidget: Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.black54
                                  : const Color(0xffe2e8f0),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.music_note,
                              color: textPrimary,
                              size: 26,
                            ),
                          ),
                        ),
                        onPressed: () {
                          playerController.playOrNavigate(
                            song,
                            index,
                            playlistSongs,
                          );
                        },
                        musicName: song.title,
                        artistName: song.artist ?? "Unknown Artist",
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isPlaying)
                              Icon(
                                Icons.play_arrow_rounded,
                                size: 28,
                                color: accentGreen,
                              ),
                            IconButton(
                              icon: Icon(
                                Icons.remove_circle_outline_rounded,
                                color: textSecondary.withValues(alpha: 0.6),
                                size: 20,
                              ),
                              onPressed: () {
                                playlistController.removeSongFromPlaylist(
                                    playlistName, song.id);
                              },
                            ),
                          ],
                        ),
                      );
                    });
                  },
                ),
              ),
            ],
          );
        }),
      );
    });
  }
}
