import 'package:flutter/widgets.dart';
import 'package:music/src/controller/home_selection_controller.dart';
import 'package:on_audio_query/on_audio_query.dart';

/// Helper for scrolling and alphabet index mapping on the home view.
class AlphabetScrollHelper {
  static String getLetter(String title) {
    final clean = title.trim();
    if (clean.isEmpty) return '#';
    final first = clean[0].toUpperCase();
    return RegExp(r'[A-Z]').hasMatch(first) ? first : '#';
  }

  static void onScroll({
    required ScrollController scrollController,
    required HomeSelectionController selController,
    required List<SongModel> songs,
  }) {
    if (selController.isDraggingScrollbar.value) return;
    if (songs.isEmpty || !scrollController.hasClients) return;

    final double offset = scrollController.offset;
    final int topIndex = (offset / 78.0).floor().clamp(0, songs.length - 1);
    final currentLetter = getLetter(songs[topIndex].title);
    if (selController.activeLetter.value != currentLetter) {
      selController.setActiveLetter(currentLetter);
    }
  }

  static void scrollToLetter({
    required String letter,
    required ScrollController scrollController,
    required List<SongModel> songs,
  }) {
    if (songs.isEmpty || !scrollController.hasClients) return;
    final target = letter.toUpperCase();
    int idx = -1;
    if (target == '#') {
      idx = songs.indexWhere((s) {
        final t = s.title.trim();
        return t.isNotEmpty && !RegExp(r'[a-zA-Z]').hasMatch(t[0]);
      });
    } else {
      idx = songs.indexWhere((s) {
        final t = s.title.trim();
        if (t.isEmpty) return false;
        final f = t[0].toUpperCase();
        return RegExp(r'[A-Z]').hasMatch(f) && f.compareTo(target) >= 0;
      });
    }
    if (idx == -1) idx = songs.length - 1;
    final targetOffset =
        (idx * 78.0).clamp(0.0, scrollController.position.maxScrollExtent);
    scrollController.jumpTo(targetOffset);
  }
}
