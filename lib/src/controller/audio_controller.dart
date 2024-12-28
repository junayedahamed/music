import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class PlayerController extends GetxController {
  final audioQuery = OnAudioQuery();
  final player = AudioPlayer();
  var playindex = 0.obs;
  var isplaying = false.obs;
  // get plindex => _playindex;
  // get isplaying => _isplaying;
  @override
  void onInit() {
    super.onInit();
    checkPermission();
  }

  playaudio(String? uri, index) async {
    playindex = RxInt(index);
    try {
      await player.setAudioSource(AudioSource.uri(
        Uri.parse(uri!),
      ));
      player.play();
      isplaying.value = true;
      update();
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
