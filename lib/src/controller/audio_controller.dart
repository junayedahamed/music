import 'dart:developer';

import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music/src/view/home/home_view.dart';
import 'package:music/src/view/home/sort_song_by_order.dart';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class PlayerController extends GetxController {
  final audioQuery = OnAudioQuery();
  final SortSongByOrder sort = SortSongByOrder();
  List<SongModel> _allSong = [];
  List<SongModel> _allSongcp = [];
  final player = AudioPlayer();
  var playindex = 0.obs;
  var isplaying = false.obs;
  var loading = true.obs;
  var max = 0.0.obs;
  var value = 0.0.obs;
  var duration = "".obs;
  var position = "".obs;
  var songname = "Please select a song to play".obs;
  @override
  void onInit() {
    checkAndRequestPermission();
    super.onInit();
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
        if (playindex.value < _allSong.length) {
          playaudio(_allSong[playindex.value + 1].uri, playindex.value + 1,
              _allSong[playindex.value + 1].title);
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
    log(playindex.value.toString() + _allSong.length.toString());
    try {
      await player.setAudioSource(AudioSource.uri(
        Uri.parse(uri!),
      ));
      songname.value = title;
      playindex.value = index;
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

  // checkPermission() async {
  //   var permission = await Permission.storage.request();
  //   if (permission.isGranted) {
  //     // allSong = await audioQuery.querySongs(
  //     //   ignoreCase: true,
  //     //   orderType: sort.order,
  //     //   sortType: null,
  //     //   uriType: UriType.EXTERNAL,
  //     // );
  //   } else {
  //     checkPermission();
  //   }
  // }

  Future<void> checkAndRequestPermission() async {
    // Android 13+ (API 33+)
    if (await Permission.audio.isDenied ||
        await Permission.audio.isPermanentlyDenied) {
      await Permission.audio.request();
    }

    // Also check for storage permission for older Android versions
    await [
      Permission.storage,
      Permission.mediaLibrary,
    ].request();

    if (await Permission.storage.isGranted ||
        await Permission.audio.isGranted) {
      _allSong = await audioQuery.querySongs(
        ignoreCase: true,
        orderType: sort.order,
        sortType: null,
        uriType: UriType.EXTERNAL,
      );
      loading.value = false;
      // setState(() => _status = "Permission granted ✅");
    } else {
      // setState(() => _status = "Permission denied ❌");
      checkAndRequestPermission();
    }
  }

//TODO sorting
  sorting(value) {
    if (value == Customorder.ztoa) {
      _allSongcp.addAll(_allSong);
      _allSong.reversed;
    } else {
      if (_allSongcp.isEmpty) {
        _allSong;
      } else {
        _allSong.reversed;
      }
    }
  }

  List<SongModel> get allsongs => _allSong;
}
