import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class AlphabetScrollbar extends StatelessWidget {
  final List<String> alphabets;
  final String? activeLetter;
  final void Function(String letter) onLetterSelected;
  final VoidCallback onDragEnd;
  final double letterHeight;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool isDark;

  const AlphabetScrollbar({
    super.key,
    required this.alphabets,
    required this.onLetterSelected,
    required this.onDragEnd,
    this.activeLetter,
    this.letterHeight = 18.0,
    this.activeColor,
    this.inactiveColor,
    this.backgroundColor,
    this.borderColor,
    this.isDark = true,
  });

  void _handleTouch(
      Offset localPosition, double verticalPadding, double borderWidth) {
    if (alphabets.isEmpty || letterHeight <= 0) return;
    final double contentY = localPosition.dy - verticalPadding - borderWidth;
    final int index =
        (contentY / letterHeight).floor().clamp(0, alphabets.length - 1);
    final letter = alphabets[index];
    HapticFeedback.selectionClick();
    onLetterSelected(letter);
  }

  @override
  Widget build(BuildContext context) {
    const double verticalPadding = 10.0;
    const double borderWidth = 1.0;

    final effectiveActiveColor = activeColor ??
        (isDark ? const Color(0xff00b0ff) : const Color(0xff0081cb));
    final effectiveInactiveColor = inactiveColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.75)
            : const Color(0xff475569));
    final effectiveBgColor = backgroundColor ??
        (isDark
            ? const Color(0xff1f212c).withValues(alpha: 0.88)
            : Colors.white.withValues(alpha: 0.92));
    final effectiveBorderColor = borderColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.12)
            : const Color(0xffcbd5e1));

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragDown: (details) =>
          _handleTouch(details.localPosition, verticalPadding, borderWidth),
      onVerticalDragUpdate: (details) =>
          _handleTouch(details.localPosition, verticalPadding, borderWidth),
      onVerticalDragEnd: (_) => onDragEnd(),
      onVerticalDragCancel: () => onDragEnd(),
      onTapDown: (details) =>
          _handleTouch(details.localPosition, verticalPadding, borderWidth),
      onTapUp: (_) => onDragEnd(),
      onTapCancel: () => onDragEnd(),
      child: Container(
        width: 26,
        padding: const EdgeInsets.symmetric(vertical: verticalPadding),
        decoration: BoxDecoration(
          color: effectiveBgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: effectiveBorderColor,
            width: borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.5)
                  : const Color(0xff64748b).withValues(alpha: 0.18),
              blurRadius: isDark ? 16 : 10,
              spreadRadius: 1,
              offset: const Offset(-2, 3),
            ),
            if (isDark)
              BoxShadow(
                color: effectiveActiveColor.withValues(alpha: 0.15),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(-1, 0),
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: alphabets.map((letter) {
            final isSelected = activeLetter == letter;
            return SizedBox(
              height: letterHeight,
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    color: isSelected
                        ? effectiveActiveColor
                        : effectiveInactiveColor,
                    fontSize: isSelected ? 13 : 10.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    shadows: isSelected && isDark
                        ? [
                            Shadow(
                              color: effectiveActiveColor.withValues(alpha: 0.8),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
