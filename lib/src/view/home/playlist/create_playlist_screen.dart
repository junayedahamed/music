import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:music/src/controller/audio_controller.dart';
import 'package:music/src/controller/playlist_controller.dart';
import 'package:music/src/controller/theme_controller.dart';
import 'package:on_audio_query/on_audio_query.dart';

class CreatePlaylistScreen extends StatefulWidget {
  final String playlistName;
  final List<int>? initialSelectedIds;

  const CreatePlaylistScreen({
    super.key,
    required this.playlistName,
    this.initialSelectedIds,
  });

  @override
  State<CreatePlaylistScreen> createState() => _CreatePlaylistScreenState();
}

class _CreatePlaylistScreenState extends State<CreatePlaylistScreen> {
  final PlayerController _playerController = Get.find<PlayerController>();
  final PlaylistController _playlistController = Get.find<PlaylistController>();
  final ThemeController _themeController = Get.put(ThemeController());

  final Set<int> _selectedSongIds = <int>{};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    if (widget.initialSelectedIds != null) {
      _selectedSongIds.addAll(widget.initialSelectedIds!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSong(int songId) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedSongIds.contains(songId)) {
        _selectedSongIds.remove(songId);
      } else {
        _selectedSongIds.add(songId);
      }
    });
  }

  void _selectAll(List<SongModel> songs) {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_selectedSongIds.length == songs.length) {
        _selectedSongIds.clear();
      } else {
        _selectedSongIds.clear();
        for (final song in songs) {
          _selectedSongIds.add(song.id);
        }
      }
    });
  }

  void _savePlaylist() {
    HapticFeedback.lightImpact();
    final isNew =
        !_playlistController.playlists.containsKey(widget.playlistName);
    if (isNew) {
      _playlistController.createPlaylist(
        widget.playlistName,
        _selectedSongIds.toList(),
      );
    } else {
      _playlistController.setPlaylistSongs(
        widget.playlistName,
        _selectedSongIds.toList(),
      );
    }

    Navigator.of(context).pop();
    Get.snackbar(
      "Playlist Saved",
      "Saved ${_selectedSongIds.length} songs to '${widget.playlistName}'",
      backgroundColor: _themeController.cardBg,
      colorText: _themeController.textPrimary,
      icon: Icon(Icons.check_circle_rounded,
          color: _themeController.accentGreen),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allSongs = _playerController.allsongs;
    final filteredSongs = allSongs.where((song) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final titleMatch = song.title.toLowerCase().contains(q);
      final artistMatch = (song.artist ?? "").toLowerCase().contains(q);
      return titleMatch || artistMatch;
    }).toList();

    final isAllSelected =
        allSongs.isNotEmpty && _selectedSongIds.length == allSongs.length;

    return Obx(() {
      final isDark = _themeController.isDarkMode.value;
      final scaffoldBg = _themeController.scaffoldBg;
      final cardBg = _themeController.cardBg;
      final textPrimary = _themeController.textPrimary;
      final textSecondary = _themeController.textSecondary;
      final borderColor = _themeController.borderColor;
      final accentGreen = _themeController.accentGreen;
      final accentBlue = _themeController.accentBlue;

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
                widget.playlistName,
                style: GoogleFonts.acme(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              Text(
                "${_selectedSongIds.length} of ${allSongs.length} songs selected",
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
              onPressed: () => _selectAll(allSongs),
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
            // Search Bar
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
                  controller: _searchController,
                  style: TextStyle(color: textPrimary, fontSize: 14),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search songs by title or artist...",
                    hintStyle: TextStyle(
                      color: textSecondary.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: textSecondary,
                      size: 20,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.close_rounded,
                                color: textSecondary, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = "";
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 14),
                  ),
                ),
              ),
            ),

            // Song List
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
                            _searchQuery.isNotEmpty
                                ? "No songs matching '$_searchQuery'"
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
                        final isSelected = _selectedSongIds.contains(song.id);

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 3),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => _toggleSong(song.id),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? accentGreen.withValues(alpha: 0.12)
                                      : cardBg,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? accentGreen.withValues(alpha: 0.5)
                                        : borderColor,
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Song Artwork
                                    QueryArtworkWidget(
                                      id: song.id,
                                      type: ArtworkType.AUDIO,
                                      nullArtworkWidget: Container(
                                        height: 44,
                                        width: 44,
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.black54
                                              : const Color(0xffe2e8f0),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.music_note,
                                          color: textPrimary,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Title & Artist
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            song.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: textPrimary,
                                              fontSize: 14,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            song.artist ?? "Unknown Artist",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Checkbox indicator
                                    Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? accentGreen
                                            : Colors.transparent,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? accentGreen
                                              : borderColor,
                                          width: 1.8,
                                        ),
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check_rounded,
                                              size: 16,
                                              color: Colors.black,
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),

        // Bottom floating Save button
        bottomNavigationBar: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          decoration: BoxDecoration(
            color: cardBg,
            border: Border(
              top: BorderSide(color: borderColor),
            ),
          ),
          child: SafeArea(
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _selectedSongIds.isEmpty ? null : _savePlaylist,
                icon: const Icon(Icons.playlist_add_check_rounded,
                    color: Colors.black, size: 22),
                label: Text(
                  _selectedSongIds.isEmpty
                      ? "Select songs to save"
                      : "Save Playlist (${_selectedSongIds.length} songs)",
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
