import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music/src/colors/colors.dart';

import 'package:music/src/controller/audio_controller.dart';
import 'package:music/src/view/player%20view/player_buttons.dart';
import 'package:music/src/view/player%20view/favourite_button.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Player extends StatelessWidget {
  Player({
    super.key,
    required this.songs,
  });
  final List<SongModel> songs;
  // final int index;
  final PlayerFunctionalities playfun = PlayerFunctionalities();
  // static double val = 0;
  final controller = Get.find<PlayerController>();

  @override
  Widget build(BuildContext context) {
    // controller.playindex.value = index;
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(
                Icons.arrow_back,
                color: whiteColor,
              )),
        ),
        // body: Column(
        //   children: [
        //     // Top music icon section
        //     Expanded(
        //       flex: 4,
        //       child: Center(
        //         child: Icon(
        //           Icons.music_note,
        //           size: 200,
        //           color: whiteColor,
        //         ),
        //       ),
        //     ),

        //     // Bottom control panel section
        //     Container(
        //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        //       color: Colors.black,
        //       child: Column(
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        //           /// Music title and artist row
        //           Obx(
        //             () => Row(
        //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //               crossAxisAlignment: CrossAxisAlignment.start,
        //               children: [
        //                 // Music title & artist
        //                 Expanded(
        //                   child: Column(
        //                     crossAxisAlignment: CrossAxisAlignment.start,
        //                     children: [
        //                       Text(
        //                         songs[controller.playindex.value].title,
        //                         maxLines: 2,
        //                         overflow: TextOverflow.ellipsis,
        //                         style: GoogleFonts.abel(
        //                           fontSize: 13,
        //                           color: whiteColor,
        //                         ),
        //                       ),
        //                       const SizedBox(height: 6),
        //                       Text(
        //                         songs[controller.playindex.value].artist ??
        //                             "Unknown",
        //                         maxLines: 1,
        //                         overflow: TextOverflow.ellipsis,
        //                         style: GoogleFonts.abel(
        //                           fontSize: 12,
        //                           color: whiteColor,
        //                         ),
        //                       ),
        //                     ],
        //                   ),
        //                 ),

        //                 // Favorite button
        //                 ListenableBuilder(
        //                   listenable: playfun,
        //                   builder: (context, snapshot) {
        //                     return PlayerButtons(
        //                       onPressed: playfun.changefav,
        //                       myicon: playfun.pressFav
        //                           ? const Icon(Icons.favorite,
        //                               color: Colors.pink, size: 30)
        //                           : Icon(Icons.favorite_border,
        //                               color: whiteColor, size: 30),
        //                     );
        //                   },
        //                 )
        //               ],
        //             ),
        //           ),

        //           const SizedBox(height: 10),

        //           /// Music slider and time
        //           Obx(
        //             () => Row(
        //               children: [
        //                 Text(
        //                   controller.position.value,
        //                   style: TextStyle(color: whiteColor, fontSize: 12),
        //                 ),
        //                 Expanded(
        //                   child: Slider(
        //                     min: 0,
        //                     max: controller.max.value,
        //                     value: controller.value.value,
        //                     onChanged: (value) {
        //                       controller.changedurationToseconds(value.toInt());
        //                     },
        //                   ),
        //                 ),
        //                 Text(
        //                   controller.duration.value,
        //                   style: TextStyle(color: whiteColor, fontSize: 12),
        //                 ),
        //               ],
        //             ),
        //           ),

        //           const SizedBox(height: 15),

        //           /// Play control buttons
        //           Row(
        //             mainAxisAlignment: MainAxisAlignment.center,
        //             children: [
        //               PlayerButtons(
        //                 myicon: Icon(Icons.skip_previous,
        //                     size: 40, color: whiteColor),
        //                 onPressed: () {
        //                   int index = controller.playindex.value;
        //                   int newIndex =
        //                       index == 0 ? songs.length - 1 : index - 1;
        //                   controller.playaudio(
        //                     songs[newIndex].uri,
        //                     newIndex,
        //                     songs[newIndex].title,
        //                   );
        //                 },
        //               ),
        //               const SizedBox(width: 35),
        //               Obx(
        //                 () => PlayerButtons(
        //                   myicon: controller.isplaying.value
        //                       ? Icon(Icons.pause, size: 40, color: whiteColor)
        //                       : Icon(Icons.play_arrow,
        //                           size: 40, color: whiteColor),
        //                   onPressed: controller.pause,
        //                 ),
        //               ),
        //               const SizedBox(width: 35),
        //               PlayerButtons(
        //                 myicon:
        //                     Icon(Icons.skip_next, size: 40, color: whiteColor),
        //                 onPressed: () {
        //                   int index = controller.playindex.value;
        //                   int newIndex =
        //                       index == songs.length - 1 ? 0 : index + 1;
        //                   controller.playaudio(
        //                     songs[newIndex].uri,
        //                     newIndex,
        //                     songs[newIndex].title,
        //                   );
        //                 },
        //               ),
        //             ],
        //           ),
        //         ],
        //       ),
        //     ),
        //   ],
        // ),
        // body: Column(
        //   children: [
        //     // Top music icon
        //     Expanded(
        //       child: Center(
        //         child: Icon(
        //           Icons.music_note,
        //           size: 200,
        //           color: whiteColor,
        //         ),
        //       ),
        //     ),

        //     // Spacer to push the controls higher
        //     const Spacer(),

        //     // Control section
        //     Container(
        //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        //       color: Colors.black,
        //       child: Column(
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        //           /// Music title and artist
        //           Obx(() => Row(
        //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                 children: [
        //                   Expanded(
        //                     child: Column(
        //                       crossAxisAlignment: CrossAxisAlignment.start,
        //                       children: [
        //                         Text(
        //                           songs[controller.playindex.value].title,
        //                           maxLines: 2,
        //                           overflow: TextOverflow.ellipsis,
        //                           style: GoogleFonts.abel(
        //                             fontSize: 13,
        //                             color: whiteColor,
        //                           ),
        //                         ),
        //                         const SizedBox(height: 6),
        //                         Text(
        //                           songs[controller.playindex.value].artist ??
        //                               "Unknown",
        //                           maxLines: 1,
        //                           overflow: TextOverflow.ellipsis,
        //                           style: GoogleFonts.abel(
        //                             fontSize: 12,
        //                             color: whiteColor,
        //                           ),
        //                         ),
        //                       ],
        //                     ),
        //                   ),
        //                   ListenableBuilder(
        //                     listenable: playfun,
        //                     builder: (context, _) {
        //                       return PlayerButtons(
        //                         onPressed: playfun.changefav,
        //                         myicon: playfun.pressFav
        //                             ? const Icon(Icons.favorite,
        //                                 color: Colors.pink, size: 30)
        //                             : Icon(Icons.favorite_border,
        //                                 color: whiteColor, size: 30),
        //                       );
        //                     },
        //                   ),
        //                 ],
        //               )),

        //           const SizedBox(height: 20),

        //           /// Music slider and time
        //           Obx(() => Row(
        //                 children: [
        //                   Text(
        //                     controller.position.value,
        //                     style: TextStyle(color: whiteColor, fontSize: 12),
        //                   ),
        //                   Expanded(
        //                     child: Slider(
        //                       min: 0,
        //                       max: controller.max.value,
        //                       value: controller.value.value,
        //                       onChanged: (value) {
        //                         controller.changedurationToseconds(value.toInt());
        //                       },
        //                     ),
        //                   ),
        //                   Text(
        //                     controller.duration.value,
        //                     style: TextStyle(color: whiteColor, fontSize: 12),
        //                   ),
        //                 ],
        //               )),

        //           const SizedBox(height: 15),

        //           /// Playback buttons
        //           Row(
        //             mainAxisAlignment: MainAxisAlignment.center,
        //             children: [
        //               PlayerButtons(
        //                 myicon: Icon(Icons.skip_previous,
        //                     size: 40, color: whiteColor),
        //                 onPressed: () {
        //                   int index = controller.playindex.value;
        //                   int newIndex =
        //                       index == 0 ? songs.length - 1 : index - 1;
        //                   controller.playaudio(
        //                     songs[newIndex].uri,
        //                     newIndex,
        //                     songs[newIndex].title,
        //                   );
        //                 },
        //               ),
        //               const SizedBox(width: 35),
        //               Obx(() => PlayerButtons(
        //                     myicon: controller.isplaying.value
        //                         ? Icon(Icons.pause, size: 40, color: whiteColor)
        //                         : Icon(Icons.play_arrow,
        //                             size: 40, color: whiteColor),
        //                     onPressed: controller.pause,
        //                   )),
        //               const SizedBox(width: 35),
        //               PlayerButtons(
        //                 myicon:
        //                     Icon(Icons.skip_next, size: 40, color: whiteColor),
        //                 onPressed: () {
        //                   int index = controller.playindex.value;
        //                   int newIndex =
        //                       index == songs.length - 1 ? 0 : index + 1;
        //                   controller.playaudio(
        //                     songs[newIndex].uri,
        //                     newIndex,
        //                     songs[newIndex].title,
        //                   );
        //                 },
        //               ),
        //             ],
        //           ),
        //         ],
        //       ),
        //     ),
        //   ],
        // ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Top section (music icon)
                      Expanded(
                        child: Center(
                          child: Icon(
                            Icons.music_note,
                            size: 200,
                            color: whiteColor,
                          ),
                        ),
                      ),

                      // Space or Spacer could go here if you want center positioning
                      const SizedBox(height: 20),

                      // Bottom section (controls)
                      Container(
                        color: Colors.black,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Title & artist
                            Obx(() => Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 250,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            songs[controller.playindex.value]
                                                .title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.abel(
                                              fontSize: 13,
                                              color: whiteColor,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            songs[controller.playindex.value]
                                                    .artist ??
                                                "Unknown",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.abel(
                                              fontSize: 12,
                                              color: whiteColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ListenableBuilder(
                                      listenable: playfun,
                                      builder: (context, _) {
                                        return PlayerButtons(
                                          onPressed: playfun.changefav,
                                          myicon: playfun.pressFav
                                              ? Icon(Icons.favorite,
                                                  color: Colors.pink, size: 30)
                                              : Icon(Icons.favorite_border,
                                                  color: whiteColor, size: 30),
                                        );
                                      },
                                    )
                                  ],
                                )),
                            const SizedBox(height: 20),

                            // Slider
                            Obx(() => Row(
                                  children: [
                                    Text(
                                      controller.position.value,
                                      style: TextStyle(
                                          color: whiteColor, fontSize: 12),
                                    ),
                                    Expanded(
                                      child: Slider(
                                        min: 0,
                                        max: controller.max.value,
                                        value: controller.value.value,
                                        onChanged: (value) {
                                          controller.changedurationToseconds(
                                              value.toInt());
                                        },
                                      ),
                                    ),
                                    Text(
                                      controller.duration.value,
                                      style: TextStyle(
                                          color: whiteColor, fontSize: 12),
                                    ),
                                  ],
                                )),

                            const SizedBox(height: 15),

                            // Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                PlayerButtons(
                                  myicon: Icon(Icons.skip_previous,
                                      size: 40, color: whiteColor),
                                  onPressed: controller.playprevious,
                                ),
                                const SizedBox(width: 35),
                                Obx(() => PlayerButtons(
                                      myicon: controller.isplaying.value
                                          ? Icon(Icons.pause,
                                              size: 40, color: whiteColor)
                                          : Icon(Icons.play_arrow,
                                              size: 40, color: whiteColor),
                                      onPressed: controller.pause,
                                    )),
                                const SizedBox(width: 35),
                                PlayerButtons(
                                  myicon: Icon(Icons.skip_next,
                                      size: 40, color: whiteColor),
                                  onPressed: controller.playnext,
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }
}
