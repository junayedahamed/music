import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:music/app.dart';
import 'package:music/src/services/music_audio_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize native background AudioService single instance before runApp()
  final audioHandler = await AudioService.init(
    builder: () => MusicAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.music.audio',
      androidNotificationChannelName: 'Music Playback',
      androidNotificationOngoing: false,
      androidStopForegroundOnPause: true,
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidShowNotificationBadge: false,
      notificationColor: Color(0xff00b0ff),
    ),
  );

  // Register the single MusicAudioHandler in GetX dependency container
  Get.put<MusicAudioHandler>(audioHandler, permanent: true);

  await Hive.initFlutter();
  await Hive.openBox<Map>("music");
  runApp(const MyApp());
}
