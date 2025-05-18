import 'dart:developer';

import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music/src/view/home/sort_song_by_order.dart';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class PlayerController extends GetxController {
  final audioQuery = OnAudioQuery();
  final SortSongByOrder sort = SortSongByOrder();
  // final playercontroller = Get.find<PlayerController>();
  List<SongModel> allSong = [];
  final player = AudioPlayer();
  var playindex = 0.obs;
  var isplaying = false.obs;
  var max = 0.0.obs;
  var value = 0.0.obs;
  var duration = "".obs;
  var position = "".obs;
  var songname = "Please select a song to play".obs;
  @override
  void onInit() async {
    super.onInit();
    allSong = await audioQuery.querySongs(
      ignoreCase: true,
      orderType: sort.order,
      sortType: null,
      uriType: UriType.EXTERNAL,
    );
    checkPermission();
  }

  updatePosition() {
    player.durationStream.listen((d) {
      duration.value = d.toString().split(".")[0];
      max.value = d!.inSeconds.toDouble();
    });

    player.positionStream.listen((p) {
      position.value = p.toString().split(".")[0];
      value.value = p.inSeconds.toDouble();
      if (duration.value == position.value) {
        isplaying.value = false;
        if (playindex.value < allSong.length) {
          playaudio(allSong[playindex.value + 1].uri, playindex.value + 1,
              allSong[playindex.value + 1].title);
        } else {
          return;
        }
      }
    });
  }

  changedurationToseconds(seconds) {
    var duration = Duration(seconds: seconds);
    player.seek(duration);
  }

  playaudio(String? uri, index, String title) async {
    playindex.value = index;
    log(playindex.value.toString() + allSong.length.toString());
    try {
      await player.setAudioSource(AudioSource.uri(
        Uri.parse(uri!),
      ));
      songname.value = title;
      player.play();
      isplaying.value = true;
      update();
      updatePosition();

      // log("hi");
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  pause() {
    if (isplaying.value) {
      player.pause();

      isplaying.value = false;
    } else {
      player.play();
      isplaying.value = true;
    }
  }

  checkPermission() async {
    var permission = await Permission.storage.request();
    if (permission.isGranted) {
    } else {
      checkPermission();
    }
  }
}
