import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music/src/colors/colors.dart';
import 'package:music/src/colors/styled_text.dart';
import 'package:music/src/controller/audio_controller.dart';
import 'package:music/src/view/home/bottom_muisic_view/bottom_music_view.dart';
import 'package:music/src/view/home/sort_song_by_order.dart';
import 'package:music/src/view/music%20tile/music_listtile.dart';
import 'package:music/src/view/player%20view/player_view.dart';
import 'package:on_audio_query/on_audio_query.dart';

enum Customorder {
  atoz,
  ztoa,
}

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final PlayerController contoller = Get.put(PlayerController());

  final SortSongByOrder sort = SortSongByOrder();

  final playercontroller = Get.find<PlayerController>();

  // @override
  @override
  Widget build(BuildContext context) {
    List<SongModel> songs = [];
    return Scaffold(
      backgroundColor: bgDarkcolor,
      // appBar: AppBar(
      //   backgroundColor: bgDarkcolor,
      //   // pinned: false,
      //   // expandedHeight: 50,
      //   // AppBar(
      //   actions: [
      //     IconButton(
      //         onPressed: () {
      //           // showSearch(context: context, delegate: SearchSong());
      //         },
      //         icon: Icon(
      //           Icons.search,
      //           color: whiteColor,
      //         )),
      //     PopupMenuButton(
      //       color: Colors.black,
      //       icon: Icon(
      //         Icons.sort,
      //         color: whiteColor,
      //       ),
      //       itemBuilder: (context) => [
      //         PopupMenuItem(
      //           value: Customorder.atoz,
      //           child: Text(
      //             " A to Z",
      //             style: fontStyle(15, whiteColor),
      //           ),
      //         ),
      //         PopupMenuItem(
      //           value: Customorder.ztoa,
      //           child: Text(
      //             "Z to A",
      //             style: fontStyle(15, whiteColor),
      //           ),
      //         ),
      //       ],
      //       onSelected: (value) {
      //         sort.sortby(value);
      //       },
      //     )
      //   ],
      //   centerTitle: true,
      //   title: Text(
      //     "Music Player",
      //     style: fontStyle(20, Colors.green),
      //   ),
      // ),
      // body: Obx(() {
      //   if (contoller.loading.value) {
      //     return const Center(child: CircularProgressIndicator());
      //   }

      //   if (contoller.allsongs.isEmpty && !contoller.loading.value) {
      //     return Center(
      //       child: Text(
      //         "No song found",
      //         style: fontStyle(14, whiteColor),
      //       ),
      //     );
      //   }

      //   return ListenableBuilder(
      //       listenable: sort,
      //       builder: (context, snapshot) {
      //         return ListView.builder(
      //           physics: BouncingScrollPhysics(),
      //           itemCount: contoller.allsongs.length,
      //           itemBuilder: (context, index) {
      //             final song = contoller.allsongs[index];
      //             songs.add(song);
      //             return MusicListtile(
      //               leading: QueryArtworkWidget(
      //                 id: song.id,
      //                 type: ArtworkType.AUDIO,
      //                 nullArtworkWidget: Container(
      //                   height: 45,
      //                   width: 45,
      //                   decoration: BoxDecoration(
      //                     color: Colors.black,
      //                     shape: BoxShape.circle,
      //                   ),
      //                   child: Icon(
      //                     Icons.music_note,
      //                     color: whiteColor,
      //                     size: 30,
      //                   ),
      //                 ),
      //               ),
      //               onPressed: () {
      //                 contoller.playaudio(song.uri, index, song.title);
      //                 Get.to(() => Player(songs: contoller.allsongs));
      //               },
      //               musicName: song.title.length > 35
      //                   ? song.title.substring(0, 35)
      //                   : song.title,
      //               artistName: song.artist ?? "Unknown Artist",
      //               trailing: contoller.playindex.value == index &&
      //                       contoller.isplaying.value
      //                   ? Icon(Icons.play_arrow, size: 26, color: whiteColor)
      //                   : Icon(Icons.circle, size: 25, color: bgcolor),
      //             );
      //           },
      //         );
      //       });
      // }),

      // body: CustomScrollView(physics: BouncingScrollPhysics(), slivers: [
      //   SliverAppBar(
      //     backgroundColor: bgDarkcolor,
      //     pinned: false,
      //     expandedHeight: 50,
      //     // AppBar(
      //     actions: [
      //       IconButton(
      //           onPressed: () {
      //             // showSearch(context: context, delegate: SearchSong());
      //           },
      //           icon: Icon(
      //             Icons.search,
      //             color: whiteColor,
      //           )),
      //       PopupMenuButton(
      //         color: Colors.black,
      //         icon: Icon(
      //           Icons.sort,
      //           color: whiteColor,
      //         ),
      //         itemBuilder: (context) => [
      //           PopupMenuItem(
      //             value: Customorder.atoz,
      //             child: Text(
      //               " A to Z",
      //               style: fontStyle(15, whiteColor),
      //             ),
      //           ),
      //           PopupMenuItem(
      //             value: Customorder.ztoa,
      //             child: Text(
      //               "Z to A",
      //               style: fontStyle(15, whiteColor),
      //             ),
      //           ),
      //         ],
      //         onSelected: (value) {
      //           sort.sortby(value);
      //         },
      //       )
      //     ],
      //     centerTitle: true,
      //     title: Text(
      //       "Music Player",
      //       style: fontStyle(20, Colors.green),
      //     ),
      //   ),
      //   ListenableBuilder(
      //       listenable: sort,
      //       builder: (context, snapshot) {
      //         // return FutureBuilder<List<SongModel>>(
      //         // future: contoller.audioQuery.querySongs(
      //         //   ignoreCase: true,
      //         //   orderType: sort.order,
      //         //   sortType: null,
      //         //   uriType: UriType.EXTERNAL,
      //         // ),

      //         return ListView.builder(
      //           itemBuilder: (context, index) {
      //             if (contoller.loading.value) {
      //               return const SliverFillRemaining(
      //                 child: Center(
      //                   child: CircularProgressIndicator(),
      //                 ),
      //               );
      //             } else if (contoller.allsongs.isEmpty ||
      //                 contoller.loading.value == false) {
      //               return SliverFillRemaining(
      //                 child: SliverFillRemaining(
      //                   child: Center(
      //                     child: Text(
      //                       "No song found",
      //                       style: fontStyle(
      //                         14,
      //                         whiteColor,
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //               );
      //             } else {
      //               // src.setvalue(snapshot.data);
      //               return SliverList(
      //                 delegate: SliverChildBuilderDelegate(
      //                   (context, index) {
      //                     final song = contoller.allsongs[index];
      //                     songs.add(song);
      //                     return Obx(
      //                       () => MusicListtile(
      //                           leading: QueryArtworkWidget(
      //                             id: song.id,
      //                             type: ArtworkType.AUDIO,
      //                             nullArtworkWidget: Container(
      //                               height: 45,
      //                               width: 45,
      //                               decoration: BoxDecoration(
      //                                 color: Colors.black,
      //                                 shape: BoxShape.circle,
      //                               ),
      //                               child: Icon(
      //                                 Icons.music_note,
      //                                 color: whiteColor,
      //                                 size: 30,
      //                               ),
      //                             ),
      //                           ),
      //                           onPressed: () {
      //                             contoller.playaudio(
      //                                 song.uri, index, song.title);
      //                             Get.to(() => Player(
      //                                   songs: contoller.allsongs,

      //                                   // song.artist ?? "Unknown Artist",
      //                                 ));
      //                           },
      //                           musicName: song.title.length > 35
      //                               ? song.title.substring(0, 35)
      //                               : song.title,
      //                           artistName: song.artist ?? "Unknown Artist",
      //                           trailing: contoller.playindex.value == index &&
      //                                   contoller.isplaying.value
      //                               ? Icon(
      //                                   Icons.play_arrow,
      //                                   size: 26,
      //                                   color: whiteColor,
      //                                 )
      //                               : Icon(
      //                                   Icons.circle,
      //                                   size: 25,
      //                                   color: bgcolor,
      //                                 )),
      //                     );
      //                   },
      //                   childCount: contoller.allsongs.length,
      //                 ),
      //               );
      //             }
      //           },
      //         );
      //       })
      // ]),
      body: Obx(
        () => CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: bgDarkcolor,
              pinned: false,
              expandedHeight: 50,
              actions: [
                IconButton(
                  onPressed: () {
                    // showSearch(context: context, delegate: SearchSong());
                  },
                  icon: Icon(Icons.search, color: whiteColor),
                ),
                PopupMenuButton(
                  color: Colors.black,
                  icon: Icon(Icons.sort, color: whiteColor),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: Customorder.atoz,
                      child: Text("A to Z", style: fontStyle(15, whiteColor)),
                    ),
                    PopupMenuItem(
                      value: Customorder.ztoa,
                      child: Text("Z to A", style: fontStyle(15, whiteColor)),
                    ),
                  ],
                  onSelected: (value) {
                    contoller.sorting(value);
                  },
                ),
              ],
              centerTitle: true,
              title: Text(
                "Music Player",
                style: fontStyle(20, Colors.green),
              ),
            ),

            // Loading Indicator
            if (contoller.loading.value)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )

            // No songs found
            else if (contoller.allsongs.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child:
                      Text("No song found", style: fontStyle(14, whiteColor)),
                ),
              )

            // Song list
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final song = contoller.allsongs[index];
                    songs.add(song);

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
                            child: Icon(Icons.music_note,
                                color: whiteColor, size: 30),
                          ),
                        ),
                        onPressed: () {
                          contoller.playaudio(song.uri, index, song.title);
                          Get.to(() => Player(songs: contoller.allsongs));
                        },
                        musicName: song.title.length > 35
                            ? song.title.substring(0, 35)
                            : song.title,
                        artistName: song.artist ?? "Unknown Artist",
                        trailing: Obx(
                          () {
                            return contoller.playindex.value == index
                                ? Icon(Icons.play_arrow,
                                    size: 26, color: whiteColor)
                                : Icon(Icons.circle, size: 25, color: bgcolor);
                          },
                        ));
                  },
                  childCount: contoller.allsongs.length,
                ),
              ),
          ],
        ),
      ),

      bottomNavigationBar: BottomMusicView(songs: songs),
    );
  }
}





        // body: ListenableBuilder(
        //     listenable: sort,
        //     builder: (context, snapshot) {
        //       // return FutureBuilder<List<SongModel>>(
        //       // future: contoller.audioQuery.querySongs(
        //       //   ignoreCase: true,
        //       //   orderType: sort.order,
        //       //   sortType: null,
        //       //   uriType: UriType.EXTERNAL,
        //       // ),

        //       return ListView.builder(
        //         itemBuilder: (context, index) {
        //           if (contoller.loading.value) {
        //             return const SliverFillRemaining(
        //               child: Center(
        //                 child: CircularProgressIndicator(),
        //               ),
        //             );
        //           } else if (contoller.allsongs.isEmpty ||
        //               contoller.loading.value == false) {
        //             return SliverFillRemaining(
        //               child: Center(
        //                 child: Text(
        //                   "No song found",
        //                   style: fontStyle(
        //                     14,
        //                     whiteColor,
        //                   ),
        //                 ),
        //               ),
        //             );
        //           } else {
        //             // src.setvalue(snapshot.data);
        //             return SliverList(
        //               delegate: SliverChildBuilderDelegate(
        //                 (context, index) {
        //                   final song = contoller.allsongs[index];
        //                   songs.add(song);
        //                   return Obx(
        //                     () => MusicListtile(
        //                         leading: QueryArtworkWidget(
        //                           id: song.id,
        //                           type: ArtworkType.AUDIO,
        //                           nullArtworkWidget: Container(
        //                             height: 45,
        //                             width: 45,
        //                             decoration: BoxDecoration(
        //                               color: Colors.black,
        //                               shape: BoxShape.circle,
        //                             ),
        //                             child: Icon(
        //                               Icons.music_note,
        //                               color: whiteColor,
        //                               size: 30,
        //                             ),
        //                           ),
        //                         ),
        //                         onPressed: () {
        //                           contoller.playaudio(
        //                               song.uri, index, song.title);
        //                           Get.to(() => Player(
        //                                 songs: contoller.allsongs,

        //                                 // song.artist ?? "Unknown Artist",
        //                               ));
        //                         },
        //                         musicName: song.title.length > 35
        //                             ? song.title.substring(0, 35)
        //                             : song.title,
        //                         artistName: song.artist ?? "Unknown Artist",
        //                         trailing: contoller.playindex.value == index &&
        //                                 contoller.isplaying.value
        //                             ? Icon(
        //                                 Icons.play_arrow,
        //                                 size: 26,
        //                                 color: whiteColor,
        //                               )
        //                             : Icon(
        //                                 Icons.circle,
        //                                 size: 25,
        //                                 color: bgcolor,
        //                               )),
        //                   );
        //                 },
        //                 childCount: contoller.allsongs.length,
        //               ),
        //             );
        //           }
        //         },
        //       );
        //     }),

        // body: ListenableBuilder(
        //   listenable: sort,
        //   builder: (context, snapshot) {
        //     if (contoller.loading.value) {
        //       return const Center(child: CircularProgressIndicator());
        //     }

        //     if (contoller.allsongs.isEmpty) {
        //       return Center(
        //         child: Text(
        //           "No song found",
        //           style: fontStyle(14, whiteColor),
        //         ),
        //       );
        //     }

        //     return CustomScrollView(
        //       physics: const BouncingScrollPhysics(),
        //       slivers: [
        //         SliverList(
        //           delegate: SliverChildBuilderDelegate(
        //             (context, index) {
        //               final song = contoller.allsongs[index];
        //               return Obx(
        //                 () => MusicListtile(
        //                   leading: QueryArtworkWidget(
        //                     id: song.id,
        //                     type: ArtworkType.AUDIO,
        //                     nullArtworkWidget: Container(
        //                       height: 45,
        //                       width: 45,
        //                       decoration: const BoxDecoration(
        //                         color: Colors.black,
        //                         shape: BoxShape.circle,
        //                       ),
        //                       child: Icon(
        //                         Icons.music_note,
        //                         color: whiteColor,
        //                         size: 30,
        //                       ),
        //                     ),
        //                   ),
        //                   onPressed: () {
        //                     contoller.playaudio(song.uri, index, song.title);
        //                     Get.to(() => Player(songs: contoller.allsongs));
        //                   },
        //                   musicName: song.title.length > 35
        //                       ? song.title.substring(0, 35)
        //                       : song.title,
        //                   artistName: song.artist ?? "Unknown Artist",
        //                   trailing: contoller.playindex.value == index &&
        //                           contoller.isplaying.value
        //                       ? Icon(Icons.play_arrow,
        //                           size: 26, color: whiteColor)
        //                       : Icon(Icons.circle, size: 25, color: bgcolor),
        //                 ),
        //               );
        //             },
        //             childCount: contoller.allsongs.length,
        //           ),
        //         ),
        //       ],
        //     );
        //   },
        // ),



// body: CustomScrollView(

        //   physics: BouncingScrollPhysics(),
        //   slivers: [
        //     SliverAppBar(
        //       backgroundColor: bgDarkcolor,
        //       pinned: false,
        //       expandedHeight: 50,
        //       // AppBar(
        //       actions: [
        //         IconButton(
        //             onPressed: () {
        //               // showSearch(context: context, delegate: SearchSong());
        //             },
        //             icon: Icon(
        //               Icons.search,
        //               color: whiteColor,
        //             )),
        //         PopupMenuButton(
        //           color: Colors.black,
        //           icon: Icon(
        //             Icons.sort,
        //             color: whiteColor,
        //           ),
        //           itemBuilder: (context) => [
        //             PopupMenuItem(
        //               value: Customorder.atoz,
        //               child: Text(
        //                 " A to Z",
        //                 style: fontStyle(15, whiteColor),
        //               ),
        //             ),
        //             PopupMenuItem(
        //               value: Customorder.ztoa,
        //               child: Text(
        //                 "Z to A",
        //                 style: fontStyle(15, whiteColor),
        //               ),
        //             ),
        //           ],
        //           onSelected: (value) {
        //             sort.sortby(value);
        //           },
        //         )
        //       ],
        //       centerTitle: true,
        //       title: Text(
        //         "Music Player",
        //         style: fontStyle(20, Colors.green),
        //       ),
        //     ),
        //     ListenableBuilder(
        //         listenable: sort,
        //         builder: (context, snapshot) {
        //           // return FutureBuilder<List<SongModel>>(
        //           // future: contoller.audioQuery.querySongs(
        //           //   ignoreCase: true,
        //           //   orderType: sort.order,
        //           //   sortType: null,
        //           //   uriType: UriType.EXTERNAL,
        //           // ),

        //           return ListView.builder(
        //             itemBuilder: (context, index) {
        //               if (contoller.loading.value) {
        //                 return const SliverFillRemaining(
        //                   child: Center(
        //                     child: CircularProgressIndicator(),
        //                   ),
        //                 );
        //               } else if (contoller.allsongs.isEmpty ||
        //                   contoller.loading.value == false) {
        //                 return SliverFillRemaining(
        //                   child: Center(
        //                     child: Text(
        //                       "No song found",
        //                       style: fontStyle(
        //                         14,
        //                         whiteColor,
        //                       ),
        //                     ),
        //                   ),
        //                 );
        //               } else {
        //                 // src.setvalue(snapshot.data);
        //                 return SliverList(
        //                   delegate: SliverChildBuilderDelegate(
        //                     (context, index) {
        //                       final song = contoller.allsongs[index];
        //                       songs.add(song);
        //                       return Obx(
        //                         () => MusicListtile(
        //                             leading: QueryArtworkWidget(
        //                               id: song.id,
        //                               type: ArtworkType.AUDIO,
        //                               nullArtworkWidget: Container(
        //                                 height: 45,
        //                                 width: 45,
        //                                 decoration: BoxDecoration(
        //                                   color: Colors.black,
        //                                   shape: BoxShape.circle,
        //                                 ),
        //                                 child: Icon(
        //                                   Icons.music_note,
        //                                   color: whiteColor,
        //                                   size: 30,
        //                                 ),
        //                               ),
        //                             ),
        //                             onPressed: () {
        //                               contoller.playaudio(
        //                                   song.uri, index, song.title);
        //                               Get.to(() => Player(
        //                                     songs: contoller.allsongs,

        //                                     // song.artist ?? "Unknown Artist",
        //                                   ));
        //                             },
        //                             musicName: song.title.length > 35
        //                                 ? song.title.substring(0, 35)
        //                                 : song.title,
        //                             artistName: song.artist ?? "Unknown Artist",
        //                             trailing:
        //                                 contoller.playindex.value == index &&
        //                                         contoller.isplaying.value
        //                                     ? Icon(
        //                                         Icons.play_arrow,
        //                                         size: 26,
        //                                         color: whiteColor,
        //                                       )
        //                                     : Icon(
        //                                         Icons.circle,
        //                                         size: 25,
        //                                         color: bgcolor,
        //                                       )),
        //                       );
        //                     },
        //                     childCount: contoller.allsongs.length,
        //                   ),
        //                 );
        //               }
        //             },
        //           );
        //         })

        //     // SliverList.builder(
        //     //   itemCount: 15,
        //     //   itemBuilder: (context, index) => MusicListtile(
        //     //       onPressed: () {
        //     //         Get.to(Player());
        //     //       },
        //     //       musicName: "musicName",
        //     //       artistName: "artistName"),
        //     // )
        //   ],
        // ),