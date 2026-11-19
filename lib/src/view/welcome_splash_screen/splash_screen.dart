import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:music/src/controller/audio_controller.dart';
import 'package:music/src/controller/theme_controller.dart';
import 'package:music/src/view/home/home_view.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreenMusic extends StatefulWidget {
  const SplashScreenMusic({super.key});

  @override
  State<SplashScreenMusic> createState() => _SplashScreenMusicState();
}

class _SplashScreenMusicState extends State<SplashScreenMusic> {
  late final PlayerController _controller;
  late final ThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = Get.put(ThemeController());
    _controller = Get.put(PlayerController());
    _permission();
  }

  Future<void> _permission() async {
    if (await Permission.audio.isDenied ||
        await Permission.audio.isPermanentlyDenied) {
      _controller.checkAndRequestPermission().then((onValue) {
        _navigate();
      });
    } else {
      _navigate();
    }
  }

  void _navigate() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const HomePage(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final scaffoldBg = _themeController.scaffoldBg;

      return Scaffold(
        backgroundColor: scaffoldBg,
        body: Center(
          child: Lottie.asset(
            'assets/music_welcome.json',
            fit: BoxFit.cover,
          ),
        ),
      );
    });
  }
}
