import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music/src/colors/colors.dart';
import 'package:music/src/controller/audio_controller.dart';
import 'package:music/src/view/player%20view/player_buttons.dart';
import 'package:music/src/view/player%20view/favourite_button.dart';

class Player extends StatelessWidget {
  Player({super.key, required this.musicName, required this.artistName});
  final String musicName;
  final String artistName;
  final PlayerFunctionalities playfun = PlayerFunctionalities();
  static double val = 0;
  final controller = Get.find<PlayerController>();
  @override
  Widget build(BuildContext context) {
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
                  color: Colors.indigo,
                ),
              ),
            ),
            SizedBox(
              height: 135,
            ),
            Expanded(
              child: Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //music name and icon column
                          Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 280,
                                    child: Text(
                                      maxLines: 2,
                                      textDirection: TextDirection.ltr,
                                      musicName,
                                      style: GoogleFonts.abel(
                                        fontSize: 12,
                                        color: whiteColor,
                                        decorationColor: Colors.amber,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    artistName,
                                    style: GoogleFonts.abel(
                                      fontSize: 15,
                                      color: whiteColor,
                                      decorationColor: Colors.amber,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          //faviorite button
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
                      SizedBox(
                        height: 20,
                      ),

                      ///music button slider and time row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            "0.10",
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(
                            width: 335,
                            child: Slider(
                              value: 0.0,
                              onChanged: (value) {
                                val = value;
                              },
                            ),
                          ),
                          Text(
                            val.toString(),
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
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
                            onPressed: () {},
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
                            onPressed: () {},
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
