import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music/src/services/audio_cache_service.dart';
import 'package:music/src/services/music_audio_handler.dart';
import 'package:on_audio_query/on_audio_query.dart';

/// Helper to restore previous playback session state on application startup.
class AudioSessionRestorer {
  static Future<void> restore({
    required List<SongModel> allSong,
    required List<SongModel> currentPlaylist,
    required MusicAudioHandler audioHandler,
    required Future<Uri?> Function(SongModel) resolveArtwork,
    required Function(int idx, SongModel song, Duration pos, double maxVal, String dur) onRestored,
  }) async {
    try {
      final data = AudioCacheService.getLastSessionData();
      if (data == null) return;
      final savedUri = data["songUri"] as String?;
      final savedId = (data["songId"] as num?)?.toInt();
      if (savedUri == null || savedUri.isEmpty) return;

      final savedIds = data["playlistIds"] as List<dynamic>?;
      if (savedIds != null && savedIds.isNotEmpty) {
        final songMap = {for (var s in allSong) s.id: s};
        final restored = savedIds.map((id) => songMap[(id as num).toInt()]).whereType<SongModel>().toList();
        if (restored.isNotEmpty) {
          currentPlaylist.clear();
          currentPlaylist.addAll(restored);
        }
      }
      if (currentPlaylist.isEmpty) currentPlaylist.addAll(allSong);
      if (currentPlaylist.isEmpty) return;

      int idx = (data["playIndex"] as num?)?.toInt() ?? 0;
      if (idx < 0 || idx >= currentPlaylist.length || currentPlaylist[idx].uri != savedUri) {
        final found = currentPlaylist.indexWhere((s) => s.uri == savedUri || (savedId != null && s.id == savedId));
        idx = found != -1 ? found : 0;
      }
      final active = currentPlaylist[idx];
      final savedSec = (data["value"] as num?)?.toInt() ?? 0;
      final initPos = Duration(seconds: savedSec);
      final artUri = await resolveArtwork(active);

      final items = currentPlaylist.map((s) => MediaItem(
            id: s.uri ?? s.data,
            title: s.title,
            artist: s.artist ?? "Unknown Artist",
            album: s.album ?? "Unknown Album",
            duration: s.duration != null && s.duration! > 0 ? Duration(milliseconds: s.duration!) : null,
            artUri: s.uri == savedUri ? artUri : null,
            playable: true,
          )).toList();

      await audioHandler.setQueueWithPlaylist(items, initialIndex: idx, initialPosition: initPos, play: false);

      final savedSpeed = (data["playbackSpeed"] as num?)?.toDouble() ?? 1.0;
      await audioHandler.setSpeed(savedSpeed);

      if (data["loopMode"] is int) {
        final lIdx = data["loopMode"] as int;
        if (lIdx >= 0 && lIdx < LoopMode.values.length) {
          await audioHandler.setLoopModeDirect(LoopMode.values[lIdx]);
        }
      }
      final isShuff = data["isShuffle"] as bool? ?? false;
      await audioHandler.setShuffleModeDirect(isShuff);

      final savedMax = (data["max"] as num?)?.toDouble() ?? 0.0;
      final savedDur = data["duration"] as String? ?? "0:00";
      onRestored(idx, active, initPos, savedMax, savedDur);
    } catch (e) {
      log("Error restoring audio session: $e");
    }
  }
}
