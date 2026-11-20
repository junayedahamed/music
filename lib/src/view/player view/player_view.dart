import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music/src/controller/audio_controller.dart';
import 'package:music/src/controller/favorite_controller.dart';
import 'package:music/src/controller/theme_controller.dart';
import 'package:music/src/view/player%20view/widgets/player_artwork_view.dart';
import 'package:music/src/view/player%20view/widgets/player_controls_row.dart';
import 'package:music/src/view/player%20view/widgets/player_progress_slider.dart';
import 'package:music/src/view/player%20view/widgets/player_speed_bottom_sheet.dart';
import 'package:music/src/view/player%20view/widgets/player_track_info_row.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Player extends StatelessWidget {
  const Player({
    super.key,
    required this.songs,
  });

  final List<SongModel> songs;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlayerController>();
    final favController = Get.put(FavoriteController());
    final themeController = Get.put(ThemeController());

    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final scaffoldBg = themeController.scaffoldBg;
      final cardBg = themeController.cardBg;
      final cardAltBg = themeController.cardAltBg;
      final textPrimary = themeController.textPrimary;
      final textSecondary = themeController.textSecondary;
      final borderColor = themeController.borderColor;
      final accentBlue = themeController.accentBlue;
      final accentGreen = themeController.accentGreen;

      final activeSongs = controller.currentPlaylist.isNotEmpty
          ? controller.currentPlaylist
          : songs;
      final idx = controller.playindex.value;
      final safeSong = controller.hasActiveSong
          ? ((idx >= 0 &&
                  idx < activeSongs.length &&
                  activeSongs[idx].uri == controller.songUri)
              ? activeSongs[idx]
              : (activeSongs.firstWhereOrNull((s) =>
                      s.uri == controller.songUri ||
                      s.id == controller.currentSongId.value) ??
                  ((idx >= 0 && idx < activeSongs.length)
                      ? activeSongs[idx]
                      : null)))
          : null;
      final title = safeSong?.title ?? controller.songname.value;
      final artist = safeSong?.artist ?? controller.artistName.value;
      final songId = safeSong?.id ?? controller.currentSongId.value;

      return Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          systemOverlayStyle:
              isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
          leading: IconButton(
            tooltip: "Back",
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Get.back();
              }
            },
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: textPrimary,
              size: 20,
            ),
          ),
          centerTitle: false,
          title: Text(
            "NOW PLAYING",
            style: GoogleFonts.acme(
              fontSize: 14,
              letterSpacing: 2.0,
              color: textSecondary,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Material(
                  color: cardAltBg,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => PlayerSpeedBottomSheet.show(
                        context, controller, themeController),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.speed_rounded,
                              size: 14, color: accentBlue),
                          const SizedBox(width: 4),
                          Text(
                            "${controller.playbackSpeed.value}x",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PlayerArtworkView(
                  song: safeSong,
                  songId: songId,
                  isDark: isDark,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  accentBlue: accentBlue,
                  accentGreen: accentGreen,
                  controller: controller,
                  themeController: themeController,
                ),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: borderColor,
                      width: 1.2,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.4)
                          : Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PlayerTrackInfoRow(
                      title: title,
                      artist: artist,
                      song: safeSong,
                      isDark: isDark,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      borderColor: borderColor,
                      favController: favController,
                    ),
                    const SizedBox(height: 16),
                    PlayerProgressSlider(
                      controller: controller,
                      isDark: isDark,
                      accentBlue: accentBlue,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 16),
                    PlayerControlsRow(
                      controller: controller,
                      accentBlue: accentBlue,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
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
