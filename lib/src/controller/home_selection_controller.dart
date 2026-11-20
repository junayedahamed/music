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
    selectedSongIds.refresh();
  }

  void addSong(int songId) {
    HapticFeedback.selectionClick();
    selectedSongIds.add(songId);
    selectedSongIds.refresh();
  }

  void selectAll(Iterable<int> songIds) {
    HapticFeedback.mediumImpact();
    if (selectedSongIds.length == songIds.length) {
      selectedSongIds.clear();
    } else {
      selectedSongIds.clear();
      selectedSongIds.addAll(songIds);
    }
    selectedSongIds.refresh();
  }

  void clearSelection() {
    selectedSongIds.clear();
    selectedSongIds.refresh();
  }

  void removeSongs(Iterable<int> songIds) {
    selectedSongIds.removeAll(songIds);
    selectedSongIds.refresh();
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
