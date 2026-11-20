import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music/src/controller/player_listener_binder.dart';
import 'package:music/src/services/audio_cache_service.dart';
import 'package:music/src/services/audio_permission_service.dart';
import 'package:music/src/services/audio_playback_coordinator.dart';
import 'package:music/src/services/audio_session_restorer.dart';
import 'package:music/src/services/music_audio_handler.dart';
import 'package:music/src/services/session_history_service.dart';
import 'package:music/src/services/song_file_service.dart';
import 'package:music/src/services/song_sorter.dart';
import 'package:music/src/utils/custom_order.dart';
import 'package:music/src/utils/duration_formatter.dart';
import 'package:music/src/view/home/home_view.dart';
import 'package:music/src/view/home/sort_song_by_order.dart';
import 'package:music/src/view/player%20view/audio_wave_visualizer.dart';
import 'package:music/src/view/player%20view/player_view.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlayerController extends GetxController with WidgetsBindingObserver {
  final audioQuery = OnAudioQuery();
  final SortSongByOrder sort = SortSongByOrder();
  List<SongModel> _allSong = [];

  late final MusicAudioHandler _audioHandler;
  AudioPlayer get player => _audioHandler.player;
  MusicAudioHandler get audioHandler => _audioHandler;

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
  final playedSessionSongs = <Map<String, dynamic>>[].obs;
  final List<StreamSubscription> _subscriptions = [];

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    AudioCacheService.init(Hive.box<Map>("music"));
    _audioHandler = Get.find<MusicAudioHandler>();
    _initListeners();
    playedSessionSongs.assignAll(AudioCacheService.loadSessionHistory());
    final cached = AudioCacheService.loadCachedSongs();
    if (cached != null && cached.isNotEmpty) {
      _allSong = cached;
      SongSorter.sortLexicographically(_allSong, ascending: true);
      loading.value = false;
      update();
    }
    _loadSavedState();
    if (_allSong.isNotEmpty) _restoreSession();
    AudioPermissionService.hasAudioPermission(audioQuery).then((h) { if (h) checkAndRequestPermission(); });
  }

  void _loadSavedState() {
    final d = AudioCacheService.getLastSessionData();
    if (d == null) return;
    AudioCacheService.applySessionData(d,
      setIndex: (i) => playindex.value = i, setName: (n) => songname.value = n,
      setArtist: (a) => artistName.value = a, setId: (id) => currentSongId.value = id,
      setMax: (m) => max.value = m, setValue: (v) => value.value = v,
      setDuration: (dur) => duration.value = dur, setPosition: (p) => position.value = p,
      setUri: (u) => songUri = u, setSpeed: (s) => playbackSpeed.value = s,
      setLoop: (l) => loopMode.value = LoopMode.values[l], setShuffle: (sh) => isShuffle.value = sh,
    );
    isplaying.value = false;
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveCache();
    AudioCacheService.saveSessionHistory(playedSessionSongs.toList());
    for (final s in _subscriptions) { s.cancel(); }
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.detached) {
      _saveCache();
      AudioCacheService.saveSessionHistory(playedSessionSongs.toList());
    }
  }

  void _recordSessionSong(SongModel? s) => SessionHistoryService.recordSong(playedSessionSongs, s);
  void clearSessionHistory() { playedSessionSongs.clear(); AudioCacheService.clearSessionHistory(); }
  List<SongModel> filterSessionSongs(List<SongModel> all) => SessionHistoryService.filterSongs(playedSessionSongs, all);

  void _saveCache() {
    AudioCacheService.saveSessionData({
      "isplaying": isplaying.value, "playIndex": playindex.value, "songName": songname.value,
      "artist": artistName.value, "songId": currentSongId.value, "max": max.value, "value": value.value,
      "duration": duration.value, "position": position.value, "songUri": songUri,
      "playbackSpeed": playbackSpeed.value, "loopMode": loopMode.value.index,
      "isShuffle": isShuffle.value, "playlistIds": currentPlaylist.map((s) => s.id).toList(),
    });
  }

  void _initListeners() {
    _subscriptions.addAll(PlayerListenerBinder.bind(
      audioHandler: _audioHandler, player: player, isplaying: isplaying, playbackSpeed: playbackSpeed,
      playindex: playindex, songname: songname, artistName: artistName, currentSongId: currentSongId,
      currentSongUri: currentSongUri, duration: duration, max: max, position: position, value: value,
      getActiveList: () => currentPlaylist.isNotEmpty ? currentPlaylist : _allSong,
      onSongChanged: _recordSessionSong, onSaveCache: _saveCache,
    ));
  }

  void changedurationToseconds(int sec) {
    _audioHandler.seek(Duration(seconds: sec));
    value.value = sec.toDouble();
    position.value = DurationFormatter.format(Duration(seconds: sec));
    _saveCache();
  }

  Future<void> playaudio(String? uri, int index, String title, {List<SongModel>? playlist}) async {
    if (uri == null || uri.isEmpty) return;
    if (playlist != null && playlist.isNotEmpty) currentPlaylist = playlist;
    final list = currentPlaylist.isNotEmpty ? currentPlaylist : _allSong;
    if (songUri == uri && isplaying.value) return;

    songUri = uri;
    playindex.value = index;
    songname.value = title;
    final song = (index >= 0 && index < list.length) ? list[index] : null;
    if (song != null) {
      artistName.value = song.artist ?? "Unknown Artist";
      currentSongId.value = song.id;
      _recordSessionSong(song);
    }
    await AudioPlaybackCoordinator.playAudio(
      audioHandler: _audioHandler, list: list, index: index, uri: uri,
      resolveArtwork: (s) => WaveformArtGenerator.resolveArtwork(audioQuery, s),
      speed: playbackSpeed.value, loopMode: loopMode.value, isShuffle: isShuffle.value,
    );
    isplaying.value = true;
    _saveCache();
    update();
  }

  void playOrNavigate(SongModel song, int index, List<SongModel> songs) {
    currentPlaylist = songs;
    if (songUri != song.uri || player.audioSource == null) {
      playaudio(song.uri, index, song.title, playlist: songs);
    } else if (!isplaying.value) {
      _audioHandler.play();
      isplaying.value = true;
      _saveCache();
      update();
    }
    Get.to(() => Player(songs: songs), transition: Transition.fadeIn, duration: const Duration(milliseconds: 150));
  }

  void toggleLoopMode() {
    final next = loopMode.value == LoopMode.off ? LoopMode.all : (loopMode.value == LoopMode.all ? LoopMode.one : LoopMode.off);
    loopMode.value = next;
    _audioHandler.setLoopModeDirect(next);
    _saveCache();
    update();
  }

  void toggleShuffle() {
    isShuffle.value = !isShuffle.value;
    _audioHandler.setShuffleModeDirect(isShuffle.value);
    _saveCache();
  }

  void setPlaybackSpeed(double spd) {
    playbackSpeed.value = spd;
    _audioHandler.setSpeed(spd);
    _saveCache();
    update();
  }

  void pause() async {
    try {
      if (player.audioSource == null && songUri != null) {
        final list = currentPlaylist.isNotEmpty ? currentPlaylist : _allSong;
        if (list.isNotEmpty) {
          await playaudio(songUri, playindex.value, songname.value, playlist: list);
          if (value.value > 0) await _audioHandler.seek(Duration(seconds: value.value.toInt()));
          return;
        }
      }
      isplaying.value ? await _audioHandler.pause() : await _audioHandler.play();
      _saveCache();
    } catch (e) {
      log("Error toggling pause/play: $e");
    }
  }

  Future<void> checkAndRequestPermission() async {
    final songs = await AudioPermissionService.requestAndFetchSongs(audioQuery: audioQuery, orderType: sort.order);
    if (songs != null) {
      _allSong = songs;
      SongSorter.sortLexicographically(_allSong, ascending: true);
      loading.value = false;
      AudioCacheService.saveCachedSongs(songs);
      update();
      _restoreSession();
    } else {
      loading.value = false;
    }
  }

  Future<void> _restoreSession() async {
    await AudioSessionRestorer.restore(
      allSong: _allSong, currentPlaylist: currentPlaylist, audioHandler: _audioHandler,
      resolveArtwork: (s) => WaveformArtGenerator.resolveArtwork(audioQuery, s),
      onRestored: (idx, active, pos, maxV, dur) {
        playindex.value = idx;
        songname.value = active.title;
        artistName.value = active.artist ?? "Unknown Artist";
        currentSongId.value = active.id;
        songUri = active.uri;
        if (pos.inSeconds > 0) { value.value = pos.inSeconds.toDouble(); position.value = DurationFormatter.format(pos); }
        if (maxV > 0) { max.value = maxV; duration.value = dur; }
        update();
      },
    );
  }

  bool get hasNext => currentPlaylist.isNotEmpty && (loopMode.value != LoopMode.off || playindex.value < currentPlaylist.length - 1);
  bool get hasPrevious => currentPlaylist.isNotEmpty && (loopMode.value != LoopMode.off || playindex.value > 0);
  void playnext() async => await _audioHandler.skipToNext();
  void playprevious() async => await _audioHandler.skipToPrevious();
  void sortLexicographically({bool ascending = true}) { SongSorter.sortLexicographically(_allSong, ascending: ascending); update(); }
  void sorting(dynamic value) => sortLexicographically(ascending: value != Customorder.ztoa);
  Future<bool> shareSongs(List<SongModel> songs) => SongFileService.shareSongs(songs);

  Future<int> deleteSongs(List<SongModel> songs) async {
    final count = await SongFileService.deleteAndCleanup(
      songs: songs, allSong: _allSong, currentPlaylist: currentPlaylist, playedSessionSongs: playedSessionSongs,
      songUri: songUri, currentSongId: currentSongId.value, onPlayNext: playnext,
      onStop: () async {
        await _audioHandler.stop();
        isplaying.value = false;
        songUri = null;
        songname.value = "Please select a song to play";
        artistName.value = "Unknown Artist";
        currentSongId.value = 0;
      },
    );
    _saveCache();
    AudioCacheService.saveSessionHistory(playedSessionSongs.toList());
    AudioCacheService.saveCachedSongs(_allSong);
    update();
    return count;
  }

  List<SongModel> get allsongs => _allSong;
}
