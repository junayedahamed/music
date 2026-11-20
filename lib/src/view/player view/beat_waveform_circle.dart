import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Circular Beat Waveform visualizer that pulses to the music rhythm.
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
