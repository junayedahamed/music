import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music/src/colors/colors.dart';
import 'package:music/src/colors/styled_text.dart';
import 'package:music/src/controller/audio_controller.dart';
import 'package:music/src/view/home/sort_song_by_order.dart';
import 'package:music/src/view/music%20tile/music_listtile.dart';
import 'package:music/src/view/player%20view/player_view.dart';
import 'package:on_audio_query/on_audio_query.dart';

enum Customorder { atoz, ztoa }

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final PlayerController contoller = Get.put(PlayerController());
  final SortSongByOrder sort = SortSongByOrder();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bgDarkcolor,
        // appBar:
        body: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: bgDarkcolor,
              pinned: true,
              expandedHeight: 50,
              // AppBar(
              actions: [
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.search,
                      color: whiteColor,
                    )),
                PopupMenuButton(
                  color: Colors.black,
                  icon: Icon(
                    Icons.sort,
                    color: whiteColor,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: Customorder.atoz,
                      child: Text(
                        "A-Z",
                        style: fontStyle(15, whiteColor),
                      ),
                    ),
                    PopupMenuItem(
                      value: Customorder.ztoa,
                      child: Text(
                        "Z-A",
                        style: fontStyle(15, whiteColor),
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == Customorder.atoz) {
                      sort.desc(value);
                    } else {
                      sort.asc(value);
                    }
                  },
                )
              ],
              centerTitle: true,
              title: Text(
                "Music Player",
                style: fontStyle(20, Colors.green),
              ),
            ),
            ListenableBuilder(
                listenable: sort,
                builder: (context, snapshot) {
                  return FutureBuilder<List<SongModel>>(
                    future: contoller.audioQuery.querySongs(
                      ignoreCase: true,
                      orderType: sort.order,
                      sortType: null,
                      uriType: UriType.EXTERNAL,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SliverFillRemaining(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Text(
                              "No song found",
                              style: fontStyle(
                                14,
                                whiteColor,
                              ),
                            ),
                          ),
                        );
                      } else {
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final song = snapshot.data![index];
                              return Obx(
                                () => MusicListtile(
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
                                        child: Icon(
                                          Icons.music_note,
                                          color: whiteColor,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      // print(contoller.isplaying);
                                      contoller.playaudio(
                                        snapshot.data![index].uri,
                                        index,
                                      );
                                      Get.to(Player(
                                        musicName: song.title,
                                        artistName:
                                            song.artist ?? "Unknown Artist",
                                      ));
                                    },
                                    musicName: song.title.length > 35
                                        ? song.title.substring(0, 35)
                                        : song.title,
                                    artistName: song.artist ?? "Unknown Artist",
                                    trailing:
                                        contoller.playindex.value == index &&
                                                contoller.isplaying.value
                                            ? Icon(
                                                Icons.play_arrow,
                                                size: 26,
                                                color: whiteColor,
                                              )
                                            : Icon(
                                                Icons.circle,
                                                size: 25,
                                              )),
                              );
                            },
                            childCount: snapshot.data!.length,
                          ),
                        );
                      }
                    },
                  );
                })

            // SliverList.builder(
            //   itemCount: 15,
            //   itemBuilder: (context, index) => MusicListtile(
            //       onPressed: () {
            //         Get.to(Player());
            //       },
            //       musicName: "musicName",
            //       artistName: "artistName"),
            // )
          ],
        ));
  }
}
