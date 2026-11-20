import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music/src/controller/audio_controller.dart';
import 'package:music/src/controller/theme_controller.dart';
import 'package:on_audio_query/on_audio_query.dart';

/// Reusable confirmation dialog for deleting single or multiple audio files.
class DeleteSongDialog extends StatelessWidget {
  final String title;
  final String message;
  final List<SongModel> songsToDelete;
  final VoidCallback? onDeleted;

  const DeleteSongDialog({
    super.key,
    required this.title,
    required this.message,
    required this.songsToDelete,
    this.onDeleted,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    required List<SongModel> songsToDelete,
    VoidCallback? onDeleted,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => DeleteSongDialog(
        title: title,
        message: message,
        songsToDelete: songsToDelete,
        onDeleted: onDeleted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final playerController = Get.find<PlayerController>();
    final cardBg = themeController.cardBg;
    final textPrimary = themeController.textPrimary;
    final textSecondary = themeController.textSecondary;
    final borderColor = themeController.borderColor;

    return AlertDialog(
      backgroundColor: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderColor),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.acme(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(
          fontSize: 13.5,
          color: textSecondary,
          height: 1.4,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            "Cancel",
            style: TextStyle(
              color: textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            elevation: 3,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.delete_forever_rounded, size: 18),
          label: const Text(
            "Delete Permanently",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: () async {
            Navigator.of(context).pop();
            final count = await playerController.deleteSongs(songsToDelete);
            onDeleted?.call();
            Get.rawSnackbar(
              message: "Permanently deleted $count song(s) from device",
              duration: const Duration(seconds: 3),
              backgroundColor: const Color(0xff1f212c),
              icon: const Icon(Icons.check_circle_outline_rounded,
                  color: Colors.redAccent),
              margin: const EdgeInsets.all(12),
              borderRadius: 12,
            );
          },
        ),
      ],
    );
  }
}
