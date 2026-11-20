import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// GetX controller managing home song selection mode and alphabet preview.
class HomeSelectionController extends GetxController {
  final RxSet<int> selectedSongIds = <int>{}.obs;
  final RxnString activeLetter = RxnString();
  final RxBool isDraggingScrollbar = false.obs;
  final RxBool showCenterPreview = false.obs;

  bool get isSelectionMode => selectedSongIds.isNotEmpty;

  void toggleSelectSong(int songId) {
    HapticFeedback.selectionClick();
    if (selectedSongIds.contains(songId)) {
      selectedSongIds.remove(songId);
    } else {
      selectedSongIds.add(songId);
    }
  }

  void addSong(int songId) {
    selectedSongIds.add(songId);
  }

  void selectAll(Iterable<int> songIds) {
    HapticFeedback.mediumImpact();
    if (selectedSongIds.length == songIds.length) {
      selectedSongIds.clear();
    } else {
      selectedSongIds.clear();
      selectedSongIds.addAll(songIds);
    }
  }

  void clearSelection() {
    selectedSongIds.clear();
  }

  void removeSongs(Iterable<int> songIds) {
    selectedSongIds.removeAll(songIds);
  }

  void setDragging(bool dragging) {
    isDraggingScrollbar.value = dragging;
  }

  void setActiveLetter(String? letter) {
    activeLetter.value = letter;
  }

  void setShowCenterPreview(bool show) {
    showCenterPreview.value = show;
  }
}
