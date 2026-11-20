import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Mini 4-bar dancing equalizer for the BottomMusicView bar.
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
                barH = const [6.0, 10.0, 8.0, 5.0][i];
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
