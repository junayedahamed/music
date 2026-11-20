import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music/src/controller/theme_controller.dart';
import 'package:music/src/view/home/playlist/create_playlist_screen.dart';

/// Dialog to input a new playlist name and proceed to song picker.
class CreatePlaylistDialog {
  static void show(BuildContext context, ThemeController themeController) {
    final textController = TextEditingController();
    final cardBg = themeController.cardBg;
    final textPrimary = themeController.textPrimary;
    final textSecondary = themeController.textSecondary;
    final accentGreen = themeController.accentGreen;
    final isDark = themeController.isDarkMode.value;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(Icons.playlist_add_rounded, color: accentGreen),
            const SizedBox(width: 8),
            Text(
              "Create Playlist",
              style: GoogleFonts.acme(color: textPrimary, fontSize: 20),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter a name for your playlist. You will choose songs next.",
              style: TextStyle(color: textSecondary, fontSize: 12.5),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              autofocus: true,
              style: TextStyle(color: textPrimary),
              decoration: InputDecoration(
                hintText: "Playlist name (e.g. Chill Beats)",
                hintStyle:
                    TextStyle(color: textSecondary.withValues(alpha: 0.5)),
                filled: true,
                fillColor:
                    isDark ? const Color(0xff161822) : const Color(0xfff3f4f8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: accentGreen, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("Cancel", style: TextStyle(color: textSecondary)),
          ),
          TextButton(
            onPressed: () {
              final name = textController.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
                Get.to(() => CreatePlaylistScreen(playlistName: name));
              }
            },
            child: Text("Next: Choose Songs",
                style: TextStyle(
                    color: accentGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
