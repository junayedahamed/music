import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music/src/controller/player_action_coordinator.dart';
import 'package:music/src/controller/player_listener_binder.dart';
import 'package:music/src/controller/player_session_coordinator.dart';
import 'package:music/src/services/audio_cache_service.dart';
import 'package:music/src/services/audio_permission_service.dart';
import 'package:music/src/services/audio_playback_coordinator.dart';
import 'package:music/src/services/music_audio_handler.dart';
import 'package:music/src/services/session_history_service.dart';
import 'package:music/src/services/song_file_service.dart';
import 'package:music/src/services/song_sorter.dart';
import 'package:music/src/utils/custom_order.dart';
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

  final playindex = (-1).obs;
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
  bool _isRestoring = false;

  bool get hasActiveSong =>
      currentSongId.value > 0 && songUri != null && songUri!.isNotEmpty;
  bool get isRestoring => _isRestoring;
  void setRestoring(bool restoring) => _isRestoring = restoring;

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
    if (_allSong.isNotEmpty && AudioCacheService.hasValidSession()) {
      _restoreSession();
    }
    AudioPermissionService.hasAudioPermission(audioQuery).then((h) {
      if (h) checkAndRequestPermission();
    });
  }

  void _loadSavedState() => PlayerSessionCoordinator.loadSavedState(this);

  void resetIdleState() {
    playindex.value = -1;
    currentSongId.value = 0;
    songUri = null;
    songname.value = "Please select a song to play";
    artistName.value = "Unknown Artist";
    max.value = 0.0;
    value.value = 0.0;
    duration.value = "0:00";
    position.value = "0:00";
    isplaying.value = false;
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    saveCache();
    AudioCacheService.saveSessionHistory(playedSessionSongs.toList());
    for (final s in _subscriptions) {
      s.cancel();
    }
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      saveCache();
      AudioCacheService.saveSessionHistory(playedSessionSongs.toList());
    }
  }

  void _recordSessionSong(SongModel? s) =>
      SessionHistoryService.recordSong(playedSessionSongs, s);
  void clearSessionHistory() {
    playedSessionSongs.clear();
    AudioCacheService.clearSessionHistory();
  }

  List<SongModel> filterSessionSongs(List<SongModel> all) =>
      SessionHistoryService.filterSongs(playedSessionSongs, all);

  void saveCache() => PlayerSessionCoordinator.saveCache(this);

  void _initListeners() {
    _subscriptions.addAll(PlayerListenerBinder.bind(
      audioHandler: _audioHandler,
      player: player,
      isplaying: isplaying,
      playbackSpeed: playbackSpeed,
      playindex: playindex,
      songname: songname,
      artistName: artistName,
      currentSongId: currentSongId,
      currentSongUri: currentSongUri,
      duration: duration,
      max: max,
      position: position,
      value: value,
      hasActiveSong: () => hasActiveSong,
      isRestoring: () => _isRestoring,
      getActiveList: () =>
          currentPlaylist.isNotEmpty ? currentPlaylist : _allSong,
      onSongChanged: _recordSessionSong,
      onSaveCache: saveCache,
    ));
  }

  void changedurationToseconds(int sec) =>
      PlayerActionCoordinator.seekToSeconds(this, sec);

  Future<void> playaudio(String? uri, int index, String title,
      {List<SongModel>? playlist}) async {
    if (uri == null || uri.isEmpty) return;
    if (playlist != null && playlist.isNotEmpty) currentPlaylist = playlist;
    final list = currentPlaylist.isNotEmpty ? currentPlaylist : _allSong;
    if (songUri == uri && isplaying.value) return;

    _isRestoring = false;
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
      audioHandler: _audioHandler,
      list: list,
      index: index,
      uri: uri,
      resolveArtwork: (s) => WaveformArtGenerator.resolveArtwork(audioQuery, s),
      speed: playbackSpeed.value,
      loopMode: loopMode.value,
      isShuffle: isShuffle.value,
    );
    isplaying.value = true;
    saveCache();
    update();
  }

  void playOrNavigate(SongModel song, int index, List<SongModel> songs) {
    currentPlaylist = songs;
    if (songUri != song.uri || player.audioSource == null) {
      playaudio(song.uri, index, song.title, playlist: songs);
    } else if (!isplaying.value) {
      _audioHandler.play();
      isplaying.value = true;
      saveCache();
      update();
    }
    Get.to(() => Player(songs: songs),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 150));
  }

  void toggleLoopMode() => PlayerActionCoordinator.toggleLoopMode(this);
  void toggleShuffle() => PlayerActionCoordinator.toggleShuffle(this);
  void setPlaybackSpeed(double spd) =>
      PlayerActionCoordinator.setSpeed(this, spd);
  void pause() async => PlayerActionCoordinator.togglePause(this);

  Future<void> checkAndRequestPermission() async {
    final songs = await AudioPermissionService.requestAndFetchSongs(
        audioQuery: audioQuery, orderType: sort.order);
    if (songs != null) {
      _allSong = songs;
      SongSorter.sortLexicographically(_allSong, ascending: true);
      loading.value = false;
      AudioCacheService.saveCachedSongs(songs);
      update();
      if (AudioCacheService.hasValidSession()) _restoreSession();
    } else {
      loading.value = false;
    }
  }

  Future<void> _restoreSession() async =>
      PlayerSessionCoordinator.restoreSession(this);

  bool get hasNext =>
      hasActiveSong &&
      currentPlaylist.isNotEmpty &&
      (loopMode.value != LoopMode.off ||
          playindex.value < currentPlaylist.length - 1);
  bool get hasPrevious =>
      hasActiveSong &&
      currentPlaylist.isNotEmpty &&
      (loopMode.value != LoopMode.off || playindex.value > 0);
  void playnext() async {
    if (hasActiveSong) await _audioHandler.skipToNext();
  }

  void playprevious() async {
    if (hasActiveSong) await _audioHandler.skipToPrevious();
  }

  void sortLexicographically({bool ascending = true}) {
    SongSorter.sortLexicographically(_allSong, ascending: ascending);
    update();
  }

  void sorting(dynamic value) =>
      sortLexicographically(ascending: value != Customorder.ztoa);
  Future<bool> shareSongs(List<SongModel> songs) =>
      SongFileService.shareSongs(songs);
  Future<int> deleteSongs(List<SongModel> songs) =>
      PlayerActionCoordinator.deleteSongs(this, songs);

  List<SongModel> get allsongs => _allSong;
}
