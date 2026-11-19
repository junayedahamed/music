import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music/src/controller/audio_controller.dart';
import 'package:music/src/controller/theme_controller.dart';
import 'package:music/src/view/music%20tile/music_listtile.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SearchSong extends SearchDelegate {
  final List<SongModel> songs;
  SearchSong(this.songs);

  final controller = Get.find<PlayerController>();

  @override
  ThemeData appBarTheme(BuildContext context) {
    final themeController = Get.put(ThemeController());
    final cardBg = themeController.cardBg;
    final textPrimary = themeController.textPrimary;
    final textSecondary = themeController.textSecondary;

    return ThemeData(
      scaffoldBackgroundColor: themeController.scaffoldBg,
      appBarTheme: AppBarTheme(
        backgroundColor: cardBg,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
            color: textSecondary.withValues(alpha: 0.6), fontSize: 14),
        border: InputBorder.none,
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(color: textPrimary, fontSize: 16),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear_rounded, color: themeController.textPrimary),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: Icon(Icons.arrow_back_ios_new_rounded,
          color: themeController.textPrimary, size: 20),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode.value;
    final textPrimary = themeController.textPrimary;
    final accentGreen = themeController.accentGreen;

    final List<SongModel> searchResult = songs.where((item) {
      return item.title.toLowerCase().contains(query.toLowerCase()) ||
          (item.artist ?? "").toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (searchResult.isEmpty) {
      return Center(
        child: Text(
          "No songs found matching '$query'",
          style: TextStyle(color: themeController.textSecondary, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: searchResult.length,
      itemBuilder: (context, index) {
        final song = searchResult[index];
        return Obx(() {
          final isCurrent = controller.songUri == song.uri;
          final isPlaying = isCurrent && controller.isplaying.value;

          return MusicListtile(
            songUri: song.uri,
            songId: song.id,
            isCurrentSong: isCurrent,
            isPlaying: isPlaying,
            leading: QueryArtworkWidget(
              id: song.id,
              type: ArtworkType.AUDIO,
              nullArtworkWidget: Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: isDark ? Colors.black54 : const Color(0xffe2e8f0),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.music_note, color: textPrimary, size: 26),
              ),
            ),
            onPressed: () {
              final origIdx = songs.indexWhere((s) => s.id == song.id);
              controller.playOrNavigate(
                  song, origIdx >= 0 ? origIdx : index, songs);
            },
            musicName: song.title,
            artistName: song.artist ?? "Unknown Artist",
            trailing: isPlaying
                ? Icon(Icons.play_arrow_rounded, size: 28, color: accentGreen)
                : null,
          );
        });
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode.value;
    final textPrimary = themeController.textPrimary;
    final accentGreen = themeController.accentGreen;

    final List<SongModel> searchSuggestion = songs.where((item) {
      return item.title.toLowerCase().contains(query.toLowerCase()) ||
          (item.artist ?? "").toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: searchSuggestion.length,
      itemBuilder: (context, index) {
        final song = searchSuggestion[index];
        return Obx(() {
          final isCurrent = controller.songUri == song.uri;
          final isPlaying = isCurrent && controller.isplaying.value;

          return MusicListtile(
            songUri: song.uri,
            songId: song.id,
            isCurrentSong: isCurrent,
            isPlaying: isPlaying,
            leading: QueryArtworkWidget(
              id: song.id,
              type: ArtworkType.AUDIO,
              nullArtworkWidget: Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: isDark ? Colors.black54 : const Color(0xffe2e8f0),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.music_note, color: textPrimary, size: 26),
              ),
            ),
            onPressed: () {
              final origIdx = songs.indexWhere((s) => s.id == song.id);
              controller.playOrNavigate(
                  song, origIdx >= 0 ? origIdx : index, songs);
            },
            musicName: song.title,
            artistName: song.artist ?? "Unknown Artist",
            trailing: isPlaying
                ? Icon(Icons.play_arrow_rounded, size: 28, color: accentGreen)
                : null,
          );
        });
      },
    );
  }
}
