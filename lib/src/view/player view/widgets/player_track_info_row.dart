import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music/src/controller/favorite_controller.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlayerTrackInfoRow extends StatelessWidget {
  final String title;
  final String artist;
  final SongModel? song;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderColor;
  final FavoriteController favController;

  const PlayerTrackInfoRow({
    super.key,
    required this.title,
    required this.artist,
    required this.song,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderColor,
    required this.favController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
        Obx(() {
          final songId = song?.id ?? 0;
          final isFav = favController.isFavorite(songId);

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                if (song != null) {
                  favController.toggleFavorite(song!);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isFav
                      ? const Color(0xffff4081).withValues(alpha: 0.15)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : const Color(0xfff3f4f8)),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isFav
                        ? const Color(0xffff4081).withValues(alpha: 0.4)
                        : borderColor,
                  ),
                ),
                child: Icon(
                  isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFav ? const Color(0xffff4081) : textSecondary,
                  size: 24,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
