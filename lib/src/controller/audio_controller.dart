import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music/src/view/home/home_view.dart';
import 'package:music/src/view/home/sort_song_by_order.dart';
import 'package:music/src/view/player%20view/audio_wave_visualizer.dart';
import 'package:music/src/view/player%20view/player_view.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class PlayerController extends GetxController with WidgetsBindingObserver {
  final audioQuery = OnAudioQuery();
  final SortSongByOrder sort = SortSongByOrder();
  List<SongModel> _allSong = [];
  final player = AudioPlayer();

  final playindex = 0.obs;
  final isplaying = false.obs;
  final currentSongUri = Rxn<String>();
  String? get songUri => currentSongUri.value;
  set songUri(String? val) => currentSongUri.value = val;
  final loading = true.obs;
  final max = 0.0.obs;
  final value = 0.0.obs;
  final duration = "0:00".obs;
  final position = "0:00".obs;
  final songname = "Please select a song to play".obs;
  final artistName = "Unknown Artist".obs;
  final currentSongId = 0.obs;
  final loopMode = LoopMode.off.obs;
  final isShuffle = false.obs;
  final playbackSpeed = 1.0.obs;
  List<SongModel> currentPlaylist = [];
  late Box<Map> musicCacheBox;

  // Session played songs: persists all songs played across sessions
  final playedSessionSongs = <Map<String, dynamic>>[].obs;
  double _lastSavedPositionSec = 0.0;

  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    musicCacheBox = Hive.box<Map>("music");
    _initAudioListeners();
    _loadSessionHistory();

    final alldata =
        musicCacheBox.get("last_session") ?? musicCacheBox.get("data");
    if (alldata != null) {
      playindex.value = (alldata["playIndex"] as num?)?.toInt() ?? 0;
      songname.value = alldata["songName"] ?? "Please select a song to play";
      artistName.value = alldata["artist"] ?? "Unknown Artist";
      currentSongId.value = (alldata["songId"] as num?)?.toInt() ?? 0;
      max.value = (alldata['max'] as num?)?.toDouble() ?? 0.0;
      value.value = (alldata["value"] as num?)?.toDouble() ?? 0.0;
      duration.value = alldata["duration"] ?? "0:00";
      position.value = alldata["position"] ?? "0:00";
      songUri = alldata["songUri"];
      playbackSpeed.value =
          (alldata["playbackSpeed"] as num?)?.toDouble() ?? 1.0;
      if (alldata["loopMode"] is int) {
        final lIndex = alldata["loopMode"] as int;
        if (lIndex >= 0 && lIndex < LoopMode.values.length) {
          loopMode.value = LoopMode.values[lIndex];
        }
      }
      isShuffle.value = alldata["isShuffle"] ?? false;
      // When opening app, start in paused state ready to resume
      isplaying.value = false;
    }

    checkAndRequestPermission();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveCache();
    _saveSessionHistory();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    player.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _saveCache();
      _saveSessionHistory();
    }
  }

  void _recordSessionSong(SongModel? song) {
    if (song == null) return;
    try {
      // Move song to front of recent played list
      playedSessionSongs
          .removeWhere((item) => (item['id'] as num?)?.toInt() == song.id);

      final entry = {
        'id': song.id,
        'title': song.title,
        'artist': song.artist ?? 'Unknown Artist',
        'uri': song.uri ?? '',
        'duration': song.duration ?? 0,
        'playedAt': DateTime.now().millisecondsSinceEpoch,
      };
      playedSessionSongs.insert(0, entry);

      // Keep up to 100 recent session songs
      if (playedSessionSongs.length > 100) {
        playedSessionSongs.removeRange(100, playedSessionSongs.length);
      }

      _saveSessionHistory();
    } catch (_) {}
  }

  void _loadSessionHistory() {
    try {
      final saved = musicCacheBox.get("session_played_songs");
      if (saved != null && saved["songs"] is List) {
        final list = saved["songs"] as List;
        final loaded = list
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        playedSessionSongs.assignAll(loaded);
      }
    } catch (_) {}
  }

  void _saveSessionHistory() async {
    try {
      await musicCacheBox.put("session_played_songs", {
        "songs": playedSessionSongs.toList(),
      });
    } catch (_) {}
  }

  void clearSessionHistory() async {
    playedSessionSongs.clear();
    try {
      await musicCacheBox.delete("session_played_songs");
    } catch (_) {}
  }

  List<SongModel> filterSessionSongs(List<SongModel> allSongs) {
    if (playedSessionSongs.isEmpty) return [];
    final idMap = {for (var s in allSongs) s.id: s};
    final List<SongModel> result = [];
    for (var item in playedSessionSongs) {
      final id = (item['id'] as num?)?.toInt();
      if (id != null && idMap.containsKey(id)) {
        result.add(idMap[id]!);
      }
    }
    return result;
  }

  void _saveCache() async {
    try {
      final data = {
        "isplaying": isplaying.value,
        "playIndex": playindex.value,
        "songName": songname.value,
        "artist": artistName.value,
        "songId": currentSongId.value,
        "max": max.value,
        "value": value.value,
        "duration": duration.value,
        "position": position.value,
        "songUri": songUri,
        "playbackSpeed": playbackSpeed.value,
        "loopMode": loopMode.value.index,
        "isShuffle": isShuffle.value,
        "playlistIds": currentPlaylist.map((s) => s.id).toList(),
      };
      // Explicitly put without clearing other box data (favorites, playlists)
      await musicCacheBox.put("last_session", data);
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

      // Periodically persist progress every 5 seconds of active playback
      if ((sec - _lastSavedPositionSec).abs() >= 5.0) {
        _lastSavedPositionSec = sec;
        _saveCache();
      }
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
          final song = list[newIndex];
          songname.value = song.title;
          artistName.value = song.artist ?? "Unknown Artist";
          currentSongId.value = song.id;
          songUri = song.uri;
          _recordSessionSong(song);
          _saveCache();
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
    value.value = seconds.toDouble();
    position.value = _formatDuration(dur);
    _lastSavedPositionSec = seconds.toDouble();
    _saveCache();
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
      if (song != null) {
        artistName.value = song.artist ?? "Unknown Artist";
        currentSongId.value = song.id;
        _recordSessionSong(song);
      }
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
      _saveCache();
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
    _saveCache();
    update();
  }

  void toggleShuffle() {
    isShuffle.value = !isShuffle.value;
    player.setShuffleModeEnabled(isShuffle.value);
    _saveCache();
  }

  void setPlaybackSpeed(double spd) {
    playbackSpeed.value = spd;
    player.setSpeed(spd);
    _saveCache();
  }

  void pause() async {
    try {
      if (player.audioSource == null && songUri != null) {
        final list = currentPlaylist.isNotEmpty ? currentPlaylist : _allSong;
        if (list.isNotEmpty) {
          await playaudio(
            songUri,
            playindex.value,
            songname.value,
            playlist: list,
          );
          if (value.value > 0) {
            await player.seek(Duration(seconds: value.value.toInt()));
          }
          return;
        }
      }
      if (isplaying.value) {
        await player.pause();
        isplaying.value = false;
      } else {
        await player.play();
        isplaying.value = true;
      }
      _saveCache();
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

      // Restore session queue and audio player prepared to resume
      await _restoreAudioSession();
    } else {
      checkAndRequestPermission();
    }
  }

  Future<void> _restoreAudioSession() async {
    try {
      final alldata =
          musicCacheBox.get("last_session") ?? musicCacheBox.get("data");
      if (alldata == null) return;

      final savedUri = alldata["songUri"] as String?;
      final savedId = (alldata["songId"] as num?)?.toInt();
      if (savedUri == null || savedUri.isEmpty) return;

      // 1. Reconstruct playlist queue
      final List<dynamic>? savedPlaylistIds =
          alldata["playlistIds"] as List<dynamic>?;
      if (savedPlaylistIds != null && savedPlaylistIds.isNotEmpty) {
        final songMap = {for (var s in _allSong) s.id: s};
        final restored = savedPlaylistIds
            .map((id) => songMap[(id as num).toInt()])
            .whereType<SongModel>()
            .toList();
        if (restored.isNotEmpty) {
          currentPlaylist = restored;
        }
      }
      if (currentPlaylist.isEmpty) {
        currentPlaylist = List.from(_allSong);
      }
      if (currentPlaylist.isEmpty) return;

      // 2. Locate current song index
      int restoredIndex = (alldata["playIndex"] as num?)?.toInt() ?? 0;
      if (restoredIndex < 0 ||
          restoredIndex >= currentPlaylist.length ||
          currentPlaylist[restoredIndex].uri != savedUri) {
        final foundIdx = currentPlaylist.indexWhere(
            (s) => s.uri == savedUri || (savedId != null && s.id == savedId));
        if (foundIdx != -1) {
          restoredIndex = foundIdx;
        } else {
          restoredIndex = 0;
        }
      }
      playindex.value = restoredIndex;
      final activeSong = currentPlaylist[restoredIndex];
      songname.value = activeSong.title;
      artistName.value = activeSong.artist ?? "Unknown Artist";
      currentSongId.value = activeSong.id;
      songUri = activeSong.uri;

      final savedPosSec = (alldata["value"] as num?)?.toInt() ?? 0;
      final initialPosition = Duration(seconds: savedPosSec);

      // 3. Prepare audio player in background notification ready to resume
      final artUri = await _resolveArtworkUri(activeSong);
      final children = <AudioSource>[];
      for (int i = 0; i < currentPlaylist.length; i++) {
        final s = currentPlaylist[i];
        final isCurrent = i == restoredIndex;
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
      await player.setAudioSources(
        children,
        initialIndex: restoredIndex,
        initialPosition: initialPosition,
      );
      await player.setSpeed(playbackSpeed.value);
      await player.setLoopMode(
        loopMode.value == LoopMode.one ? LoopMode.off : loopMode.value,
      );
      await player.setShuffleModeEnabled(isShuffle.value);
      await player.pause();
      isplaying.value = false;

      if (savedPosSec > 0) {
        value.value = savedPosSec.toDouble();
        position.value = _formatDuration(initialPosition);
      }
      final savedMax = (alldata["max"] as num?)?.toDouble() ?? 0.0;
      if (savedMax > 0) {
        max.value = savedMax;
        duration.value = alldata["duration"] ??
            _formatDuration(Duration(seconds: savedMax.toInt()));
      }

      update();
    } catch (e) {
      log("Error restoring audio session: $e");
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
