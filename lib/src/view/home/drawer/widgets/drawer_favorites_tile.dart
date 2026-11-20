import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music/src/controller/favorite_controller.dart';
import 'package:music/src/controller/theme_controller.dart';
import 'package:music/src/view/home/favorites/favorites_screen.dart';

class DrawerFavoritesTile extends StatelessWidget {
  final FavoriteController favController;
  final ThemeController themeController;

  const DrawerFavoritesTile({
    super.key,
    required this.favController,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final cardBg = themeController.cardBg;
      final textPrimary = themeController.textPrimary;
      final textSecondary = themeController.textSecondary;
      final count = favController.favoriteIds.length;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "FAVORITES",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textSecondary.withValues(alpha: 0.6),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.of(context).pop();
                Get.to(() => const FavoritesScreen());
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xffff4081).withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xffff4081), Color(0xfff50057)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xffff4081).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Favorite Songs",
                            style: GoogleFonts.acme(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            count > 0
                                ? "$count liked tracks • Tap to view"
                                : "No favorites yet",
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xffff4081),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: textSecondary.withValues(alpha: 0.5), size: 14),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
