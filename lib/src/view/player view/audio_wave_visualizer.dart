import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:music/src/view/player%20view/waveform_art_generator.dart';

export 'package:music/src/view/player%20view/beat_waveform_circle.dart';
export 'package:music/src/view/player%20view/mini_music_visualizer.dart';
export 'package:music/src/view/player%20view/waveform_art_generator.dart';

class AudioWaveVisualizer extends StatefulWidget {
  final bool isPlaying;
  final double height;
  final Color? activeColor;
  final Color? secondaryColor;
  final int barCount;

  const AudioWaveVisualizer({
    super.key,
    required this.isPlaying,
    this.height = 42.0,
    this.activeColor,
    this.secondaryColor,
    this.barCount = 28,
  });

  /// Forwarder for backwards compatibility.
  static Future<Uri?> getOrCreateNotificationWaveformArt(
    int songId,
    String songTitle, {
    Uint8List? albumArtBytes,
  }) =>
      WaveformArtGenerator.getOrCreateNotificationWaveformArt(
        songId,
        songTitle,
        albumArtBytes: albumArtBytes,
      );

  @override
  State<AudioWaveVisualizer> createState() => _AudioWaveVisualizerState();
}

class _AudioWaveVisualizerState extends State<AudioWaveVisualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    if (widget.isPlaying) {
      _animController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AudioWaveVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _animController.repeat();
      } else {
        _animController.stop();
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? const Color(0xff00b0ff);
    final secondaryColor = widget.secondaryColor ?? const Color(0xff60E95D);

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        final t = _animController.value * 2 * math.pi;

        return SizedBox(
          height: widget.height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(widget.barCount, (i) {
              final norm = i / (widget.barCount - 1);
              final envelope = math.sin(norm * math.pi);

              double barHeight;
              if (widget.isPlaying) {
                final wave1 = math.sin(t * 1.5 + i * 0.4);
                final wave2 = math.cos(t * 2.2 - i * 0.3);
                final wave3 = math.sin(t * 0.8 + i * 0.7);
                final combined = (wave1 + wave2 + wave3) / 3.0;
                final heightFactor = ((combined + 1.0) / 2.0) * envelope;
                barHeight = (4.0 + heightFactor * (widget.height - 6.0))
                    .clamp(4.0, widget.height);
              } else {
                barHeight = (4.0 + envelope * 6.0).clamp(4.0, 10.0);
              }

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2.0),
                width: 3.5,
                height: barHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [activeColor, secondaryColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: widget.isPlaying
                      ? [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.3),
                            blurRadius: 4,
                            spreadRadius: 0.5,
                          ),
                        ]
                      : null,
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
