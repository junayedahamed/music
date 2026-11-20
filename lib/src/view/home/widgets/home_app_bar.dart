import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music/src/controller/audio_controller.dart';
import 'package:music/src/controller/home_selection_controller.dart';
import 'package:music/src/view/home/search_song.dart';

class HomeAppBar extends StatelessWidget {
  final HomeSelectionController selectionController;
  final PlayerController playerController;
  final Color scaffoldBg;
  final Color textPrimary;
  final Color accentBlue;
  final Color accentGreen;
  final VoidCallback onShareSelected;
  final VoidCallback onDeleteSelected;

  const HomeAppBar({
    super.key,
    required this.selectionController,
    required this.playerController,
    required this.scaffoldBg,
    required this.textPrimary,
    required this.accentBlue,
    required this.accentGreen,
    required this.onShareSelected,
    required this.onDeleteSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelectionMode = selectionController.isSelectionMode;
    final selectedCount = selectionController.selectedSongIds.length;
    final totalSongs = playerController.allsongs.length;
    final isAllSelected = selectedCount == totalSongs;

    return SliverAppBar(
      backgroundColor: scaffoldBg,
      pinned: true,
      surfaceTintColor: scaffoldBg,
      floating: true,
      automaticallyImplyLeading: false,
      elevation: 0,
      centerTitle: false,
      leading: isSelectionMode
          ? IconButton(
              icon: Icon(Icons.close_rounded, color: textPrimary, size: 24),
              onPressed: selectionController.clearSelection,
            )
          : Builder(
              builder: (ctx) => IconButton(
                icon: Icon(Icons.menu_rounded, color: textPrimary, size: 26),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
      title: Text(
        isSelectionMode ? "$selectedCount Selected" : "Music Player",
        style: GoogleFonts.acme(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: isSelectionMode ? accentBlue : accentGreen,
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        if (isSelectionMode) ...[
          IconButton(
            tooltip: isAllSelected ? "Deselect All" : "Select All",
            icon: Icon(
              isAllSelected ? Icons.deselect_rounded : Icons.select_all_rounded,
              color: textPrimary,
            ),
            onPressed: () => selectionController
                .selectAll(playerController.allsongs.map((s) => s.id)),
          ),
          IconButton(
            tooltip: "Share Selected",
            icon: Icon(Icons.share_rounded, color: accentBlue),
            onPressed: onShareSelected,
          ),
          IconButton(
            tooltip: "Delete Selected",
            icon: const Icon(Icons.delete_forever_rounded,
                color: Colors.redAccent),
            onPressed: onDeleteSelected,
          ),
        ] else ...[
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: SearchSong(playerController.allsongs),
              );
            },
            icon: Icon(Icons.search, color: textPrimary),
          ),
        ],
      ],
    );
  }
}
