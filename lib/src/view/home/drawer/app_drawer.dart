import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music/src/controller/equalizer_controller.dart';
import 'package:music/src/controller/favorite_controller.dart';
import 'package:music/src/controller/playlist_controller.dart';
import 'package:music/src/controller/theme_controller.dart';
import 'package:music/src/view/home/drawer/widgets/drawer_equalizer_tile.dart';
import 'package:music/src/view/home/drawer/widgets/drawer_favorites_tile.dart';
import 'package:music/src/view/home/drawer/widgets/drawer_header_widget.dart';
import 'package:music/src/view/home/drawer/widgets/drawer_playlist_section.dart';
import 'package:music/src/view/home/drawer/widgets/drawer_settings_section.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final eqController = Get.put(EqualizerController());
    final playlistController = Get.put(PlaylistController());
    final themeController = Get.put(ThemeController());
    final favController = Get.put(FavoriteController());

    return Obx(() {
      final scaffoldBg = themeController.scaffoldBg;
      final textSecondary = themeController.textSecondary;
      final borderColor = themeController.borderColor;

      return Drawer(
        backgroundColor: scaffoldBg,
        child: SafeArea(
          child: Column(
            children: [
              DrawerHeaderWidget(
                eqController: eqController,
                themeController: themeController,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    DrawerEqualizerTile(
                      eqController: eqController,
                      themeController: themeController,
                    ),
                    const SizedBox(height: 18),
                    Divider(color: borderColor, height: 1),
                    const SizedBox(height: 16),
                    DrawerFavoritesTile(
                      favController: favController,
                      themeController: themeController,
                    ),
                    const SizedBox(height: 18),
                    Divider(color: borderColor, height: 1),
                    const SizedBox(height: 16),
                    DrawerPlaylistSection(
                      playlistController: playlistController,
                      themeController: themeController,
                    ),
                    const SizedBox(height: 18),
                    Divider(color: borderColor, height: 1),
                    const SizedBox(height: 16),
                    DrawerSettingsSection(
                      themeController: themeController,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12, top: 4),
                child: Text(
                  "Music Player v1.0 • Offline Studio",
                  style: TextStyle(
                    color: textSecondary.withValues(alpha: 0.5),
                    fontSize: 11,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
