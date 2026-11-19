import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music/src/controller/theme_controller.dart';
import 'package:music/src/view/welcome_splash_screen/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.put(ThemeController(), permanent: true);

    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xff070B11),
      canvasColor: const Color(0xff070B11),
      cardColor: const Color(0xff1f212c),
      dialogTheme: const DialogThemeData(
        backgroundColor: Color(0xff1f212c),
      ),
      fontFamily: "Regular",
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xff00b0ff),
        surface: Color(0xff070B11),
      ),
    );

    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xfff3f4f8),
      canvasColor: const Color(0xff070B11), // Keeps transition underlay dark
      cardColor: Colors.white,
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
      ),
      fontFamily: "Regular",
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      colorScheme: const ColorScheme.light(
        primary: Color(0xff0081cb),
        surface: Color(0xfff3f4f8),
      ),
    );

    return GetMaterialApp(
      title: 'Juna_Music',
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 150),
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode:
          themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreenMusic(),
    );
  }
}
