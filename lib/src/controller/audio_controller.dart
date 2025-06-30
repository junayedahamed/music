import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

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
  String? songUri;
  var loading = true.obs;
  var max = 0.0.obs;
  var value = 0.0.obs;
  var duration = "".obs;
  var position = "".obs;
  var songname = "Please select a song to play".obs;
  var musicCacheBox = Hive.box<Map>("music");
  @override
  void onInit() {
    checkAndRequestPermission();
    var alldata = musicCacheBox.get("data");
    if (alldata != null) {
      log("message");
      isplaying.value = alldata["isplaying"];
      playindex.value = alldata["playIndex"];
      songname.value = alldata["songName"];
      max.value = alldata['max'];
      value.value = alldata["value"];
      duration.value = alldata["duration"];
      position.value = alldata["position"];
      songUri = alldata["songUri"];
    } else {
      log(alldata.toString());
    }
    super.onInit();
  }

  @override
  void dispose() async {
    log("message");
    final data = {
      "isplaying": isplaying.value,
      "playIndex": playindex.value,
      "songName": songname.value,
      "max": max.value,
      "value": value.value,
      "duration": duration.value,
      "position": position.value,
      "songUri": songUri,
    };
    await musicCacheBox.clear();
    musicCacheBox.put("data", data);
    super.dispose();
  }

  void updatePosition() {
    player.durationStream.listen((d) {
      duration.value = d.toString().split(".")[0];
      max.value = d!.inSeconds.toDouble();
    });

    player.positionStream.listen((p) {
      position.value = p.toString().split(".")[0];
      value.value = p.inSeconds.toDouble();
      if (duration.value == position.value) {
        isplaying.value = false;
        // Future.delayed(Duration(seconds: 1));
        if (playindex.value < _allSong.length) {
          playaudio(_allSong[playindex.value + 1].uri, playindex.value + 1,
              _allSong[playindex.value + 1].title);
        } else {
          return;
        }
      }
    });
  }

  void changedurationToseconds(int seconds) {
    var duration = Duration(seconds: seconds);
    player.seek(duration);
  }

  Future<void> playaudio(String? uri, int index, String title) async {
    // log(playindex.value.toString() + _allSong.length.toString());
    try {
      songUri = uri!;
      final mediaitem = MediaItem(
        id: uri,
        title: title,
      );
      final audioSource = AudioSource.uri(
        Uri.parse(mediaitem.id),
        tag: mediaitem,
      );
      await player.setAudioSource(audioSource);
      songname.value = mediaitem.title;
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

  void pause() async {
    log(isplaying.value.toString());
    if (isplaying.value) {
      player.pause();

      isplaying.value = false;
    } else {
      // log(songUri.toString());
      // playaudio(songUri, playindex.value, songname.value);
      player.play();
      isplaying.value = true;
      // update();
      // // updatePosition();
    }
  }

  Future<void> checkAndRequestPermission() async {
    // Android 13+ (API 33+)
    if (await Permission.audio.isDenied ||
        await Permission.audio.isPermanentlyDenied) {
      await Permission.audio.request();
      // return false;
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

      // return true;
    } else {
      // setState(() => _status = "Permission denied ❌");
      checkAndRequestPermission();
      // return false;
    }
  }

  void playnext() {
    if (playindex.value < _allSong.length) {
      playaudio(_allSong[playindex.value + 1].uri, playindex.value + 1,
          _allSong[playindex.value + 1].title);
    } else {
      return;
    }
  }

  void playprevious() {
    if (playindex.value > 0) {
      playaudio(_allSong[playindex.value - 1].uri, playindex.value - 1,
          _allSong[playindex.value - 1].title);
    } else {
      return;
    }
  }

//TODO sorting
  void sorting(dynamic value) {
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
