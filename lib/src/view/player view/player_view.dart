import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:music/src/controller/audio_controller.dart';
import 'package:music/src/controller/favorite_controller.dart';
import 'package:music/src/controller/theme_controller.dart';
import 'package:music/src/view/player%20view/audio_wave_visualizer.dart';
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

      final activeSongs = controller.currentPlaylist.isNotEmpty
          ? controller.currentPlaylist
          : songs;
      final idx = controller.playindex.value;
      final safeSong = (idx >= 0 &&
              idx < activeSongs.length &&
              activeSongs[idx].uri == controller.songUri)
          ? activeSongs[idx]
          : (activeSongs.firstWhereOrNull((s) =>
                  s.uri == controller.songUri ||
                  s.id == controller.currentSongId.value) ??
              ((idx >= 0 && idx < activeSongs.length)
                  ? activeSongs[idx]
                  : null));
      final title = safeSong?.title ?? controller.songname.value;
      final artist = safeSong?.artist ?? controller.artistName.value;
      final songId = safeSong?.id ?? controller.currentSongId.value;
      final isFav = favController.isFavorite(songId);

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
            // Playback speed selector pill
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Material(
                  color: cardAltBg,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showSpeedSelector(
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
              // Visual artwork section in center
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Hero(
                      tag: "album_art_${safeSong?.id ?? 'default'}",
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
                          child: (safeSong != null || songId > 0)
                              ? QueryArtworkWidget(
                                  id: safeSong?.id ?? songId,
                                  type: ArtworkType.AUDIO,
                                  artworkWidth: double.infinity,
                                  artworkHeight: double.infinity,
                                  artworkFit: BoxFit.cover,
                                  nullArtworkWidget: _buildArtworkFallback(
                                      context, themeController, controller),
                                )
                              : _buildArtworkFallback(
                                  context, themeController, controller),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom control panel card
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
                    // Title, Artist and Heart Favorite button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.acme(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Animated Favorite Heart Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () {
                              if (safeSong != null) {
                                favController.toggleFavorite(safeSong);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isFav
                                    ? const Color(0xffff4081)
                                        .withValues(alpha: 0.15)
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : const Color(0xfff3f4f8)),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isFav
                                      ? const Color(0xffff4081)
                                          .withValues(alpha: 0.4)
                                      : borderColor,
                                ),
                              ),
                              child: Icon(
                                isFav
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: isFav
                                    ? const Color(0xffff4081)
                                    : textSecondary,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Progress Slider & Timestamps
                    Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6.5),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 14),
                            activeTrackColor: accentBlue,
                            inactiveTrackColor: isDark
                                ? Colors.white.withValues(alpha: 0.15)
                                : const Color(0xffe2e8f0),
                            thumbColor: accentBlue,
                            overlayColor: accentBlue.withValues(alpha: 0.2),
                          ),
                          child: Slider(
                            min: 0,
                            max: controller.max.value > 0
                                ? controller.max.value
                                : 1.0,
                            value: controller.value.value.clamp(
                                0.0,
                                controller.max.value > 0
                                    ? controller.max.value
                                    : 1.0),
                            onChanged: (value) {
                              controller.changedurationToseconds(value.toInt());
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                controller.position.value,
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                controller.duration.value,
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Controls Row (Shuffle, Previous, Play/Pause, Next, Repeat)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Shuffle Button
                        IconButton(
                          tooltip: "Shuffle",
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            controller.toggleShuffle();
                          },
                          icon: Icon(
                            Icons.shuffle_rounded,
                            size: 24,
                            color: controller.isShuffle.value
                                ? accentBlue
                                : textSecondary.withValues(alpha: 0.5),
                          ),
                        ),

                        // Previous Button
                        IconButton(
                          tooltip: "Previous Track",
                          onPressed: controller.hasPrevious
                              ? () {
                                  HapticFeedback.mediumImpact();
                                  controller.playprevious();
                                }
                              : null,
                          icon: Icon(
                            Icons.skip_previous_rounded,
                            size: 38,
                            color: controller.hasPrevious
                                ? textPrimary
                                : textSecondary.withValues(alpha: 0.25),
                          ),
                        ),

                        // Play / Pause Floating Action Button
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
                              controller.isplaying.value
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 36,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        // Next Button
                        IconButton(
                          tooltip: "Next Track",
                          onPressed: controller.hasNext
                              ? () {
                                  HapticFeedback.mediumImpact();
                                  controller.playnext();
                                }
                              : null,
                          icon: Icon(
                            Icons.skip_next_rounded,
                            size: 38,
                            color: controller.hasNext
                                ? textPrimary
                                : textSecondary.withValues(alpha: 0.25),
                          ),
                        ),

                        // Repeat Button (off, all, one)
                        IconButton(
                          tooltip: "Repeat Mode",
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            controller.toggleLoopMode();
                          },
                          icon: Icon(
                            controller.loopMode.value == LoopMode.one
                                ? Icons.repeat_one_rounded
                                : Icons.repeat_rounded,
                            size: 24,
                            color: controller.loopMode.value != LoopMode.off
                                ? accentBlue
                                : textSecondary.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
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

  Widget _buildArtworkFallback(BuildContext context,
      ThemeController themeController, PlayerController controller) {
    final isDark = themeController.isDarkMode.value;
    final accentBlue = themeController.accentBlue;
    final accentGreen = themeController.accentGreen;

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
        child: BeatWaveformCircle(
          isPlaying: controller.isplaying.value,
          size: 110,
          primaryColor: accentBlue,
          secondaryColor: accentGreen,
        ),
      ),
    );
  }

  void _showSpeedSelector(BuildContext context, PlayerController controller,
      ThemeController themeController) {
    final cardBg = themeController.cardBg;
    final textPrimary = themeController.textPrimary;
    final textSecondary = themeController.textSecondary;
    final accentBlue = themeController.accentBlue;
    final borderColor = themeController.borderColor;

    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Playback Speed",
              style: GoogleFonts.acme(
                fontSize: 20,
                color: textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Select playback speed multiplier",
              style: TextStyle(fontSize: 12, color: textSecondary),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: speeds.map((s) {
                final isSelected = controller.playbackSpeed.value == s;
                return ChoiceChip(
                  label: Text("${s}x"),
                  selected: isSelected,
                  selectedColor: accentBlue,
                  backgroundColor: themeController.cardAltBg,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: isSelected ? accentBlue : borderColor,
                  ),
                  onSelected: (val) {
                    if (val) {
                      HapticFeedback.selectionClick();
                      controller.setPlaybackSpeed(s);
                      Navigator.of(ctx).pop();
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
