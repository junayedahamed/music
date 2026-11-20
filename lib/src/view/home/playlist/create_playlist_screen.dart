import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music/src/controller/audio_controller.dart';
import 'package:music/src/controller/playlist_controller.dart';
import 'package:music/src/controller/playlist_editor_controller.dart';
import 'package:music/src/controller/theme_controller.dart';
import 'package:music/src/view/home/playlist/widgets/playlist_song_picker_tile.dart';

class CreatePlaylistScreen extends StatelessWidget {
  final String playlistName;
  final List<int>? initialSelectedIds;

  const CreatePlaylistScreen({
    super.key,
    required this.playlistName,
    this.initialSelectedIds,
  });

  void _savePlaylist(
    BuildContext context,
    PlaylistEditorController editorController,
    PlaylistController playlistController,
    ThemeController themeController,
  ) {
    HapticFeedback.lightImpact();
    final ids = editorController.selectedSongIds.toList();
    final isNew = !playlistController.playlists.containsKey(playlistName);
    if (isNew) {
      playlistController.createPlaylist(playlistName, ids);
    } else {
      playlistController.setPlaylistSongs(playlistName, ids);
    }

    Navigator.of(context).pop();
    Get.snackbar(
      "Playlist Saved",
      "Saved ${ids.length} songs to '$playlistName'",
      backgroundColor: themeController.cardBg,
      colorText: themeController.textPrimary,
      icon: Icon(Icons.check_circle_rounded, color: themeController.accentGreen),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerController = Get.find<PlayerController>();
    final playlistController = Get.find<PlaylistController>();
    final themeController = Get.put(ThemeController());
    final editorController = Get.put(PlaylistEditorController());

    if (editorController.selectedSongIds.isEmpty && initialSelectedIds != null) {
      editorController.initSelected(initialSelectedIds);
    }

    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final scaffoldBg = themeController.scaffoldBg;
      final cardBg = themeController.cardBg;
      final textPrimary = themeController.textPrimary;
      final textSecondary = themeController.textSecondary;
      final borderColor = themeController.borderColor;
      final accentGreen = themeController.accentGreen;
      final accentBlue = themeController.accentBlue;

      final allSongs = playerController.allsongs;
      final filteredSongs = editorController.filterSongs(allSongs);
      final selectedCount = editorController.selectedSongIds.length;
      final isAllSelected = allSongs.isNotEmpty && selectedCount == allSongs.length;

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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                playlistName,
                style: GoogleFonts.acme(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              Text(
                "$selectedCount of ${allSongs.length} songs selected",
                style: TextStyle(
                  fontSize: 12,
                  color: accentGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => editorController.selectAll(allSongs),
              child: Text(
                isAllSelected ? "Deselect All" : "Select All",
                style: TextStyle(
                  color: accentBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: TextField(
                  style: TextStyle(color: textPrimary, fontSize: 14),
                  onChanged: editorController.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: "Search songs by title or artist...",
                    hintStyle: TextStyle(
                      color: textSecondary.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: textSecondary, size: 20),
                    suffixIcon: editorController.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.close_rounded,
                                color: textSecondary, size: 18),
                            onPressed: () => editorController.setSearchQuery(""),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 14),
                  ),
                ),
              ),
            ),
            Expanded(
              child: filteredSongs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 48,
                              color: textSecondary.withValues(alpha: 0.4)),
                          const SizedBox(height: 12),
                          Text(
                            editorController.searchQuery.value.isNotEmpty
                                ? "No songs matching '${editorController.searchQuery.value}'"
                                : "No songs found on device",
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredSongs.length,
                      padding: const EdgeInsets.only(bottom: 90),
                      itemBuilder: (context, index) {
                        final song = filteredSongs[index];
                        final isSelected =
                            editorController.selectedSongIds.contains(song.id);

                        return PlaylistSongPickerTile(
                          song: song,
                          isSelected: isSelected,
                          isDark: isDark,
                          cardBg: cardBg,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          borderColor: borderColor,
                          accentGreen: accentGreen,
                          onTap: () => editorController.toggleSong(song.id),
                        );
                      },
                    ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          decoration: BoxDecoration(
            color: cardBg,
            border: Border(top: BorderSide(color: borderColor)),
          ),
          child: SafeArea(
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: selectedCount == 0
                    ? null
                    : () => _savePlaylist(context, editorController,
                        playlistController, themeController),
                icon: const Icon(Icons.playlist_add_check_rounded,
                    color: Colors.black, size: 22),
                label: Text(
                  selectedCount == 0
                      ? "Select songs to save"
                      : "Save Playlist ($selectedCount songs)",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentGreen,
                  disabledBackgroundColor:
                      isDark ? Colors.white12 : const Color(0xffd1d5db),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
