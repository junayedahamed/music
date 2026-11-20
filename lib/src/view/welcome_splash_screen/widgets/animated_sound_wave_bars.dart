import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animated 5-bar soundwave visualizer below the logo
class AnimatedSoundWaveBars extends StatefulWidget {
  final Color accentBlue;
  final bool isDark;

  const AnimatedSoundWaveBars({
    super.key,
    required this.accentBlue,
    required this.isDark,
  });

  @override
  State<AnimatedSoundWaveBars> createState() => _AnimatedSoundWaveBarsState();
}

class _AnimatedSoundWaveBarsState extends State<AnimatedSoundWaveBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final t = (_waveController.value + index * 0.2) % 1.0;
            final height = 4.0 + 12.0 * math.sin(t * math.pi);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: 3.5,
              height: height,
              decoration: BoxDecoration(
                color: widget.accentBlue.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}
