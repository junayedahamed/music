import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';

import 'package:just_audio/just_audio.dart';
import 'package:music/src/services/audio_cache_service.dart';
import 'package:music/src/services/music_audio_handler.dart';
import 'package:music/src/utils/duration_formatter.dart';
import 'package:on_audio_query/on_audio_query.dart';

/// Helper to safely restore previous playback session state on startup.
class AudioSessionRestorer {
  static Future<void> restore({
    required List<SongModel> allSong,
    required List<SongModel> currentPlaylist,
    required MusicAudioHandler audioHandler,
    required Future<Uri?> Function(SongModel) resolveArtwork,
    required Function(int idx, SongModel song, Duration pos, double maxVal,
            String dur, String posStr)
        onRestored,
    required Function() onResetIdle,
  }) async {
    try {
      final data = AudioCacheService.getLastSessionData();
      if (data == null || !AudioCacheService.isValidSession(data)) {
        onResetIdle();
        return;
      }
      final savedUri = data["songUri"] as String?;
      final savedId = (data["songId"] as num?)?.toInt();
      if ((savedId == null || savedId <= 0) &&
          (savedUri == null || savedUri.isEmpty)) {
        onResetIdle();
        return;
      }

      // Check whether the persisted song exists in the device audio library
      final matchedSong = allSong.firstWhereOrNull(
        (s) =>
            (savedId != null && savedId > 0 && s.id == savedId) ||
            (savedUri != null &&
                savedUri.isNotEmpty &&
                (s.uri == savedUri || s.data == savedUri)),
      );

      // Rule: Song removed from device -> remain idle, do NOT select first song!
      if (matchedSong == null) {
        log("Saved song no longer on device. Remaining idle.");
        await AudioCacheService.clearSessionData();
        onResetIdle();
        return;
      }

      // Restore playlist
      final savedIds = data["playlistIds"] as List<dynamic>?;
      if (savedIds != null && savedIds.isNotEmpty) {
        final songMap = {for (var s in allSong) s.id: s};
        final restored = savedIds
            .map((id) => songMap[(id as num).toInt()])
            .whereType<SongModel>()
            .toList();
        if (restored.isNotEmpty) {
          currentPlaylist.clear();
          currentPlaylist.addAll(restored);
        }
      }
      if (currentPlaylist.isEmpty) {
        currentPlaylist.addAll(allSong);
      }
      if (currentPlaylist.isEmpty) {
        onResetIdle();
        return;
      }

      int idx = currentPlaylist.indexWhere((s) => s.id == matchedSong.id);
      if (idx == -1) {
        currentPlaylist.insert(0, matchedSong);
        idx = 0;
      }

      final savedSec = (data["value"] as num?)?.toDouble() ?? 0.0;
      final initPos = Duration(milliseconds: (savedSec * 1000).toInt());

      final defaultMax =
          (matchedSong.duration != null && matchedSong.duration! > 0)
              ? matchedSong.duration! / 1000.0
              : 0.0;
      final savedMax = (data["max"] as num?)?.toDouble() ?? defaultMax;
      final savedDur = data["duration"] as String? ??
          (savedMax > 0
              ? DurationFormatter.format(Duration(seconds: savedMax.toInt()))
              : "0:00");
      final savedPosStr =
          data["position"] as String? ?? DurationFormatter.format(initPos);

      final artUri = await resolveArtwork(matchedSong);
      final items = currentPlaylist
          .map((s) => MediaItem(
                id: s.uri ?? s.data,
                title: s.title,
                artist: s.artist ?? "Unknown Artist",
                album: s.album ?? "Unknown Album",
                duration: s.duration != null && s.duration! > 0
                    ? Duration(milliseconds: s.duration!)
                    : null,
                artUri: s.id == matchedSong.id ? artUri : null,
                playable: true,
              ))
          .toList();

      await audioHandler.setQueueWithPlaylist(
        items,
        initialIndex: idx,
        initialPosition: initPos,
        play: false, // Must remain paused on restoration
      );

      final savedSpeed = (data["playbackSpeed"] as num?)?.toDouble() ?? 1.0;
      await audioHandler.setSpeed(savedSpeed);

      if (data["loopMode"] is int) {
        final lIdx =
            (data["loopMode"] as int).clamp(0, LoopMode.values.length - 1);
        await audioHandler.setLoopModeDirect(LoopMode.values[lIdx]);
      }
      final isShuff = data["isShuffle"] as bool? ?? false;
      await audioHandler.setShuffleModeDirect(isShuff);

      onRestored(idx, matchedSong, initPos, savedMax, savedDur, savedPosStr);
    } catch (e) {
      log("Error restoring audio session: $e");
      onResetIdle();
    }
  }
}
