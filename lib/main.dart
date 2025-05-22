import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music/app.dart';

void main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: "com.example.music",
    androidNotificationChannelName: 'JMusic',
    androidNotificationOngoing: true,
    androidShowNotificationBadge: false,
    androidStopForegroundOnPause: true,
    notificationColor: Colors.white,
    preloadArtwork: true,
  );
  runApp(const MyApp());
}
