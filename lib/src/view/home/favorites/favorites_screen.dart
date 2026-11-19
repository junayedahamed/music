import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:music/src/controller/audio_controller.dart';
import 'package:music/src/controller/favorite_controller.dart';
import 'package:music/src/controller/theme_controller.dart';
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
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: cardBg,
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor),
                        ),
                        child: const Icon(
                          Icons.favorite_border_rounded,
                          size: 64,
                          color: Color(0xffff4081),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        "No Favorite Songs Yet",
                        style: GoogleFonts.acme(
                          fontSize: 22,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tap the heart icon (❤️) on any song in the player to save it to your favorites list.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Header Hero Banner with Play All
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [
                                    const Color(0xff2d1222),
                                    const Color(0xff1f212c),
                                  ]
                                : [
                                    const Color(0xfffce4ec),
                                    Colors.white,
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xffff4081)
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xffff4081),
                                    Color(0xfff50057)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xffff4081)
                                        .withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.favorite_rounded,
                                  color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Liked Tracks",
                                    style: GoogleFonts.acme(
                                      fontSize: 20,
                                      color: textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${favSongs.length} favorite songs",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                playerController.playOrNavigate(
                                  favSongs[0],
                                  0,
                                  favSongs,
                                );
                              },
                              icon: const Icon(Icons.play_arrow_rounded,
                                  color: Colors.white, size: 20),
                              label: const Text(
                                "Play All",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xffff4081),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // List of favorite songs
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
