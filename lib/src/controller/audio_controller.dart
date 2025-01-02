import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class PlayerController extends GetxController {
  final audioQuery = OnAudioQuery();
  final player = AudioPlayer();
  var playindex = 0.obs;
  var isplaying = false.obs;
  var max = 0.0.obs;
  var value = 0.0.obs;
  var duration = "".obs;
  var position = "".obs;
  @override
  void onInit() {
    super.onInit();
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
    });
  }

  changedurationToseconds(seconds) {
    var duration = Duration(seconds: seconds);
    player.seek(duration);
  }

  playaudio(String? uri, index) async {
    playindex.value = index;
    try {
      await player.setAudioSource(AudioSource.uri(
        Uri.parse(uri!),
      ));
      player.play();
      isplaying.value = true;
      update();
      updatePosition();
    } on Exception catch (e) {
      print(e);
      // throw Exception(e);
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
