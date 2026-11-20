import 'dart:developer';

import 'package:just_audio/just_audio.dart';
import 'package:music/src/controller/audio_controller.dart';
import 'package:music/src/services/audio_cache_service.dart';
import 'package:music/src/services/song_file_service.dart';
import 'package:music/src/utils/duration_formatter.dart';
import 'package:on_audio_query/on_audio_query.dart';

/// Coordinates secondary actions: loop mode, shuffle, speed, seek, and file operations.
class PlayerActionCoordinator {
  static void toggleLoopMode(PlayerController c) {
    final next = c.loopMode.value == LoopMode.off
        ? LoopMode.all
        : (c.loopMode.value == LoopMode.all ? LoopMode.one : LoopMode.off);
    c.loopMode.value = next;
    c.audioHandler.setLoopModeDirect(next);
    c.saveCache();
    c.update();
  }

  static void toggleShuffle(PlayerController c) {
    c.isShuffle.value = !c.isShuffle.value;
    c.audioHandler.setShuffleModeDirect(c.isShuffle.value);
    c.saveCache();
  }

  static void setSpeed(PlayerController c, double speed) {
    c.playbackSpeed.value = speed;
    c.audioHandler.setSpeed(speed);
    c.saveCache();
    c.update();
  }

  static void seekToSeconds(PlayerController c, int sec) {
    if (!c.hasActiveSong) return;
    c.audioHandler.seek(Duration(seconds: sec));
    c.value.value = sec.toDouble();
    c.position.value = DurationFormatter.format(Duration(seconds: sec));
    c.saveCache();
  }

  static Future<void> togglePause(PlayerController c) async {
    try {
      if (!c.hasActiveSong) return;
      if (c.player.audioSource == null && c.songUri != null) {
        final list = c.currentPlaylist.isNotEmpty ? c.currentPlaylist : c.allsongs;
        if (list.isNotEmpty) {
          final idx = c.playindex.value >= 0 ? c.playindex.value : 0;
          await c.playaudio(c.songUri, idx, c.songname.value, playlist: list);
          if (c.value.value > 0) {
            await c.audioHandler.seek(Duration(seconds: c.value.value.toInt()));
          }
          return;
        }
      }
      c.isplaying.value ? await c.audioHandler.pause() : await c.audioHandler.play();
      c.saveCache();
    } catch (e) {
      log("Error toggling pause/play: $e");
    }
  }

  static Future<int> deleteSongs(PlayerController c, List<SongModel> songs) async {
    final count = await SongFileService.deleteAndCleanup(
      songs: songs,
      allSong: c.allsongs,
      currentPlaylist: c.currentPlaylist,
      playedSessionSongs: c.playedSessionSongs,
      songUri: c.songUri,
      currentSongId: c.currentSongId.value,
      onPlayNext: c.playnext,
      onStop: () async {
        await c.audioHandler.stop();
        c.resetIdleState();
        await AudioCacheService.clearSessionData();
      },
    );
    c.saveCache();
    AudioCacheService.saveSessionHistory(c.playedSessionSongs.toList());
    AudioCacheService.saveCachedSongs(c.allsongs);
    c.update();
    return count;
  }
}
