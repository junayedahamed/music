import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music/src/controller/audio_controller.dart';
import 'package:music/src/view/player%20view/player_buttons.dart';
import 'package:music/src/view/player%20view/player_view.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'package:step_progress_indicator/step_progress_indicator.dart';

class BottomMusicView extends StatelessWidget {
  BottomMusicView({super.key, required this.songs});
  final playercontroller = Get.find<PlayerController>();
  final List<SongModel> songs;
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Material(
        color: Colors.transparent,
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: EdgeInsets.all(12),
          height: 50,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                  colors: [Colors.black87, Colors.brown, Colors.white30])),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //title and music notation row
              GestureDetector(
                onTap: () {
                  Get.to(() => Player(songs: songs));
                },
                child: Row(
                  children: [
                    Container(
                        margin: EdgeInsets.only(left: 5),
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            color: Colors.green, shape: BoxShape.circle),
                        child: Icon(Icons.music_note)),
                    SizedBox(
                      width: 7,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .55,
                      child: Text(
                        playercontroller.songname.value,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // controller skip next ,progress and play,pause
              Row(
                spacing: 10,
                children: [
                  SizedBox(
                    width: 5,
                  ),
                  SizedBox(
                    height: 40,
                    width: 40,
                    child: CircularStepProgressIndicator(
                      totalSteps: playercontroller.max.value.toInt() > 0
                          ? playercontroller.max.value.toInt()
                          : 100,
                      currentStep: playercontroller.value.value.toInt(),
                      selectedColor: Colors.white.withAlpha(50),
                      unselectedStepSize: 5,
                      width: 40,
                      child: PlayerButtons(
                          myicon: Icon(playercontroller.isplaying.value
                              ? Icons.pause
                              : Icons.play_arrow),
                          onPressed: () {
                            playercontroller.pause();
                          }),
                    ),
                  ),
                  PlayerButtons(
                      myicon: Icon(Icons.skip_next),
                      onPressed: () {
                        if (playercontroller.playindex.value ==
                            songs.length - 1) {
                          playercontroller.playaudio(
                              songs[0].uri, 0, songs[0].title);
                        } else {
                          playercontroller.playaudio(
                              songs[playercontroller.playindex.value + 1].uri,
                              playercontroller.playindex.value + 1,
                              songs[playercontroller.playindex.value + 1]
                                  .title);
                        }
                      }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
