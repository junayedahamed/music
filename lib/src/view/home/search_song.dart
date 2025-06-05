import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music/src/colors/colors.dart';
import 'package:music/src/controller/audio_controller.dart';
import 'package:music/src/view/music%20tile/music_listtile.dart';
import 'package:music/src/view/player%20view/player_view.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SearchSong extends SearchDelegate {
  final List<SongModel> songs;
  SearchSong(this.songs);
  final controller = Get.find<PlayerController>();

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<SongModel> seacrhResult = songs.where((item) {
      return item.title.toLowerCase().contains(query.toLowerCase());
    }).toList();
    return ListView.builder(
      itemCount: seacrhResult.length,
      itemBuilder: (context, index) {
        final song = seacrhResult[index];
        return MusicListtile(
            leading: QueryArtworkWidget(
              id: song.id,
              type: ArtworkType.AUDIO,
              nullArtworkWidget: Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.music_note, color: whiteColor, size: 30),
              ),
            ),
            onPressed: () {
              controller.playaudio(song.uri, index, song.title);
              Get.to(() => Player(songs: controller.allsongs));
            },
            musicName: song.title.length > 35
                ? song.title.substring(0, 35)
                : song.title,
            artistName: song.artist ?? "Unknown Artist",
            trailing: Obx(
              () {
                return controller.playindex.value == index
                    ? Icon(Icons.play_arrow, size: 26, color: whiteColor)
                    : Icon(Icons.circle, size: 0, color: bgcolor);
              },
            ));
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<SongModel> seacrhSuggestion = songs.where((item) {
      return item.title.toLowerCase().contains(query.toLowerCase());
    }).toList();
    return ListView.builder(
      itemCount: seacrhSuggestion.length,
      itemBuilder: (context, index) {
        final song = seacrhSuggestion[index];
        return MusicListtile(
            leading: QueryArtworkWidget(
              id: song.id,
              type: ArtworkType.AUDIO,
              nullArtworkWidget: Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.music_note, color: whiteColor, size: 30),
              ),
            ),
            onPressed: () {
              controller.playaudio(song.uri, index, song.title);
              Get.to(() => Player(songs: controller.allsongs));
            },
            musicName: song.title.length > 35
                ? song.title.substring(0, 35)
                : song.title,
            artistName: song.artist ?? "Unknown Artist",
            trailing: Obx(
              () {
                return controller.playindex.value == index
                    ? Icon(Icons.play_arrow, size: 26, color: whiteColor)
                    : Icon(Icons.circle, size: 25, color: bgcolor);
              },
            ));
      },
    );
  }
}
