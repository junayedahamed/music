import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class ThemeController extends GetxController {
  final isDarkMode = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  void _loadTheme() {
    try {
      final box = Hive.box<Map>("music");
      final saved = box.get("theme_prefs");
      if (saved != null && saved["isDark"] != null) {
        isDarkMode.value = saved["isDark"] as bool;
      }
    } catch (_) {}
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    try {
      final box = Hive.box<Map>("music");
      box.put("theme_prefs", {"isDark": isDarkMode.value});
    } catch (_) {}
  }

  // Adaptive theme colors
  Color get scaffoldBg =>
      isDarkMode.value ? const Color(0xff070B11) : const Color(0xfff3f4f8);

  Color get cardBg =>
      isDarkMode.value ? const Color(0xff1f212c) : Colors.white;

  Color get cardAltBg =>
      isDarkMode.value ? const Color(0xff161822) : const Color(0xffe8ebf2);

  Color get textPrimary =>
      isDarkMode.value ? Colors.white : const Color(0xff111827);

  Color get textSecondary =>
      isDarkMode.value ? Colors.white70 : const Color(0xff4b5563);

  Color get textTertiary =>
      isDarkMode.value ? Colors.white38 : const Color(0xff9ca3af);

  Color get borderColor => isDarkMode.value
      ? Colors.white.withValues(alpha: 0.1)
      : const Color(0xffe5e7eb);

  Color get accentBlue => const Color(0xff00b0ff);

  Color get accentGreen =>
      isDarkMode.value ? const Color(0xff60E95D) : const Color(0xff10b981);
}
