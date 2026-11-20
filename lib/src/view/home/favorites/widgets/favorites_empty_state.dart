import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoritesEmptyState extends StatelessWidget {
  final Color cardBg;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;

  const FavoritesEmptyState({
    super.key,
    required this.cardBg,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
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
    );
  }
}
