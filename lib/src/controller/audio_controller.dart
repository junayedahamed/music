import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music/src/view/home/home_view.dart';
import 'package:music/src/view/home/sort_song_by_order.dart';
import 'package:music/src/view/player%20view/audio_wave_visualizer.dart';
import 'package:music/src/view/player%20view/player_view.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class PlayerController extends GetxController {
  final audioQuery = OnAudioQuery();
  final SortSongByOrder sort = SortSongByOrder();
  List<SongModel> _allSong = [];
  final player = AudioPlayer();

  final playindex = 0.obs;
  final isplaying = false.obs;
  String? songUri;
  final loading = true.obs;
  final max = 0.0.obs;
  final value = 0.0.obs;
  final duration = "0:00".obs;
  final position = "0:00".obs;
  final songname = "Please select a song to play".obs;
  final loopMode = LoopMode.off.obs;
  final isShuffle = false.obs;
  final playbackSpeed = 1.0.obs;
  List<SongModel> currentPlaylist = [];
  late Box<Map> musicCacheBox;

  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  @override
  void onInit() {
    super.onInit();
    musicCacheBox = Hive.box<Map>("music");
    checkAndRequestPermission();
    _initAudioListeners();

    final alldata = musicCacheBox.get("data");
    if (alldata != null) {
      isplaying.value = alldata["isplaying"] ?? false;
      playindex.value = alldata["playIndex"] ?? 0;
      songname.value = alldata["songName"] ?? "Please select a song to play";
      max.value = (alldata['max'] as num?)?.toDouble() ?? 0.0;
      value.value = (alldata["value"] as num?)?.toDouble() ?? 0.0;
      duration.value = alldata["duration"] ?? "0:00";
      position.value = alldata["position"] ?? "0:00";
      songUri = alldata["songUri"];
    }
  }

  @override
  void onClose() {
    _saveCache();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    player.dispose();
    super.onClose();
  }

  void _saveCache() async {
    try {
      final data = {
        "isplaying": isplaying.value,
        "playIndex": playindex.value,
        "songName": songname.value,
        "max": max.value,
        "value": value.value,
        "duration": duration.value,
        "position": position.value,
        "songUri": songUri,
      };
      await musicCacheBox.clear();
      await musicCacheBox.put("data", data);
    } catch (_) {}
  }

  void _initAudioListeners() {
    _durationSubscription = player.durationStream.listen((d) {
      if (d != null && d.inSeconds > 0) {
        duration.value = _formatDuration(d);
        max.value = d.inSeconds.toDouble();
      } else {
        duration.value = "0:00";
        max.value = 0.0;
      }
    });

    _positionSubscription = player.positionStream.listen((p) {
      position.value = _formatDuration(p);
      final sec = p.inSeconds.toDouble();
      value.value = sec.clamp(0.0, max.value > 0 ? max.value : sec);
    });

    _playerStateSubscription = player.playerStateStream.listen((state) {
      isplaying.value = state.playing;
      if (state.processingState == ProcessingState.completed) {
        if (loopMode.value == LoopMode.one) {
          player.seek(Duration.zero);
          player.play();
        } else if (loopMode.value == LoopMode.all) {
          playnext();
        } else {
          final list = currentPlaylist.isNotEmpty ? currentPlaylist : _allSong;
          if (playindex.value < list.length - 1) {
            playnext();
          } else {
            isplaying.value = false;
            player.pause();
          }
        }
      }
    });

    player.currentIndexStream.listen((newIndex) {
      if (newIndex != null) {
        final list = currentPlaylist.isNotEmpty ? currentPlaylist : _allSong;
        if (newIndex >= 0 &&
            newIndex < list.length &&
            newIndex != playindex.value) {
          playindex.value = newIndex;
          songname.value = list[newIndex].title;
          songUri = list[newIndex].uri;
        }
      }
    });
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString();
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return "${d.inHours}:$minutes:$seconds";
    }
    return "$minutes:$seconds";
  }

  void changedurationToseconds(int seconds) {
    final dur = Duration(seconds: seconds);
    player.seek(dur);
  }

  Future<Uri?> _resolveArtworkUri(SongModel song) async {
    try {
      final bytes = await audioQuery.queryArtwork(
        song.id,
        ArtworkType.AUDIO,
        format: ArtworkFormat.JPEG,
        size: 500,
      );
      // Creates glowing wave background for notifications (composited over album art if present)
      return await AudioWaveVisualizer.getOrCreateNotificationWaveformArt(
        song.id,
        song.title,
        albumArtBytes: (bytes != null && bytes.isNotEmpty) ? bytes : null,
      );
    } catch (_) {
      return await AudioWaveVisualizer.getOrCreateNotificationWaveformArt(
        song.id,
        song.title,
      );
    }
  }

  Future<void> playaudio(String? uri, int index, String title,
      {List<SongModel>? playlist}) async {
    if (uri == null || uri.isEmpty) return;
    try {
      if (playlist != null && playlist.isNotEmpty) {
        currentPlaylist = playlist;
      }
      final list = currentPlaylist.isNotEmpty ? currentPlaylist : _allSong;

      // If same song is already active and playing, keep state
      if (songUri == uri && isplaying.value) {
        return;
      }

      songUri = uri;
      playindex.value = index;
      songname.value = title;

      final song = (index >= 0 && index < list.length) ? list[index] : null;
      final artUri = song != null ? await _resolveArtworkUri(song) : null;

      // ConcatenatingAudioSource powers the 3 buttons: Prev, Play/Pause, Next in the notification
      final children = <AudioSource>[];
      for (int i = 0; i < list.length; i++) {
        final s = list[i];
        final isCurrent = i == index;
        children.add(
          AudioSource.uri(
            Uri.parse(s.uri ?? ""),
            tag: MediaItem(
              id: s.uri ?? "",
              title: s.title,
              artist: s.artist ?? "Unknown Artist",
              artUri: isCurrent ? artUri : null,
              playable: true,
            ),
          ),
        );
      }

      await player.stop();
      await player.setAudioSources(children, initialIndex: index);
      await player.setSpeed(playbackSpeed.value);
      // If loopMode is Repeat One, keep player loopMode off so notification Next/Prev buttons
      // remain enabled and advance rather than locking to the same track
      await player.setLoopMode(
        loopMode.value == LoopMode.one ? LoopMode.off : loopMode.value,
      );
      await player.play();
      isplaying.value = true;
      update();
    } catch (e) {
      log("Audio playback error: $e");
    }
  }

  void playOrNavigate(SongModel song, int index, List<SongModel> songs) {
    currentPlaylist = songs;
    final isCurrentSong =
        songUri == song.uri && (isplaying.value || player.duration != null);

    if (!isCurrentSong) {
      // Different song -> play from start
      playaudio(song.uri, index, song.title, playlist: songs);
    }
    // Smooth transition
    Get.to(
      () => Player(songs: songs),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 150),
    );
  }

  void toggleLoopMode() {
    switch (loopMode.value) {
      case LoopMode.off:
        loopMode.value = LoopMode.all;
        player.setLoopMode(LoopMode.all);
        break;
      case LoopMode.all:
        loopMode.value = LoopMode.one;
        // Keep underlying player on LoopMode.off so notification Next/Prev buttons
        // remain active and advance rather than being disabled or restarting the track!
        player.setLoopMode(LoopMode.off);
        break;
      case LoopMode.one:
        loopMode.value = LoopMode.off;
        player.setLoopMode(LoopMode.off);
        break;
    }
    update();
  }

  void toggleShuffle() {
    isShuffle.value = !isShuffle.value;
    player.setShuffleModeEnabled(isShuffle.value);
  }

  void setPlaybackSpeed(double spd) {
    playbackSpeed.value = spd;
    player.setSpeed(spd);
  }

  void pause() async {
    try {
      if (isplaying.value) {
        await player.pause();
        isplaying.value = false;
      } else {
        await player.play();
        isplaying.value = true;
      }
    } catch (e) {
      log("Error toggling pause/play: $e");
    }
  }

  Future<void> checkAndRequestPermission() async {
    if (await Permission.audio.isDenied ||
        await Permission.audio.isPermanentlyDenied) {
      await Permission.audio.request();
    }

    await [
      Permission.storage,
      Permission.mediaLibrary,
    ].request();

    if (await Permission.storage.isGranted ||
        await Permission.audio.isGranted) {
      _allSong = await audioQuery.querySongs(
        ignoreCase: true,
        orderType: sort.order,
        sortType: null,
        uriType: UriType.EXTERNAL,
      );
      sortLexicographically(ascending: true);
      loading.value = false;
    } else {
      checkAndRequestPermission();
    }
  }

  bool get hasNext {
    final list = currentPlaylist.isNotEmpty ? currentPlaylist : _allSong;
    if (list.isEmpty) return false;
    if (loopMode.value == LoopMode.all || loopMode.value == LoopMode.one) {
      return true;
    }
    return playindex.value < list.length - 1;
  }

  bool get hasPrevious {
    final list = currentPlaylist.isNotEmpty ? currentPlaylist : _allSong;
    if (list.isEmpty) return false;
    if (loopMode.value == LoopMode.all || loopMode.value == LoopMode.one) {
      return true;
    }
    return playindex.value > 0;
  }

  void playnext() {
    final list = currentPlaylist.isNotEmpty ? currentPlaylist : _allSong;
    if (list.isEmpty) return;

    int nextIndex;
    if (isShuffle.value && list.length > 1) {
      final random = DateTime.now().millisecondsSinceEpoch;
      nextIndex =
          (playindex.value + 1 + (random % (list.length - 1))) % list.length;
    } else {
      nextIndex = playindex.value + 1;
      if (nextIndex >= list.length) {
        if (loopMode.value == LoopMode.off) {
          // Playlist ended: do not switch, stop playback
          isplaying.value = false;
          player.pause();
          return;
        }
        nextIndex = 0;
      }
    }

    final song = list[nextIndex];
    playaudio(song.uri, nextIndex, song.title, playlist: list);
  }

  void playprevious() {
    final list = currentPlaylist.isNotEmpty ? currentPlaylist : _allSong;
    if (list.isEmpty) return;

    int prevIndex;
    if (isShuffle.value && list.length > 1) {
      final random = DateTime.now().millisecondsSinceEpoch;
      prevIndex =
          (playindex.value - 1 - (random % (list.length - 1))) % list.length;
      if (prevIndex < 0) prevIndex += list.length;
    } else {
      prevIndex = playindex.value - 1;
      if (prevIndex < 0) {
        if (loopMode.value == LoopMode.off) {
          // At beginning of playlist: no previous switch needed
          return;
        }
        prevIndex = list.length - 1;
      }
    }

    final song = list[prevIndex];
    playaudio(song.uri, prevIndex, song.title, playlist: list);
  }

  void sortLexicographically({bool ascending = true}) {
    _allSong.sort((a, b) {
      final cleanA = a.title.trim();
      final cleanB = b.title.trim();
      if (cleanA.isEmpty && cleanB.isEmpty) return 0;
      if (cleanA.isEmpty) return ascending ? 1 : -1;
      if (cleanB.isEmpty) return ascending ? -1 : 1;

      final isLetterA = RegExp(r'[a-zA-Z]').hasMatch(cleanA[0]);
      final isLetterB = RegExp(r'[a-zA-Z]').hasMatch(cleanB[0]);

      if (isLetterA && !isLetterB) {
        return ascending ? -1 : 1;
      }
      if (!isLetterA && isLetterB) {
        return ascending ? 1 : -1;
      }

      final comp = cleanA.toLowerCase().compareTo(cleanB.toLowerCase());
      return ascending ? comp : -comp;
    });
    update();
  }

  void sorting(dynamic value) {
    if (value == Customorder.ztoa) {
      sortLexicographically(ascending: false);
    } else {
      sortLexicographically(ascending: true);
    }
  }

  List<SongModel> get allsongs => _allSong;
}
