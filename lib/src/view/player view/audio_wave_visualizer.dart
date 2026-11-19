import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

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

  /// Generates a waveform background image and saves it to a temp file for notifications.
  /// If [albumArtBytes] is provided, it composites the waveform over the artwork.
  static Future<Uri?> getOrCreateNotificationWaveformArt(
      int songId, String songTitle,
      {Uint8List? albumArtBytes}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final hasArt = albumArtBytes != null && albumArtBytes.isNotEmpty;
      final file = File(
          "${tempDir.path}/wave_art_${songId}_${hasArt ? 'art' : 'wave'}.png");
      if (await file.exists()) {
        return Uri.file(file.path);
      }

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 512, 512));

      if (hasArt) {
        try {
          final codec = await ui.instantiateImageCodec(albumArtBytes);
          final frame = await codec.getNextFrame();
          final img = frame.image;
          // Draw artwork scaled to 512x512
          paintImage(
            canvas: canvas,
            rect: const Rect.fromLTWH(0, 0, 512, 512),
            image: img,
            fit: BoxFit.cover,
          );
          // Dark overlay so waveform pops
          final darkPaint = Paint()
            ..color = Colors.black.withValues(alpha: 0.55);
          canvas.drawRect(const Rect.fromLTWH(0, 0, 512, 512), darkPaint);
        } catch (_) {
          _drawDefaultWaveBackground(canvas);
        }
      } else {
        _drawDefaultWaveBackground(canvas);
      }

      // Draw center glowing wave bars
      const int bars = 36;
      const double barWidth = 7.0;
      const double spacing = 6.0;
      const double startX = (512 - (bars * (barWidth + spacing))) / 2;

      final wavePaint = Paint();
      final random = math.Random(songId);

      for (int i = 0; i < bars; i++) {
        final x = startX + i * (barWidth + spacing);
        final norm = i / (bars - 1);
        final envelope = math.sin(norm * math.pi);
        final heightFactor =
            (0.3 + 0.7 * envelope) * (0.6 + 0.4 * random.nextDouble());
        final barHeight = (heightFactor * 220).clamp(16.0, 240.0);
        final y = 256.0 - (barHeight / 2);

        // Cyan to neon green gradient
        wavePaint.shader = ui.Gradient.linear(
          Offset(x, y),
          Offset(x, y + barHeight),
          [
            const Color(0xff00b0ff),
            const Color(0xff60E95D),
          ],
        );

        final rrect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(4),
        );
        canvas.drawRRect(rrect, wavePaint);
      }

      final picture = recorder.endRecording();
      final image = await picture.toImage(512, 512);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        await file.writeAsBytes(byteData.buffer.asUint8List());
        return Uri.file(file.path);
      }
    } catch (_) {}
    return null;
  }

  static void _drawDefaultWaveBackground(Canvas canvas) {
    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        const Offset(512, 512),
        [
          const Color(0xff060910),
          const Color(0xff121826),
          const Color(0xff090c14),
        ],
      );
    canvas.drawRect(const Rect.fromLTWH(0, 0, 512, 512), bgPaint);

    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        const Offset(256, 256),
        200,
        [
          const Color(0xff00b0ff).withValues(alpha: 0.3),
          Colors.transparent,
        ],
      );
    canvas.drawCircle(const Offset(256, 256), 200, glowPaint);
  }

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

/// Circular Beat Waveform visualizer that replaces the static music note icon
class BeatWaveformCircle extends StatefulWidget {
  final bool isPlaying;
  final double size;
  final Color primaryColor;
  final Color secondaryColor;

  const BeatWaveformCircle({
    super.key,
    required this.isPlaying,
    this.size = 110.0,
    this.primaryColor = const Color(0xff00b0ff),
    this.secondaryColor = const Color(0xff60E95D),
  });

  @override
  State<BeatWaveformCircle> createState() => _BeatWaveformCircleState();
}

class _BeatWaveformCircleState extends State<BeatWaveformCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant BeatWaveformCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value * 2 * math.pi;
        // Beat pulse scale (subtle bounce on music beat)
        final pulse = widget.isPlaying ? 1.0 + 0.06 * math.sin(t * 2) : 1.0;

        return Transform.scale(
          scale: pulse,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.primaryColor.withValues(alpha: 0.12),
              border: Border.all(
                color: widget.primaryColor.withValues(alpha: 0.35),
                width: 2.0,
              ),
              boxShadow: widget.isPlaying
                  ? [
                      BoxShadow(
                        color: widget.primaryColor.withValues(alpha: 0.25),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(7, (i) {
                  final norm = i / 6.0;
                  final envelope = math.sin(norm * math.pi);

                  double barHeight;
                  if (widget.isPlaying) {
                    final wave1 = math.sin(t * 2.0 + i * 0.8);
                    final wave2 = math.cos(t * 1.4 - i * 0.5);
                    final factor = ((wave1 + wave2) / 2.0 + 1.0) / 2.0;
                    barHeight = (12.0 + factor * envelope * (widget.size * 0.45))
                        .clamp(8.0, widget.size * 0.55);
                  } else {
                    barHeight = (8.0 + envelope * 12.0).clamp(8.0, 22.0);
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    width: 4.5,
                    height: barHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [widget.primaryColor, widget.secondaryColor],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Mini 4-bar dancing equalizer for the BottomMusicView bar
class MiniMusicVisualizer extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  final double height;

  const MiniMusicVisualizer({
    super.key,
    required this.isPlaying,
    this.color = Colors.white,
    this.height = 18.0,
  });

  @override
  State<MiniMusicVisualizer> createState() => _MiniMusicVisualizerState();
}

class _MiniMusicVisualizerState extends State<MiniMusicVisualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant MiniMusicVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value * 2 * math.pi;

        return SizedBox(
          height: widget.height,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(4, (i) {
              double barH;
              if (widget.isPlaying) {
                final w = math.sin(t * 1.8 + i * 1.2);
                final factor = (w + 1.0) / 2.0;
                barH = (4.0 + factor * (widget.height - 4.0))
                    .clamp(4.0, widget.height);
              } else {
                barH = [6.0, 10.0, 8.0, 5.0][i];
              }

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                width: 3.0,
                height: barH,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
