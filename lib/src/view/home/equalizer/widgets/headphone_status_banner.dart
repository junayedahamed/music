import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music/src/controller/equalizer_controller.dart';
import 'package:music/src/controller/theme_controller.dart';

class HeadphoneStatusBanner extends StatelessWidget {
  final EqualizerController eqController;
  final ThemeController themeController;

  const HeadphoneStatusBanner({
    super.key,
    required this.eqController,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
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
}
