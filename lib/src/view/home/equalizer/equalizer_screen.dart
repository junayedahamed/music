import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music/src/controller/equalizer_controller.dart';
import 'package:music/src/controller/theme_controller.dart';
import 'package:music/src/view/home/equalizer/widgets/bass_boost_card.dart';
import 'package:music/src/view/home/equalizer/widgets/equalizer_header_card.dart';
import 'package:music/src/view/home/equalizer/widgets/frequency_bands_display.dart';
import 'package:music/src/view/home/equalizer/widgets/genre_presets_grid.dart';
import 'package:music/src/view/home/equalizer/widgets/headphone_status_banner.dart';

class EqualizerScreen extends StatelessWidget {
  const EqualizerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eqController = Get.put(EqualizerController());
    final themeController = Get.put(ThemeController());

    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final scaffoldBg = themeController.scaffoldBg;
      final textPrimary = themeController.textPrimary;
      final borderColor = themeController.borderColor;
      final accentBlue = themeController.accentBlue;
      final accentGreen = themeController.accentGreen;
      final cardBg = themeController.cardBg;
      final textSecondary = themeController.textSecondary;
      final isPlugged = eqController.isHeadphonePlugged.value;

      return Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          backgroundColor: scaffoldBg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: textPrimary, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            "Bass & Equalizer Studio",
            style: GoogleFonts.acme(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isPlugged
                        ? accentBlue.withValues(alpha: 0.15)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : const Color(0xfff3f4f8)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isPlugged
                          ? accentBlue.withValues(alpha: 0.5)
                          : borderColor,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPlugged
                            ? Icons.headphones_rounded
                            : Icons.headset_off_rounded,
                        color: isPlugged
                            ? accentBlue
                            : const Color(0xffffb74d),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isPlugged ? "Active" : "Disabled",
                        style: TextStyle(
                          color: isPlugged
                              ? accentBlue
                              : const Color(0xffffb74d),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            EqualizerHeaderCard(
              cardBg: cardBg,
              borderColor: borderColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              accentBlue: accentBlue,
              accentGreen: accentGreen,
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            HeadphoneStatusBanner(
              eqController: eqController,
              themeController: themeController,
            ),
            const SizedBox(height: 24),
            GenrePresetsGrid(
              eqController: eqController,
              themeController: themeController,
            ),
            const SizedBox(height: 24),
            BassBoostCard(
              eqController: eqController,
              themeController: themeController,
            ),
            const SizedBox(height: 24),
            FrequencyBandsDisplay(
              eqController: eqController,
              themeController: themeController,
            ),
          ],
        ),
      );
    });
  }
}
