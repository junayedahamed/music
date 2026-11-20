import 'dart:async';

import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music/src/services/music_audio_handler.dart';
import 'package:music/src/utils/duration_formatter.dart';
import 'package:on_audio_query/on_audio_query.dart';

/// Binds AudioHandler and AudioPlayer streams to PlayerController reactive observables.
class PlayerListenerBinder {
  static List<StreamSubscription> bind({
    required MusicAudioHandler audioHandler,
    required AudioPlayer player,
    required RxBool isplaying,
    required RxDouble playbackSpeed,
    required RxInt playindex,
    required RxString songname,
    required RxString artistName,
    required RxInt currentSongId,
    required Rxn<String> currentSongUri,
    required RxString duration,
    required RxDouble max,
    required RxString position,
    required RxDouble value,
    required bool Function() hasActiveSong,
    required bool Function() isRestoring,
    required List<SongModel> Function() getActiveList,
    required Function(SongModel song) onSongChanged,
    required Function() onSaveCache,
  }) {
    double lastSavedPositionSec = 0.0;
    final subs = <StreamSubscription>[];

    subs.add(audioHandler.playbackState.listen((s) {
      isplaying.value = s.playing;
      playbackSpeed.value = s.speed;
      if (s.queueIndex != null && hasActiveSong()) {
        final list = getActiveList();
        if (s.queueIndex! >= 0 &&
            s.queueIndex! < list.length &&
            s.queueIndex! != playindex.value) {
          playindex.value = s.queueIndex!;
          final song = list[s.queueIndex!];
          songname.value = song.title;
          artistName.value = song.artist ?? "Unknown Artist";
          currentSongId.value = song.id;
          currentSongUri.value = song.uri;
          onSongChanged(song);
          onSaveCache();
        }
      }
    }));

    subs.add(audioHandler.mediaItem.listen((item) {
      if (item != null && hasActiveSong()) {
        songname.value = item.title;
        artistName.value = item.artist ?? "Unknown Artist";
        currentSongUri.value = item.id;
        if (item.duration != null && item.duration!.inSeconds > 0) {
          duration.value = DurationFormatter.format(item.duration!);
          max.value = item.duration!.inSeconds.toDouble();
        }
        final list = getActiveList();
        final idx = list.indexWhere((s) => s.uri == item.id || s.data == item.id);
        if (idx != -1) {
          playindex.value = idx;
          currentSongId.value = list[idx].id;
          onSongChanged(list[idx]);
        }
        onSaveCache();
      }
    }));

    subs.add(player.durationStream.listen((d) {
      if (!hasActiveSong()) return;
      if (d != null && d.inSeconds > 0) {
        duration.value = DurationFormatter.format(d);
        max.value = d.inSeconds.toDouble();
      }
    }));

    subs.add(player.positionStream.listen((p) {
      if (!hasActiveSong()) return;
      if (isRestoring() && p == Duration.zero && value.value > 0) {
        return; // Guard against ExoPlayer startup 0 position reset
      }
      final sec = p.inMilliseconds / 1000.0;
      if (player.playing || sec > 0.05 || !isRestoring()) {
        position.value = DurationFormatter.format(p);
        value.value = sec.clamp(0.0, max.value > 0 ? max.value : sec);
        if ((sec - lastSavedPositionSec).abs() >= 3.0) {
          lastSavedPositionSec = sec;
          onSaveCache();
        }
      }
    }));

    return subs;
  }
}
