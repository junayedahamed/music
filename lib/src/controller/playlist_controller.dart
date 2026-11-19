import 'dart:developer';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class PlaylistController extends GetxController {
  final playlists = <String, List<int>>{}.obs;
  late Box<Map> _cacheBox;

  @override
  void onInit() {
    super.onInit();
    _loadPlaylists();
  }

  void _loadPlaylists() {
    try {
      _cacheBox = Hive.box<Map>("music");
      final data = _cacheBox.get("user_playlists");
      if (data != null) {
        data.forEach((key, value) {
          if (value is List) {
            playlists[key.toString()] = List<int>.from(value);
          }
        });
      }
    } catch (e) {
      log("Error loading playlists: $e");
    }
  }

  Future<void> _savePlaylists() async {
    try {
      await _cacheBox.put("user_playlists", playlists);
    } catch (e) {
      log("Error saving playlists: $e");
    }
  }

  bool createPlaylist(String name, [List<int>? songIds]) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    if (playlists.containsKey(trimmed)) return false;

    playlists[trimmed] = songIds != null ? List<int>.from(songIds) : [];
    _savePlaylists();
    return true;
  }

  void setPlaylistSongs(String name, List<int> songIds) {
    if (!playlists.containsKey(name)) return;
    playlists[name] = List<int>.from(songIds);
    _savePlaylists();
  }

  List<int> getPlaylistSongIds(String name) {
    return playlists[name] ?? [];
  }

  void deletePlaylist(String name) {
    playlists.remove(name);
    _savePlaylists();
  }

  void addSongToPlaylist(String playlistName, int songId) {
    if (!playlists.containsKey(playlistName)) return;
    final list = playlists[playlistName]!;
    if (!list.contains(songId)) {
      list.add(songId);
      playlists[playlistName] = List.from(list);
      _savePlaylists();
    }
  }

  void removeSongFromPlaylist(String playlistName, int songId) {
    if (!playlists.containsKey(playlistName)) return;
    playlists[playlistName]!.remove(songId);
    playlists[playlistName] = List.from(playlists[playlistName]!);
    _savePlaylists();
  }
}
