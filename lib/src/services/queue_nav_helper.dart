import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

/// Helper to calculate next and previous indices for queue navigation.
class QueueNavHelper {
  static int? getNextIndex({
    required List<MediaItem> queue,
    required int currentIndex,
    required bool isShuffleEnabled,
    required LoopMode loopMode,
  }) {
    if (queue.isEmpty) return null;
    if (isShuffleEnabled && queue.length > 1) {
      final rand = Random().nextInt(queue.length - 1);
      return (currentIndex + 1 + rand) % queue.length;
    }
    final nextIdx = currentIndex + 1;
    if (nextIdx >= queue.length) {
      if (loopMode == LoopMode.off) return null;
      return 0;
    }
    return nextIdx;
  }

  static int? getPreviousIndex({
    required List<MediaItem> queue,
    required int currentIndex,
    required bool isShuffleEnabled,
    required LoopMode loopMode,
  }) {
    if (queue.isEmpty) return null;
    if (isShuffleEnabled && queue.length > 1) {
      final rand = Random().nextInt(queue.length - 1);
      int prevIdx = (currentIndex - 1 - rand) % queue.length;
      if (prevIdx < 0) prevIdx += queue.length;
      return prevIdx;
    }
    final prevIdx = currentIndex - 1;
    if (prevIdx < 0) {
      if (loopMode == LoopMode.off) return null;
      return queue.length - 1;
    }
    return prevIdx;
  }
}
