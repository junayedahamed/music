import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class FavoriteController extends GetxController {
  final favoriteIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFavorites();
  }

  void _loadFavorites() {
    try {
      final box = Hive.box<Map>("music");
      final saved = box.get("favorite_ids");
      if (saved != null && saved["ids"] is List) {
        final List list = saved["ids"] as List;
        favoriteIds.addAll(list.map((e) => (e as num).toInt()));
      }
    } catch (_) {}
  }

  Future<void> _saveFavorites() async {
    try {
      final box = Hive.box<Map>("music");
      await box.put("favorite_ids", {
        "ids": favoriteIds.toList(),
      });
    } catch (_) {}
  }

  bool isFavorite(int songId) {
    return favoriteIds.contains(songId);
  }

  Future<void> toggleFavorite(SongModel song) async {
    HapticFeedback.lightImpact();
    if (favoriteIds.contains(song.id)) {
      favoriteIds.remove(song.id);
      await _saveFavorites();
      Get.rawSnackbar(
        message: "Removed '${song.title}' from Favorites",
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xff1f212c),
        icon: const Icon(Icons.favorite_border_rounded, color: Colors.white70),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
    } else {
      favoriteIds.add(song.id);
      await _saveFavorites();
      Get.rawSnackbar(
        message: "Added '${song.title}' to Favorites",
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xff1f212c),
        icon: const Icon(Icons.favorite_rounded, color: Color(0xffff4081)),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
    }
  }

  List<SongModel> filterFavorites(List<SongModel> allSongs) {
    return allSongs.where((song) => favoriteIds.contains(song.id)).toList();
  }
}
