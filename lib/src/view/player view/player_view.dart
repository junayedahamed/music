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
      body: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
                child: Center(
              child: Icon(
                Icons.music_note,
                size: 200,
                color: whiteColor,
              ),
            )),
            SizedBox(
              height: 135,
            ),
            Expanded(
              child: Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    children: [
                      // Row(
                      //   children: [

                      //   ],
                      // ),
                      Obx(
                        () => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //music name and icon column
                            Column(
                              children: [
                                SizedBox(
                                  width: 250,
                                  child: Text(
                                    maxLines: 2,
                                    songs[controller.playindex.value].title,
                                    textDirection: TextDirection.ltr,
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.abel(
                                      fontSize: 13,
                                      color: whiteColor,
                                      decorationColor: Colors.amber,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                SizedBox(
                                  width: 250,
                                  child: Text(
                                    maxLines: 2,
                                    songs[controller.playindex.value].artist ??
                                        "Unknown",
                                    textDirection: TextDirection.ltr,
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.abel(
                                      fontSize: 12,
                                      color: whiteColor,
                                      decorationColor: Colors.amber,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ListenableBuilder(
                              listenable: playfun,
                              builder: (context, snapshot) {
                                return PlayerButtons(
                                  onPressed: playfun.changefav,
                                  myicon: playfun.pressFav
                                      ? Icon(
                                          Icons.favorite,
                                          color: Colors.pink,
                                          size: 30,
                                        )
                                      : Icon(
                                          Icons.favorite_border,
                                          color: whiteColor,
                                          size: 30,
                                        ),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),

                      ///music button slider and time row
                      Obx(
                        () => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 4,
                            ),
                            Text(
                              controller.position.value,
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(
                              width: 300,
                              child: Slider(
                                min: Duration(seconds: 0).inSeconds.toDouble(),
                                max: controller.max.value,
                                value: controller.value.value,
                                onChanged: (value) {
                                  controller
                                      .changedurationToseconds(value.toInt());
                                  value = value;
                                },
                              ),
                            ),
                            Text(
                              controller.duration.value,
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),

                      /// music play pause next prev button row

                      Row(
                        spacing: 35,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PlayerButtons(
                            myicon: Icon(
                              Icons.skip_previous,
                              size: 40,
                              color: whiteColor,
                            ),
                            onPressed: () {
                              controller.playaudio(
                                  songs[controller.playindex.value - 1].uri,
                                  controller.playindex.value - 1);
                            },
                          ),
                          Obx(
                            () => PlayerButtons(
                              myicon: controller.isplaying.value
                                  ? Icon(
                                      Icons.pause,
                                      size: 40,
                                      color: whiteColor,
                                    )
                                  : Icon(
                                      Icons.play_arrow,
                                      size: 40,
                                      color: whiteColor,
                                    ),
                              onPressed: () {
                                controller.pause();
                              },
                            ),
                          ),
                          PlayerButtons(
                            myicon: Icon(
                              Icons.skip_next,
                              size: 40,
                              color: whiteColor,
                            ),
                            onPressed: () {
                              controller.playaudio(
                                  songs[controller.playindex.value + 1].uri,
                                  controller.playindex.value + 1);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
