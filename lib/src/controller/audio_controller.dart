import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class PlayerController extends GetxController {
  final audioQuery = OnAudioQuery();
  final player = AudioPlayer();

  @override
  void onInit() {
    super.onInit();
    checkPermission();
  }

  playaudio(String? uri) async {
    try {
      await player.setAudioSource(AudioSource.uri(
        Uri.parse(uri!),
      ));
      player.play();
    } on Exception catch (e) {
      print(e);
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
