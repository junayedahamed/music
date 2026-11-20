import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music/src/controller/audio_controller.dart';
import 'package:music/src/controller/favorite_controller.dart';
import 'package:music/src/controller/theme_controller.dart';
import 'package:music/src/view/home/favorites/widgets/favorites_empty_state.dart';
import 'package:music/src/view/home/favorites/widgets/favorites_header_banner.dart';
import 'package:music/src/view/music%20tile/music_listtile.dart';
import 'package:on_audio_query/on_audio_query.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favController = Get.put(FavoriteController());
    final playerController = Get.find<PlayerController>();
    final themeController = Get.put(ThemeController());

    return Obx(() {
      final scaffoldBg = themeController.scaffoldBg;
      final cardBg = themeController.cardBg;
      final textPrimary = themeController.textPrimary;
      final textSecondary = themeController.textSecondary;
      final borderColor = themeController.borderColor;
      final isDark = themeController.isDarkMode.value;

      final favSongs = favController.filterFavorites(playerController.allsongs);

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
            "Favorites",
            style: GoogleFonts.acme(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          actions: [
            if (favSongs.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xffff4081).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xffff4081).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      "${favSongs.length} songs",
                      style: const TextStyle(
                        color: Color(0xffff4081),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: favSongs.isEmpty
            ? FavoritesEmptyState(
                cardBg: cardBg,
                borderColor: borderColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              )
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: FavoritesHeaderBanner(
                      isDark: isDark,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      favSongs: favSongs,
                      playerController: playerController,
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final song = favSongs[index];

                        return MusicListtile(
                          songUri: song.uri,
                          songId: song.id,
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
                              child: const Icon(
                                Icons.music_note,
                                color: Color(0xffff4081),
                                size: 24,
                              ),
                            ),
                          ),
                          onPressed: () {
                            playerController.playOrNavigate(
                              song,
                              index,
                              favSongs,
                            );
                          },
                          musicName: song.title,
                          artistName: song.artist ?? "Unknown Artist",
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.favorite_rounded,
                              color: Color(0xffff4081),
                              size: 22,
                            ),
                            tooltip: "Remove from favorites",
                            onPressed: () {
                              favController.toggleFavorite(song);
                            },
                          ),
                        );
                      },
                      childCount: favSongs.length,
                    ),
                  ),
                ],
              ),
      );
    });
  }
}
