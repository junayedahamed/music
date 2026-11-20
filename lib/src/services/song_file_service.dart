import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:on_audio_query/on_audio_query.dart';

/// Service for native file operations (sharing via FileProvider and permanent deletion).
class SongFileService {
  static const MethodChannel _platform = MethodChannel("com.example.music/headphone");

  static Future<bool> shareSongs(List<SongModel> songs) async {
    if (songs.isEmpty) return false;
    try {
      final paths = songs.map((s) => s.data).where((p) => p.isNotEmpty).toList();
      final titles = songs.map((s) => s.title).toList();
      final result = await _platform.invokeMethod<bool>("shareSongs", {
        "paths": paths,
        "titles": titles,
      });
      return result ?? false;
    } catch (e) {
      log("Error sharing songs: $e");
      return false;
    }
  }

  static Future<int> deleteSongs(List<SongModel> songs) async {
    if (songs.isEmpty) return 0;
    int deleted = 0;
    try {
      for (final s in songs) {
        try {
          if (s.data.isNotEmpty) {
            final f = File(s.data);
            if (await f.exists()) {
              await f.delete();
              deleted++;
            }
          }
        } catch (e) {
          log("Error deleting file ${s.data}: $e");
        }
      }

      final paths = songs.map((s) => s.data).where((p) => p.isNotEmpty).toList();
      final uris = songs.map((s) => s.uri ?? "").where((u) => u.isNotEmpty).toList();
      await _platform.invokeMethod("deleteSongs", {
        "paths": paths,
        "uris": uris,
      });
    } catch (e) {
      log("Error deleting songs: $e");
    }
    return deleted > 0 ? deleted : songs.length;
  }

  static Future<int> deleteAndCleanup({
    required List<SongModel> songs,
    required List<SongModel> allSong,
    required List<SongModel> currentPlaylist,
    required List<Map<String, dynamic>> playedSessionSongs,
    required String? songUri,
    required int currentSongId,
    required Function() onPlayNext,
    required Function() onStop,
  }) async {
    final count = await deleteSongs(songs);
    final deletedIds = songs.map((s) => s.id).toSet();
    if (songUri != null && songs.any((s) => s.uri == songUri || s.id == currentSongId)) {
      if (allSong.length > songs.length) {
        onPlayNext();
      } else {
        onStop();
      }
    }
    allSong.removeWhere((s) => deletedIds.contains(s.id));
    currentPlaylist.removeWhere((s) => deletedIds.contains(s.id));
    playedSessionSongs.removeWhere((m) => deletedIds.contains((m['id'] as num?)?.toInt()));
    return count;
  }
}
