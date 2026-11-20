import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music/src/controller/audio_controller.dart';
import 'package:on_audio_query/on_audio_query.dart';

class FavoritesHeaderBanner extends StatelessWidget {
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final List<SongModel> favSongs;
  final PlayerController playerController;

  const FavoritesHeaderBanner({
    super.key,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.favSongs,
    required this.playerController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xff2d1222), const Color(0xff1f212c)]
                : [const Color(0xfffce4ec), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xffff4081).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xffff4081), Color(0xfff50057)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xffff4081).withValues(alpha: 0.4),
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
                    style: TextStyle(fontSize: 12, color: textSecondary),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
