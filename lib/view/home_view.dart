import 'package:flutter/material.dart';
import 'package:music/src/colors/colors.dart';
import 'package:music/src/colors/styled_text.dart';
import 'package:music/view/music/music_listtile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
                    icon: Icon(
                      Icons.more_vert,
                      color: whiteColor,
                    ),
                    itemBuilder: (context) => [
                          PopupMenuItem(child: Text("data")),
                          PopupMenuItem(child: Text("data")),
                          PopupMenuItem(child: Text("data")),
                        ])
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
                  musicName: "musicName", artistName: "artistName"),
            )
          ],
        ));
  }
}
