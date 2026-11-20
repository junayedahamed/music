import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music/src/services/music_audio_handler.dart';
import 'package:on_audio_query/on_audio_query.dart';

/// Coordinates constructing media items and configuring playback queue.
class AudioPlaybackCoordinator {
  static Future<void> playAudio({
    required MusicAudioHandler audioHandler,
    required List<SongModel> list,
    required int index,
    required String uri,
    required Future<Uri?> Function(SongModel) resolveArtwork,
    required double speed,
    required LoopMode loopMode,
    required bool isShuffle,
  }) async {
    try {
      final song = (index >= 0 && index < list.length) ? list[index] : null;
      final artUri = song != null ? await resolveArtwork(song) : null;

      final items = list.map((s) => MediaItem(
            id: s.uri ?? s.data,
            title: s.title,
            artist: s.artist ?? "Unknown Artist",
            album: s.album ?? "Unknown Album",
            duration: s.duration != null && s.duration! > 0
                ? Duration(milliseconds: s.duration!)
                : null,
            artUri: s.uri == uri ? artUri : null,
            playable: true,
          )).toList();

      await audioHandler.setQueueWithPlaylist(items, initialIndex: index, play: true);
      await audioHandler.setSpeed(speed);
      await audioHandler.setLoopModeDirect(loopMode);
      await audioHandler.setShuffleModeDirect(isShuffle);
    } catch (e) {
      log("Audio playback error: $e");
    }
  }
}
