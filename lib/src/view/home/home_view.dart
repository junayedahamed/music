import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:music/src/colors/colors.dart';
import 'package:music/src/colors/styled_text.dart';
import 'package:music/src/view/music%20tile/music_listtile.dart';
import 'package:music/src/view/player%20view/player_view.dart';

enum OrderType {
  name,
  addingtime,
  playedNumber,
  duration,
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // final contoller = Get.put(PlayerController());
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
                      value: OrderType.name,
                      child: Text(
                        "Name",
                        style: fontStyle(15, whiteColor),
                      ),
                    ),
                    PopupMenuItem(
                      value: OrderType.addingtime,
                      child: Text(
                        "Date",
                        style: fontStyle(15, whiteColor),
                      ),
                    ),
                    PopupMenuItem(
                      value: OrderType.playedNumber,
                      child: Text(
                        "Number of playing",
                        style: fontStyle(15, whiteColor),
                      ),
                    ),
                    PopupMenuItem(
                      value: OrderType.duration,
                      child: Text(
                        "Size",
                        style: fontStyle(15, whiteColor),
                      ),
                    )
                  ],
                  onSelected: (value) {
                    // print(value);
                  },
                )
              ],
              centerTitle: true,
              title: Text(
                "Music Player",
                style: fontStyle(20, Colors.green),
              ),
            ),
            // FutureBuilder<List<SongModel>>(
            //   future: contoller.audioQuery.querySongs(
            //     ignoreCase: true,
            //     orderType: OrderType.ASC_OR_SMALLER,
            //     sortType: null,
            //     uriType: UriType.EXTERNAL,
            //   ),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return const SliverFillRemaining(
            //         child: Center(
            //           child: CircularProgressIndicator(),
            //         ),
            //       );
            //     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            //       return SliverFillRemaining(
            //         child: Center(
            //           child: Text(
            //             "No song found",
            //             style: fontStyle(
            //               14,
            //               whiteColor,
            //             ),
            //           ),
            //         ),
            //       );
            //     } else {
            //       return SliverList(
            //         delegate: SliverChildBuilderDelegate(
            //           (context, index) {
            //             final song = snapshot.data![index];
            //             return MusicListtile(
            //               musicName: song.title,
            //               artistName: song.artist ?? "Unknown Artist",
            //             );
            //           },
            //           childCount: snapshot.data!.length,
            //         ),
            //       );
            //     }
            //   },
            // )

            SliverList.builder(
              itemCount: 15,
              itemBuilder: (context, index) => MusicListtile(
                  onPressed: () {
                    Get.to(Player());
                  },
                  musicName: "musicName",
                  artistName: "artistName"),
            )
          ],
        ));
  }
}
