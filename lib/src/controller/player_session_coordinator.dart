import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music/src/controller/audio_controller.dart';
import 'package:music/src/services/audio_cache_service.dart';
import 'package:music/src/services/audio_session_restorer.dart';
import 'package:music/src/view/player%20view/waveform_art_generator.dart';

/// Handles session state loading, cache persistence, and session restoration for PlayerController.
class PlayerSessionCoordinator {
  static void loadSavedState(PlayerController c) {
    final d = AudioCacheService.getLastSessionData();
    if (d == null || !AudioCacheService.isValidSession(d)) {
      c.resetIdleState();
      return;
    }
    c.setRestoring(true);
    AudioCacheService.applySessionData(
      d,
      setIndex: (i) => c.playindex.value = i,
      setName: (n) => c.songname.value = n,
      setArtist: (a) => c.artistName.value = a,
      setId: (id) => c.currentSongId.value = id,
      setMax: (m) => c.max.value = m,
      setValue: (v) => c.value.value = v,
      setDuration: (dur) => c.duration.value = dur,
      setPosition: (p) => c.position.value = p,
      setUri: (u) => c.songUri = u,
      setSpeed: (s) => c.playbackSpeed.value = s,
      setLoop: (l) => c.loopMode.value = LoopMode.values[l],
      setShuffle: (sh) => c.isShuffle.value = sh,
    );
    c.isplaying.value = false;
  }

  static void saveCache(PlayerController c) {
    if (!c.hasActiveSong) return;
    AudioCacheService.saveSessionData({
      "isplaying": c.isplaying.value,
      "playIndex": c.playindex.value,
      "songName": c.songname.value,
      "artist": c.artistName.value,
      "songId": c.currentSongId.value,
      "max": c.max.value,
      "value": c.value.value,
      "duration": c.duration.value,
      "position": c.position.value,
      "songUri": c.songUri,
      "playbackSpeed": c.playbackSpeed.value,
      "loopMode": c.loopMode.value.index,
      "isShuffle": c.isShuffle.value,
      "playlistIds": c.currentPlaylist.map((s) => s.id).toList(),
    });
  }

  static Future<void> restoreSession(PlayerController c) async {
    if (!AudioCacheService.hasValidSession()) return;
    c.setRestoring(true);
    await AudioSessionRestorer.restore(
      allSong: c.allsongs,
      currentPlaylist: c.currentPlaylist,
      audioHandler: c.audioHandler,
      resolveArtwork: (s) =>
          WaveformArtGenerator.resolveArtwork(c.audioQuery, s),
      onResetIdle: () {
        c.resetIdleState();
        c.setRestoring(false);
        c.update();
      },
      onRestored: (idx, active, pos, maxV, dur, posStr) {
        c.playindex.value = idx;
        c.songname.value = active.title;
        c.artistName.value = active.artist ?? "Unknown Artist";
        c.currentSongId.value = active.id;
        c.songUri = active.uri;
        c.value.value = pos.inMilliseconds / 1000.0;
        c.position.value = posStr;
        if (maxV > 0) {
          c.max.value = maxV;
          c.duration.value = dur;
        }
        c.setRestoring(false);
        c.update();
      },
    );
  }
}
