import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:music/src/controller/theme_controller.dart';

class DrawerSettingsSection extends StatelessWidget {
  final ThemeController themeController;

  const DrawerSettingsSection({
    super.key,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cardBg = themeController.cardBg;
      final textPrimary = themeController.textPrimary;
      final textSecondary = themeController.textSecondary;
      final borderColor = themeController.borderColor;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "PREFERENCES",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textSecondary.withValues(alpha: 0.6),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: borderColor),
            ),
            tileColor: cardBg,
            leading: Icon(Icons.tune_rounded, color: textSecondary, size: 20),
            title: Text(
              "Playback & Storage Settings",
              style: TextStyle(
                  color: textPrimary, fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              "Clear cache, audio engine status",
              style: TextStyle(color: textSecondary, fontSize: 11),
            ),
            trailing: Icon(Icons.arrow_forward_ios_rounded,
                color: textSecondary.withValues(alpha: 0.5), size: 14),
            onTap: () => _showSettingsBottomSheet(context),
          ),
        ],
      );
    });
  }

  void _showSettingsBottomSheet(BuildContext context) {
    final cardBg = themeController.cardBg;
    final textPrimary = themeController.textPrimary;
    final textSecondary = themeController.textSecondary;
    final accentGreen = themeController.accentGreen;
    final borderColor = themeController.borderColor;

    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              "Settings & Cache",
              style: GoogleFonts.acme(
                fontSize: 22,
                color: textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.cleaning_services_rounded,
                  color: Color(0xff00b0ff)),
              title: Text("Clear Music Cache",
                  style: TextStyle(color: textPrimary, fontSize: 14)),
              subtitle: Text("Clears saved last-played state and cache",
                  style: TextStyle(color: textSecondary, fontSize: 11)),
              trailing: TextButton(
                onPressed: () async {
                  try {
                    final box = Hive.box<Map>("music");
                    await box.clear();
                    Get.back();
                    Get.snackbar(
                      "Cache Cleared",
                      "Music playback cache cleared successfully.",
                      backgroundColor: cardBg,
                      colorText: textPrimary,
                    );
                  } catch (_) {}
                },
                child: Text("Clear", style: TextStyle(color: accentGreen)),
              ),
            ),
            Divider(color: borderColor),
            ListTile(
              leading: Icon(Icons.info_outline_rounded, color: textSecondary),
              title: Text("About Engine",
                  style: TextStyle(color: textPrimary, fontSize: 14)),
              subtitle: Text(
                  "Flutter 3.50+ • Material UI • Hardware Equalizer Active",
                  style: TextStyle(color: textSecondary, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }
}
