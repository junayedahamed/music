import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';

/// GetX controller managing playlist creation and song selection state.
class PlaylistEditorController extends GetxController {
  final RxSet<int> selectedSongIds = <int>{}.obs;
  final RxString searchQuery = "".obs;

  void initSelected(List<int>? initialIds) {
    if (initialIds != null) {
      selectedSongIds.addAll(initialIds);
    }
  }

  void toggleSong(int songId) {
    HapticFeedback.selectionClick();
    if (selectedSongIds.contains(songId)) {
      selectedSongIds.remove(songId);
    } else {
      selectedSongIds.add(songId);
    }
  }

  void selectAll(List<SongModel> songs) {
    HapticFeedback.mediumImpact();
    if (selectedSongIds.length == songs.length) {
      selectedSongIds.clear();
    } else {
      selectedSongIds.clear();
      for (final song in songs) {
        selectedSongIds.add(song.id);
      }
    }
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  List<SongModel> filterSongs(List<SongModel> songs) {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return songs;
    return songs.where((s) {
      final titleMatch = s.title.toLowerCase().contains(q);
      final artistMatch = (s.artist ?? "").toLowerCase().contains(q);
      return titleMatch || artistMatch;
    }).toList();
  }
}
