import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: "com.example.music",
    androidNotificationChannelName: 'JMusic',
    androidNotificationOngoing: false,
    androidShowNotificationBadge: false,
    androidStopForegroundOnPause: false,
    notificationColor: const Color(0xff00b0ff),
    preloadArtwork: true,
  );
  await Hive.initFlutter();
  await Hive.openBox<Map>("music");
  runApp(const MyApp());
}
