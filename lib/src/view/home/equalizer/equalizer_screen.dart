import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:music/src/controller/equalizer_controller.dart';
import 'package:music/src/controller/theme_controller.dart';

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
            // Live status pill in AppBar
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
            // Header Graphic Card
            _buildHeaderGraphic(context, eqController, themeController),

            const SizedBox(height: 16),

            // Headphone Status Alert Banner
            _buildHeadphoneBanner(context, eqController, themeController),

            const SizedBox(height: 24),

            // Sound Preset Profiles (Jazz, Rock, Pop, etc.)
            _buildPresetsSection(context, eqController, themeController),

            const SizedBox(height: 24),

            // Bass Boost Controller
            _buildBassBoostSection(context, eqController, themeController),

            const SizedBox(height: 24),

            // 5-Band Equalizer Frequency Display
            _buildEqualizerBandsSection(context, eqController, themeController),
          ],
        ),
      );
    });
  }

  Widget _buildHeaderGraphic(
    BuildContext context,
    EqualizerController eqController,
    ThemeController themeController,
  ) {
    final cardBg = themeController.cardBg;
    final textPrimary = themeController.textPrimary;
    final textSecondary = themeController.textSecondary;
    final borderColor = themeController.borderColor;
    final accentBlue = themeController.accentBlue;
    final accentGreen = themeController.accentGreen;
    final isDark = themeController.isDarkMode.value;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildEqBar(28, accentBlue),
              const SizedBox(width: 6),
              _buildEqBar(44, accentBlue),
              const SizedBox(width: 6),
              _buildEqBar(62, accentGreen),
              const SizedBox(width: 6),
              _buildEqBar(50, accentGreen),
              const SizedBox(width: 6),
              _buildEqBar(34, accentBlue),
              const SizedBox(width: 6),
              _buildEqBar(56, accentBlue),
              const SizedBox(width: 6),
              _buildEqBar(40, accentGreen),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            "Hardware Sound Engine",
            style: GoogleFonts.acme(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            "Real-time Android Equalizer & Bass Controller",
            style: TextStyle(
              fontSize: 12,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEqBar(double height, Color color) {
    return Container(
      width: 7,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildHeadphoneBanner(
    BuildContext context,
    EqualizerController eqController,
    ThemeController themeController,
  ) {
    return Obx(() {
      final isPlugged = eqController.isHeadphonePlugged.value;
      final hasNative = eqController.hasNativeSupport.value;
      final textSecondary = themeController.textSecondary;
      final accentBlue = themeController.accentBlue;

      if (isPlugged) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: accentBlue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accentBlue.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: accentBlue, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Earphones Connected (Active)",
                      style: TextStyle(
                        color: accentBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                    Text(
                      "Sound profiles and Bass Boost are enabled.",
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => eqController.toggleHeadphoneOverride(),
                child: Text(
                  "Disable",
                  style: TextStyle(
                    color: textSecondary.withValues(alpha: 0.8),
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xffffb74d).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xffffb74d).withValues(alpha: 0.45),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lock_rounded,
                    color: Color(0xffffb74d), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Earphones Not Detected",
                        style: TextStyle(
                          color: Color(0xffffb74d),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        !hasNative
                            ? "App was started with previous build: native Kotlin channels require running 'flutter run' to install on device. Tap 'Enable Override' below to test immediately!"
                            : "Plug in wired 3.5mm, USB-C, or Bluetooth earphones to activate the hardware equalizer.",
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => eqController.toggleHeadphoneOverride(),
                icon: const Icon(Icons.headphones_rounded,
                    size: 16, color: Colors.black),
                label: const Text(
                  "Enable Override (Test Mode)",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffffb74d),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPresetsSection(
    BuildContext context,
    EqualizerController eqController,
    ThemeController themeController,
  ) {
    final presetIcons = <String, IconData>{
      "Normal": Icons.music_note_rounded,
      "Jazz": Icons.nightlife_rounded,
      "Rock": Icons.electric_bolt_rounded,
      "Pop": Icons.mic_external_on_rounded,
      "Classical": Icons.piano_rounded,
      "Bass Boost": Icons.speaker_group_rounded,
    };

    final cardBg = themeController.cardBg;
    final textPrimary = themeController.textPrimary;
    final textSecondary = themeController.textSecondary;
    final borderColor = themeController.borderColor;
    final accentBlue = themeController.accentBlue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.tune_rounded, color: accentBlue, size: 20),
            const SizedBox(width: 8),
            Text(
              "Genre Sound Profiles",
              style: GoogleFonts.acme(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Switch equalizer tone based on music genre",
          style: TextStyle(
            fontSize: 12,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 14),

        Obx(() {
          final isPlugged = eqController.isHeadphonePlugged.value;
          final activePreset = eqController.currentPreset.value;

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: eqController.presets.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.3,
            ),
            itemBuilder: (context, index) {
              final preset = eqController.presets[index];
              final isSelected =
                  activePreset.toLowerCase() == preset.toLowerCase();
              final icon = presetIcons[preset] ?? Icons.music_note_rounded;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    if (!isPlugged) {
                      HapticFeedback.heavyImpact();
                      Get.snackbar(
                        "Headphones Required",
                        "Plug in earphones to activate '$preset' preset.",
                        backgroundColor: cardBg,
                        colorText: textPrimary,
                        icon: const Icon(Icons.headset_off_rounded,
                            color: Color(0xffffb74d)),
                        duration: const Duration(seconds: 2),
                      );
                      return;
                    }
                    HapticFeedback.selectionClick();
                    eqController.setPreset(preset);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isPlugged
                          ? (isSelected
                              ? accentBlue.withValues(alpha: 0.18)
                              : cardBg)
                          : cardBg.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isPlugged
                            ? (isSelected ? accentBlue : borderColor)
                            : borderColor.withValues(alpha: 0.4),
                        width: isSelected ? 1.8 : 1.0,
                      ),
                      boxShadow: isPlugged && isSelected
                          ? [
                              BoxShadow(
                                color: accentBlue.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: isPlugged && isSelected
                                ? accentBlue
                                : themeController.cardAltBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isPlugged ? icon : Icons.lock_outline_rounded,
                            size: 18,
                            color: isPlugged
                                ? (isSelected ? Colors.white : textSecondary)
                                : textSecondary.withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            preset,
                            style: TextStyle(
                              color: isPlugged
                                  ? (isSelected ? accentBlue : textPrimary)
                                  : textSecondary.withValues(alpha: 0.5),
                              fontSize: 13.5,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (isPlugged && isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: accentBlue,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildBassBoostSection(
    BuildContext context,
    EqualizerController eqController,
    ThemeController themeController,
  ) {
    final cardBg = themeController.cardBg;
    final textPrimary = themeController.textPrimary;
    final textSecondary = themeController.textSecondary;
    final borderColor = themeController.borderColor;
    final accentBlue = themeController.accentBlue;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Obx(() {
        final isPlugged = eqController.isHeadphonePlugged.value;
        final bassVal = eqController.bassLevel.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isPlugged
                            ? accentBlue.withValues(alpha: 0.15)
                            : themeController.cardAltBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.surround_sound_rounded,
                        color: isPlugged ? accentBlue : textSecondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Deep Bass Boost",
                          style: GoogleFonts.acme(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isPlugged
                                ? textPrimary
                                : textSecondary.withValues(alpha: 0.5),
                          ),
                        ),
                        Text(
                          "Low-frequency sub-bass amplifier",
                          style: TextStyle(
                            fontSize: 11,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPlugged
                        ? accentBlue.withValues(alpha: 0.15)
                        : themeController.cardAltBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${(bassVal * 100).toInt()}%",
                    style: TextStyle(
                      color: isPlugged ? accentBlue : textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbColor: isPlugged ? accentBlue : Colors.grey,
                activeTrackColor: isPlugged
                    ? accentBlue
                    : borderColor.withValues(alpha: 0.4),
                inactiveTrackColor: borderColor,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayColor: accentBlue.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: isPlugged ? bassVal : 0.0,
                onChanged: isPlugged
                    ? (newVal) => eqController.setBass(newVal)
                    : null,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEqualizerBandsSection(
    BuildContext context,
    EqualizerController eqController,
    ThemeController themeController,
  ) {
    final bands = [
      {"label": "60 Hz", "sub": "Bass"},
      {"label": "230 Hz", "sub": "Low-Mid"},
      {"label": "910 Hz", "sub": "Mid"},
      {"label": "3.6 kHz", "sub": "High-Mid"},
      {"label": "14 kHz", "sub": "Treble"},
    ];

    final cardBg = themeController.cardBg;
    final textPrimary = themeController.textPrimary;
    final textSecondary = themeController.textSecondary;
    final borderColor = themeController.borderColor;
    final accentGreen = themeController.accentGreen;
    final accentBlue = themeController.accentBlue;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Obx(() {
        final isPlugged = eqController.isHeadphonePlugged.value;
        final preset = eqController.currentPreset.value.toLowerCase();

        List<double> levels;
        switch (preset) {
          case "rock":
            levels = [0.7, 0.4, -0.2, 0.5, 0.8];
            break;
          case "jazz":
            levels = [0.4, 0.2, 0.0, 0.3, 0.5];
            break;
          case "pop":
            levels = [-0.2, 0.3, 0.6, 0.3, -0.2];
            break;
          case "classical":
            levels = [0.5, 0.3, -0.2, 0.4, 0.6];
            break;
          case "bass boost":
            levels = [0.95, 0.7, 0.1, 0.0, 0.1];
            break;
          default:
            levels = [0.0, 0.0, 0.0, 0.0, 0.0];
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.graphic_eq_rounded,
                    color: accentGreen, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Frequency Response Curve",
                  style: GoogleFonts.acme(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isPlugged
                        ? textPrimary
                        : textSecondary.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(bands.length, (i) {
                final band = bands[i];
                final level = isPlugged ? levels[i] : 0.0;
                final barHeight = 40.0 + (level * 25.0);

                return Column(
                  children: [
                    Text(
                      "${(level * 12).toInt()} dB",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isPlugged
                            ? (level > 0 ? accentGreen : textSecondary)
                            : textSecondary.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 14,
                      height: 90,
                      decoration: BoxDecoration(
                        color: themeController.cardAltBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 14,
                        height: barHeight.clamp(8.0, 90.0),
                        decoration: BoxDecoration(
                          color: isPlugged
                              ? accentBlue
                              : textSecondary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: isPlugged
                              ? [
                                  BoxShadow(
                                    color: accentBlue.withValues(alpha: 0.5),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      band["label"]!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isPlugged
                            ? textPrimary
                            : textSecondary.withValues(alpha: 0.4),
                      ),
                    ),
                    Text(
                      band["sub"]!,
                      style: TextStyle(
                        fontSize: 9,
                        color: textSecondary.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        );
      }),
    );
  }
}
