import 'package:flutter/material.dart';
import 'package:music/src/controller/home_selection_controller.dart';
import 'package:music/src/view/home/alphabet_scrollbar.dart';

class HomeAlphabetSidebar extends StatelessWidget {
  final HomeSelectionController selController;
  final bool isDark;
  final Color accentBlue;
  final ValueChanged<String> onLetterSelected;

  static const List<String> alphabets = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '#'
  ];

  const HomeAlphabetSidebar({
    super.key,
    required this.selController,
    required this.isDark,
    required this.accentBlue,
    required this.onLetterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 4.0, top: 56.0, bottom: 8.0),
        child: AlphabetScrollbar(
          alphabets: alphabets,
          activeLetter: selController.activeLetter.value,
          letterHeight: 18.0,
          activeColor: accentBlue,
          inactiveColor: isDark ? Colors.white70 : const Color(0xff475569),
          backgroundColor: isDark
              ? const Color(0xff1f212c).withValues(alpha: 0.88)
              : Colors.white.withValues(alpha: 0.92),
          borderColor: isDark ? Colors.white12 : const Color(0xffcbd5e1),
          isDark: isDark,
          onLetterSelected: (letter) {
            selController.setDragging(true);
            selController.setActiveLetter(letter);
            selController.setShowCenterPreview(true);
            onLetterSelected(letter);
          },
          onDragEnd: () {
            selController.setDragging(false);
            selController.setShowCenterPreview(false);
          },
        ),
      ),
    );
  }
}
