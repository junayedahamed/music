import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:music/src/controller/equalizer_controller.dart';
import 'package:music/src/controller/favorite_controller.dart';
import 'package:music/src/controller/playlist_controller.dart';
import 'package:music/src/controller/theme_controller.dart';
import 'package:music/src/view/home/equalizer/equalizer_screen.dart';
import 'package:music/src/view/home/favorites/favorites_screen.dart';
import 'package:music/src/view/home/playlist/create_playlist_screen.dart';
import 'package:music/src/view/home/playlist/playlist_detail_screen.dart';

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
              // Drawer Header with Theme Toggler
              _buildDrawerHeader(context, eqController, themeController),

              // Scrollable Navigation Items
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // 1. Dedicated Bass & Equalizer Tile
                    _buildEqualizerTile(
                        context, eqController, themeController),

                    const SizedBox(height: 18),
                    Divider(color: borderColor, height: 1),
                    const SizedBox(height: 16),

                    // 2. Favorites Tile
                    _buildFavoritesTile(
                        context, favController, themeController),

                    const SizedBox(height: 18),
                    Divider(color: borderColor, height: 1),
                    const SizedBox(height: 16),

                    // 3. Playlists Section
                    _buildPlaylistSection(
                        context, playlistController, themeController),

                    const SizedBox(height: 18),
                    Divider(color: borderColor, height: 1),
                    const SizedBox(height: 16),

                    // 4. Settings Section
                    _buildSettingsSection(context, themeController),
                  ],
                ),
              ),

              // Drawer Footer
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

  Widget _buildDrawerHeader(
    BuildContext context,
    EqualizerController eqController,
    ThemeController themeController,
  ) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final cardBg = themeController.cardBg;
      final textPrimary = themeController.textPrimary;
      final textSecondary = themeController.textSecondary;
      final borderColor = themeController.borderColor;
      final isPlugged = eqController.isHeadphonePlugged.value;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          border: Border(
            bottom: BorderSide(
              color: borderColor,
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // App Logo
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xff00b0ff), Color(0xff60E95D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff00b0ff).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.music_note_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),

                // App Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Music Player",
                        style: GoogleFonts.acme(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Audio Studio & Sound Engine",
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Theme Toggler Button (Adaptive Sun / Moon)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      themeController.toggleTheme();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xfff3f4f8),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.15)
                              : const Color(0xffd1d5db),
                          width: 1.2,
                        ),
                      ),
                      child: Icon(
                        isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        color: isDark
                            ? const Color(0xffffd54f)
                            : const Color(0xff374151),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Reactive Headphone Status Badge & Toggle
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                eqController.toggleHeadphoneOverride();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isPlugged
                      ? const Color(0xff00b0ff).withValues(alpha: 0.14)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : const Color(0xfff3f4f8)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isPlugged
                        ? const Color(0xff00b0ff).withValues(alpha: 0.5)
                        : borderColor,
                    width: 1,
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
                          ? const Color(0xff00b0ff)
                          : textSecondary.withValues(alpha: 0.7),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isPlugged
                          ? "Earphone Connected (Active)"
                          : "Earphone Disconnected (Tap to toggle)",
                      style: TextStyle(
                        color: isPlugged
                            ? const Color(0xff00b0ff)
                            : textSecondary,
                        fontSize: 11.5,
                        fontWeight:
                            isPlugged ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // Dedicated Equalizer Screen Tile
  Widget _buildEqualizerTile(
    BuildContext context,
    EqualizerController eqController,
    ThemeController themeController,
  ) {
    return Obx(() {
      final isPlugged = eqController.isHeadphonePlugged.value;
      final preset = eqController.currentPreset.value;
      final isDark = themeController.isDarkMode.value;
      final cardBg = themeController.cardBg;
      final textPrimary = themeController.textPrimary;
      final textSecondary = themeController.textSecondary;
      final borderColor = themeController.borderColor;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "AUDIO STUDIO",
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
                Navigator.of(context).pop(); // Close drawer
                Get.to(() => const EqualizerScreen());
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isPlugged
                        ? const Color(0xff00b0ff).withValues(alpha: 0.4)
                        : borderColor,
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
                        gradient: LinearGradient(
                          colors: isPlugged
                              ? [const Color(0xff00b0ff), const Color(0xff0081cb)]
                              : [
                                  isDark ? Colors.white24 : const Color(0xffd1d5db),
                                  isDark ? Colors.white10 : const Color(0xffe5e7eb)
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.equalizer_rounded,
                        color: isPlugged
                            ? Colors.black
                            : (isDark ? Colors.white60 : Colors.black54),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Bass & Equalizer",
                                style: GoogleFonts.acme(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (!isPlugged)
                                const Icon(Icons.lock_rounded,
                                    color: Color(0xffffb74d), size: 14),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isPlugged
                                ? "Active: $preset profile • Tap to adjust"
                                : "🔒 Tap to enable / plug in headphones",
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isPlugged
                                  ? const Color(0xff00b0ff)
                                  : const Color(0xffffb74d),
                              fontWeight: isPlugged
                                  ? FontWeight.w500
                                  : FontWeight.normal,
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

  Widget _buildFavoritesTile(
    BuildContext context,
    FavoriteController favController,
    ThemeController themeController,
  ) {
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
                            color:
                                const Color(0xffff4081).withValues(alpha: 0.3),
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

  Widget _buildPlaylistSection(
    BuildContext context,
    PlaylistController playlistController,
    ThemeController themeController,
  ) {
    return Obx(() {
      final cardBg = themeController.cardBg;
      final cardAltBg = themeController.cardAltBg;
      final textPrimary = themeController.textPrimary;
      final textSecondary = themeController.textSecondary;
      final borderColor = themeController.borderColor;
      final accentGreen = themeController.accentGreen;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "PLAYLISTS",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: textSecondary.withValues(alpha: 0.6),
                  letterSpacing: 1.0,
                ),
              ),
              GestureDetector(
                onTap: () => _showCreatePlaylistDialog(context, themeController),
                child: Row(
                  children: [
                    Icon(Icons.add_rounded, color: accentGreen, size: 16),
                    const SizedBox(width: 3),
                    Text(
                      "New",
                      style: TextStyle(
                        color: accentGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Create Playlist Action Card
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _showCreatePlaylistDialog(context, themeController),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accentGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.add_rounded,
                          color: accentGreen, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Create Own Playlist",
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Select songs from your device library",
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 11,
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

          // List of created playlists
          if (playlistController.playlists.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...playlistController.playlists.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.of(context).pop();
                      Get.to(() =>
                          PlaylistDetailScreen(playlistName: entry.key));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: cardAltBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.queue_music_rounded,
                              color: accentGreen, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "${entry.value.length} songs",
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline_rounded,
                                color: textSecondary.withValues(alpha: 0.6),
                                size: 18),
                            onPressed: () {
                              playlistController.deletePlaylist(entry.key);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ],
      );
    });
  }

  Widget _buildSettingsSection(
    BuildContext context,
    ThemeController themeController,
  ) {
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
            leading:
                Icon(Icons.tune_rounded, color: textSecondary, size: 20),
            title: Text(
              "Playback & Storage Settings",
              style: TextStyle(
                  color: textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              "Clear cache, audio engine status",
              style: TextStyle(color: textSecondary, fontSize: 11),
            ),
            trailing: Icon(Icons.arrow_forward_ios_rounded,
                color: textSecondary.withValues(alpha: 0.5), size: 14),
            onTap: () => _showSettingsBottomSheet(context, themeController),
          ),
        ],
      );
    });
  }

  void _showCreatePlaylistDialog(
      BuildContext context, ThemeController themeController) {
    final textController = TextEditingController();
    final cardBg = themeController.cardBg;
    final textPrimary = themeController.textPrimary;
    final textSecondary = themeController.textSecondary;
    final accentGreen = themeController.accentGreen;
    final isDark = themeController.isDarkMode.value;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(Icons.playlist_add_rounded, color: accentGreen),
            const SizedBox(width: 8),
            Text(
              "Create Playlist",
              style: GoogleFonts.acme(color: textPrimary, fontSize: 20),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter a name for your playlist. You will choose songs next.",
              style: TextStyle(
                color: textSecondary,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              autofocus: true,
              style: TextStyle(color: textPrimary),
              decoration: InputDecoration(
                hintText: "Playlist name (e.g. Chill Beats)",
                hintStyle:
                    TextStyle(color: textSecondary.withValues(alpha: 0.5)),
                filled: true,
                fillColor: isDark
                    ? const Color(0xff161822)
                    : const Color(0xfff3f4f8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: accentGreen, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("Cancel", style: TextStyle(color: textSecondary)),
          ),
          TextButton(
            onPressed: () {
              final name = textController.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
                Get.to(() => CreatePlaylistScreen(playlistName: name));
              }
            },
            child: Text("Next: Choose Songs",
                style: TextStyle(
                    color: accentGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSettingsBottomSheet(
      BuildContext context, ThemeController themeController) {
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
