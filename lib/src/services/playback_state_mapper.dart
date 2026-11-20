import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

/// Helper for mapping JustAudio player states to AudioService PlaybackState.
class PlaybackStateMapper {
  static PlaybackState build({
    required AudioPlayer player,
    required PlaybackEvent event,
    required LoopMode loopMode,
    required bool isShuffleEnabled,
  }) {
    final isPlaying = player.playing;

    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (isPlaying) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.setRepeatMode,
        MediaAction.setShuffleMode,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[player.processingState] ?? AudioProcessingState.idle,
      playing: isPlaying,
      updatePosition: player.position,
      bufferedPosition: player.bufferedPosition,
      speed: player.speed,
      queueIndex: event.currentIndex ?? player.currentIndex,
      repeatMode: mapLoopModeToAudioService(loopMode),
      shuffleMode: isShuffleEnabled
          ? AudioServiceShuffleMode.all
          : AudioServiceShuffleMode.none,
    );
  }

  static AudioServiceRepeatMode mapLoopModeToAudioService(LoopMode mode) {
    switch (mode) {
      case LoopMode.off:
        return AudioServiceRepeatMode.none;
      case LoopMode.one:
        return AudioServiceRepeatMode.one;
      case LoopMode.all:
        return AudioServiceRepeatMode.all;
    }
  }

  static LoopMode mapAudioServiceToLoopMode(AudioServiceRepeatMode mode) {
    switch (mode) {
      case AudioServiceRepeatMode.none:
      case AudioServiceRepeatMode.group:
        return LoopMode.off;
      case AudioServiceRepeatMode.one:
        return LoopMode.one;
      case AudioServiceRepeatMode.all:
        return LoopMode.all;
    }
  }
}
