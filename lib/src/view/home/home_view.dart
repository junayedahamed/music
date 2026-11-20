import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:music/src/controller/audio_controller.dart';
import 'package:music/src/controller/home_selection_controller.dart';
import 'package:music/src/controller/theme_controller.dart';
import 'package:music/src/view/home/bottom_muisic_view/bottom_music_view.dart';

export 'package:music/src/utils/custom_order.dart';
import 'package:music/src/view/home/drawer/app_drawer.dart';
import 'package:music/src/view/home/widgets/alphabet_preview_overlay.dart';
import 'package:music/src/view/home/widgets/alphabet_scroll_helper.dart';
import 'package:music/src/view/home/widgets/exit_confirmation_dialog.dart';
import 'package:music/src/view/home/widgets/home_alphabet_sidebar.dart';
import 'package:music/src/view/home/widgets/home_app_bar.dart';
import 'package:music/src/view/home/widgets/home_empty_view.dart';
import 'package:music/src/view/music%20tile/music_listtile.dart';
import 'package:music/src/view/widgets/delete_song_dialog.dart';
import 'package:on_audio_query/on_audio_query.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PlayerController contoller = Get.put(PlayerController());
  final HomeSelectionController selController =
      Get.put(HomeSelectionController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() => AlphabetScrollHelper.onScroll(
        scrollController: _scrollController,
        selController: selController,
        songs: contoller.allsongs,
      );

  void _scrollToLetter(String letter) => AlphabetScrollHelper.scrollToLetter(
        letter: letter,
        scrollController: _scrollController,
        songs: contoller.allsongs,
      );

  void _shareSelectedSongs() {
    final toShare = contoller.allsongs
        .where((s) => selController.selectedSongIds.contains(s.id))
        .toList();
    if (toShare.isNotEmpty) {
      HapticFeedback.lightImpact();
      contoller.shareSongs(toShare);
    }
  }

  void _confirmDeleteSelectedSongs() {
    final toDelete = contoller.allsongs
        .where((s) => selController.selectedSongIds.contains(s.id))
        .toList();
    if (toDelete.isEmpty) return;
    DeleteSongDialog.show(
      context: context,
      title: "Delete ${toDelete.length} Songs?",
      message:
          "Are you sure you want to permanently delete ${toDelete.length} selected song(s)?",
      songsToDelete: toDelete,
      onDeleted: () => selController.removeSongs(toDelete.map((s) => s.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.put(ThemeController());

    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final scaffoldBg = themeController.scaffoldBg;
      final cardBg = themeController.cardBg;
      final textPrimary = themeController.textPrimary;
      final textSecondary = themeController.textSecondary;
      final accentGreen = themeController.accentGreen;
      final accentBlue = themeController.accentBlue;

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          if (selController.isSelectionMode) {
            selController.clearSelection();
            return;
          }
          final shouldExit = await ExitConfirmationDialog.show(
            context,
            cardBg: cardBg,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            accentGreen: accentGreen,
          );
          if (shouldExit == true) SystemNavigator.pop();
        },
        child: Scaffold(
          drawer: const AppDrawer(),
          backgroundColor: scaffoldBg,
          body: Obx(() {
            if (contoller.loading.value) {
              return Center(
                  child: CircularProgressIndicator(color: accentGreen));
            }
            if (contoller.allsongs.isEmpty) {
              return HomeEmptyView(
                textSecondary: textSecondary,
                accentGreen: accentGreen,
                onRefresh: () => contoller.checkAndRequestPermission(),
              );
            }
            if (selController.activeLetter.value == null) {
              selController.setActiveLetter(AlphabetScrollHelper.getLetter(
                  contoller.allsongs.first.title));
            }

            return Stack(
              children: [
                CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    HomeAppBar(
                      selectionController: selController,
                      playerController: contoller,
                      scaffoldBg: scaffoldBg,
                      textPrimary: textPrimary,
                      accentBlue: accentBlue,
                      accentGreen: accentGreen,
                      onShareSelected: _shareSelectedSongs,
                      onDeleteSelected: _confirmDeleteSelectedSongs,
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final song = contoller.allsongs[index];

                          return Obx(() {
                            final isSelected =
                                selController.selectedSongIds.contains(song.id);
                            final isCurrent = contoller.hasActiveSong &&
                                contoller.songUri == song.uri;
                            final isPlaying =
                                isCurrent && contoller.isplaying.value;

                            return MusicListtile(
                              songUri: song.uri,
                              songId: song.id,
                              isCurrentSong: isCurrent,
                              isPlaying: isPlaying,
                              isSelectionMode: selController.isSelectionMode,
                              isSelected: isSelected,
                              leading: QueryArtworkWidget(
                                id: song.id,
                                type: ArtworkType.AUDIO,
                                nullArtworkWidget: Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.black54
                                        : const Color(0xffe2e8f0),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.music_note,
                                      color: textPrimary, size: 26),
                                ),
                              ),
                              onPressed: () {
                                if (selController.isSelectionMode) {
                                  selController.toggleSelectSong(song.id);
                                } else {
                                  contoller.playOrNavigate(
                                      song, index, contoller.allsongs);
                                }
                              },
                              onLongPress: () =>
                                  selController.toggleSelectSong(song.id),
                              onMenuShare: () => contoller.shareSongs([song]),
                              onMenuSelect: () =>
                                  selController.addSong(song.id),
                              onMenuDelete: () => DeleteSongDialog.show(
                                context: context,
                                title: "Delete Song?",
                                message:
                                    "Are you sure you want to permanently delete \"${song.title}\"?",
                                songsToDelete: [song],
                              ),
                              musicName: song.title,
                              artistName: song.artist ?? "Unknown Artist",
                              trailing:
                                  !selController.isSelectionMode && isPlaying
                                      ? Icon(Icons.play_arrow_rounded,
                                          size: 28, color: accentGreen)
                                      : null,
                            );
                          });
                        },
                        childCount: contoller.allsongs.length,
                      ),
                    ),
                  ],
                ),
                HomeAlphabetSidebar(
                  selController: selController,
                  isDark: isDark,
                  accentBlue: accentBlue,
                  onLetterSelected: _scrollToLetter,
                ),
                AlphabetPreviewOverlay(
                  showPreview: selController.showCenterPreview.value,
                  activeLetter: selController.activeLetter.value,
                  isDark: isDark,
                  cardBg: cardBg,
                  accentBlue: accentBlue,
                ),
              ],
            );
          }),
          bottomNavigationBar: BottomMusicView(songs: contoller.allsongs),
        ),
      );
    });
  }
}
