import 'package:flutter/material.dart';

class PlayerButtons extends StatelessWidget {
  const PlayerButtons({
    super.key,
    required this.myicon,
    required this.onPressed,
  });

  final VoidCallback onPressed;
  final Widget myicon;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: myicon,
    );
  }
}
