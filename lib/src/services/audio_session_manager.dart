import 'dart:async';
import 'dart:developer';

import 'package:audio_session/audio_session.dart';

/// Manages Android/iOS audio session configuration, interruptions, and noisy events.
class AudioSessionManager {
  AudioSession? _session;
  StreamSubscription<AudioInterruptionEvent>? _interruptionSub;
  StreamSubscription<void>? _becomingNoisySub;

  Future<void> init({
    required Function(bool shouldPlay) onInterruptionChange,
    required Function(double volume) onDuckChange,
    required Function() onBecomingNoisy,
  }) async {
    try {
      _session = await AudioSession.instance;
      await _session?.configure(const AudioSessionConfiguration.music());

      _interruptionSub = _session?.interruptionEventStream.listen((event) {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              onDuckChange(0.7);
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              onInterruptionChange(false);
              break;
          }
        } else {
          switch (event.type) {
            case AudioInterruptionType.duck:
            case AudioInterruptionType.unknown:
              onDuckChange(1.0);
              break;
            case AudioInterruptionType.pause:
              onInterruptionChange(true);
              onDuckChange(1.0);
              break;
          }
        }
      });

      _becomingNoisySub = _session?.becomingNoisyEventStream.listen((_) {
        onBecomingNoisy();
      });
    } catch (e) {
      log("Error configuring AudioSession: $e");
    }
  }

  Future<void> setActive(bool active) async {
    try {
      await _session?.setActive(active);
    } catch (_) {}
  }

  void dispose() {
    _interruptionSub?.cancel();
    _becomingNoisySub?.cancel();
  }
}
