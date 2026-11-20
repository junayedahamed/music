import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music/src/services/audio_session_manager.dart';
import 'package:music/src/services/playback_state_mapper.dart';

/// Single source of truth for audio playback and Android media notifications.
class MusicAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  final AudioSessionManager _sessionManager = AudioSessionManager();

  static const String customActionToggleRepeat = 'toggleRepeat';
  static const String customActionToggleShuffle = 'toggleShuffle';

  LoopMode _loopMode = LoopMode.off;
  bool _isShuffleEnabled = false;

  StreamSubscription<PlaybackEvent>? _playbackEventSubscription;
  StreamSubscription<SequenceState>? _sequenceStateSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  AudioPlayer get player => _player;
  LoopMode get currentLoopMode => _loopMode;
  bool get isShuffleActive => _isShuffleEnabled;

  MusicAudioHandler() {
    _player.setVolume(1.0);
    _sessionManager.init(
      onInterruptionChange: (play) => play ? this.play() : pause(),
      onDuckChange: (vol) => _player.setVolume(vol),
      onBecomingNoisy: pause,
    );
    _initPlayerListeners();
  }

  void _initPlayerListeners() {
    _playbackEventSubscription = _player.playbackEventStream.listen(
      _broadcastPlaybackState,
      onError: (Object e) => log("PlaybackEvent error: $e"),
    );

    _sequenceStateSubscription =
        _player.sequenceStateStream.listen((sequenceState) {
      final currentSource = sequenceState.currentSource;
      if (currentSource?.tag is MediaItem) {
        mediaItem.add(currentSource!.tag as MediaItem);
      }
    });

    _playerStateSubscription = _player.playerStateStream.listen((state) {
      _broadcastPlaybackState(_player.playbackEvent);
      if (state.processingState == ProcessingState.completed) {
        _handlePlaybackCompleted();
      }
    });
  }

  void _broadcastPlaybackState(PlaybackEvent event) {
    playbackState.add(
      PlaybackStateMapper.build(
        player: _player,
        event: event,
        loopMode: _loopMode,
        isShuffleEnabled: _isShuffleEnabled,
      ),
    );
  }

  void _handlePlaybackCompleted() {
    if (_loopMode == LoopMode.one) {
      _player.seek(Duration.zero);
      _player.play();
    } else if (_loopMode == LoopMode.all) {
      skipToNext();
    } else {
      final currentIdx = _player.currentIndex ?? 0;
      if (currentIdx < queue.value.length - 1) {
        skipToNext();
      } else {
        pause();
      }
    }
  }

  Future<void> setQueueWithPlaylist(
    List<MediaItem> items, {
    int initialIndex = 0,
    Duration? initialPosition,
    bool play = true,
  }) async {
    if (items.isEmpty) return;
    queue.add(items);

    final safeIndex = initialIndex.clamp(0, items.length - 1);
    mediaItem.add(items[safeIndex]);

    final sources = items.map((item) {
      return AudioSource.uri(Uri.parse(item.id), tag: item);
    }).toList();

    try {
      await _player.stop();
      await _player.setAudioSources(
        sources,
        initialIndex: safeIndex,
        initialPosition: initialPosition,
      );
      await _player.setLoopMode(_loopMode);
      await _player.setShuffleModeEnabled(_isShuffleEnabled);

      if (play) {
        await _player.play();
      } else {
        await _player.pause();
      }
    } catch (e) {
      log("Error loading audio sources: $e");
    }
  }

  @override
  Future<void> play() async {
    await _sessionManager.setActive(true);
    if (_player.volume < 1.0) await _player.setVolume(1.0);
    await _player.play();
  }

  @override
  Future<void> pause() async => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await _sessionManager.setActive(false);
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    final q = queue.value;
    if (q.isEmpty) return;
    final currentIdx = _player.currentIndex ?? 0;
    int nextIdx;

    if (_isShuffleEnabled && q.length > 1) {
      final rand = DateTime.now().millisecondsSinceEpoch;
      nextIdx = (currentIdx + 1 + (rand % (q.length - 1))) % q.length;
    } else {
      nextIdx = currentIdx + 1;
      if (nextIdx >= q.length) {
        if (_loopMode == LoopMode.off) {
          pause();
          return;
        }
        nextIdx = 0;
      }
    }
    await skipToQueueItem(nextIdx);
  }

  @override
  Future<void> skipToPrevious() async {
    final q = queue.value;
    if (q.isEmpty) return;
    final currentIdx = _player.currentIndex ?? 0;
    int prevIdx;

    if (_isShuffleEnabled && q.length > 1) {
      final rand = DateTime.now().millisecondsSinceEpoch;
      prevIdx = (currentIdx - 1 - (rand % (q.length - 1))) % q.length;
      if (prevIdx < 0) prevIdx += q.length;
    } else {
      prevIdx = currentIdx - 1;
      if (prevIdx < 0) {
        if (_loopMode == LoopMode.off) return;
        prevIdx = q.length - 1;
      }
    }
    await skipToQueueItem(prevIdx);
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    final q = queue.value;
    if (index < 0 || index >= q.length) return;
    try {
      await _player.seek(Duration.zero, index: index);
      mediaItem.add(q[index]);
      if (!_player.playing) await play();
    } catch (e) {
      log("Error skipping to queue item $index: $e");
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) =>
      setLoopModeDirect(PlaybackStateMapper.mapAudioServiceToLoopMode(repeatMode));

  Future<void> setLoopModeDirect(LoopMode mode) async {
    _loopMode = mode;
    await _player.setLoopMode(mode);
    _broadcastPlaybackState(_player.playbackEvent);
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) =>
      setShuffleModeDirect(shuffleMode == AudioServiceShuffleMode.all);

  Future<void> setShuffleModeDirect(bool enabled) async {
    _isShuffleEnabled = enabled;
    await _player.setShuffleModeEnabled(enabled);
    _broadcastPlaybackState(_player.playbackEvent);
  }

  @override
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
    _broadcastPlaybackState(_player.playbackEvent);
  }

  @override
  Future<dynamic> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == customActionToggleRepeat) {
      final next = _loopMode == LoopMode.off
          ? LoopMode.all
          : (_loopMode == LoopMode.all ? LoopMode.one : LoopMode.off);
      await setLoopModeDirect(next);
      return next.index;
    }
    if (name == customActionToggleShuffle) {
      await setShuffleModeDirect(!_isShuffleEnabled);
      return _isShuffleEnabled;
    }
    return super.customAction(name, extras);
  }

  Future<void> dispose() async {
    _playbackEventSubscription?.cancel();
    _sequenceStateSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _sessionManager.dispose();
    await _player.dispose();
  }
}
