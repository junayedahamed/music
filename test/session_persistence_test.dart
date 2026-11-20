import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music/src/services/audio_cache_service.dart';
import 'package:music/src/services/queue_nav_helper.dart';
import 'package:audio_service/audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Session Persistence & Validation Tests', () {
    test('AudioCacheService.isValidSession validates session data correctly', () {
      expect(AudioCacheService.isValidSession(null), isFalse);
      expect(AudioCacheService.isValidSession({}), isFalse);
      expect(AudioCacheService.isValidSession({'songId': 0, 'songUri': null}), isFalse);
      expect(AudioCacheService.isValidSession({'songId': 0, 'songUri': ''}), isFalse);
      expect(AudioCacheService.isValidSession({'songId': -1, 'songUri': ''}), isFalse);

      expect(AudioCacheService.isValidSession({'songId': 42}), isTrue);
      expect(AudioCacheService.isValidSession({'songUri': 'content://media/audio/42'}), isTrue);
      expect(AudioCacheService.isValidSession({'songId': 42, 'songUri': 'content://media/audio/42'}), isTrue);
    });

    test('QueueNavHelper respects LoopMode.off and does not advance past queue end', () {
      final queue = [
        const MediaItem(id: '1', title: 'Song 1'),
        const MediaItem(id: '2', title: 'Song 2'),
      ];

      final nextFromLast = QueueNavHelper.getNextIndex(
        queue: queue,
        currentIndex: 1,
        isShuffleEnabled: false,
        loopMode: LoopMode.off,
      );
      expect(nextFromLast, isNull);

      final prevFromFirst = QueueNavHelper.getPreviousIndex(
        queue: queue,
        currentIndex: 0,
        isShuffleEnabled: false,
        loopMode: LoopMode.off,
      );
      expect(prevFromFirst, isNull);
    });

    test('QueueNavHelper wraps around when LoopMode.all is active', () {
      final queue = [
        const MediaItem(id: '1', title: 'Song 1'),
        const MediaItem(id: '2', title: 'Song 2'),
      ];

      final nextFromLast = QueueNavHelper.getNextIndex(
        queue: queue,
        currentIndex: 1,
        isShuffleEnabled: false,
        loopMode: LoopMode.all,
      );
      expect(nextFromLast, 0);

      final prevFromFirst = QueueNavHelper.getPreviousIndex(
        queue: queue,
        currentIndex: 0,
        isShuffleEnabled: false,
        loopMode: LoopMode.all,
      );
      expect(prevFromFirst, 1);
    });
  });
}
