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
    required List<SongModel> Function() getActiveList,
    required Function(SongModel song) onSongChanged,
    required Function() onSaveCache,
  }) {
    double lastSavedPositionSec = 0.0;
    final subs = <StreamSubscription>[];

    subs.add(audioHandler.playbackState.listen((s) {
      isplaying.value = s.playing;
      playbackSpeed.value = s.speed;
      if (s.queueIndex != null) {
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
      if (item != null) {
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
      duration.value = (d != null && d.inSeconds > 0) ? DurationFormatter.format(d) : "0:00";
      max.value = (d != null && d.inSeconds > 0) ? d.inSeconds.toDouble() : 0.0;
    }));

    subs.add(player.positionStream.listen((p) {
      position.value = DurationFormatter.format(p);
      final sec = p.inSeconds.toDouble();
      value.value = sec.clamp(0.0, max.value > 0 ? max.value : sec);
      if ((sec - lastSavedPositionSec).abs() >= 5.0) {
        lastSavedPositionSec = sec;
        onSaveCache();
      }
    }));

    return subs;
  }
}
