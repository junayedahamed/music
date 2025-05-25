import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:music/src/controller/audio_controller.dart';
import 'package:music/src/view/home/home_view.dart';

class SplashScreenMusic extends StatefulWidget {
  const SplashScreenMusic({super.key});

  @override
  State<SplashScreenMusic> createState() => _SplashScreenMusicState();
}

class _SplashScreenMusicState extends State<SplashScreenMusic> {
  final PlayerController _controller = PlayerController();

  @override
  void initState() {
    _controller.checkAndRequestPermission().then((onValue) {
      _navigate();
    });
    // status.then((onValue) {
    //   log(onValue.toString());
    // });
    super.initState();
  }

  void _navigate() async {
    await Future.delayed(Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => HomePage(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          'assets/music_welcome.json',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
