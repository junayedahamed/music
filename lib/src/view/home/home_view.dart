import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:music/src/controller/audio_controller.dart';
import 'package:music/src/controller/theme_controller.dart';
import 'package:music/src/view/home/alphabet_scrollbar.dart';
import 'package:music/src/view/home/bottom_muisic_view/bottom_music_view.dart';
import 'package:music/src/view/home/drawer/app_drawer.dart';
import 'package:music/src/view/home/search_song.dart';
import 'package:music/src/view/music%20tile/music_listtile.dart';
import 'package:on_audio_query/on_audio_query.dart';

// Enum for sort by order
enum Customorder {
  atoz,
  ztoa,
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PlayerController contoller = Get.put(PlayerController());
  final ScrollController _scrollController = ScrollController();

  static const List<String> _alphabets = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
    '#'
  ];

  static const double _letterHeight = 18.0;

  String? _activeLetter;
  bool _isDraggingScrollbar = false;
  bool _showCenterPreview = false;

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

  void _onScroll() {
    if (_isDraggingScrollbar) return;
    final songs = contoller.allsongs;
    if (songs.isEmpty || !_scrollController.hasClients) return;

    const double itemHeight = 78.0;
    final double offset = _scrollController.offset;
    final int topIndex =
        (offset / itemHeight).floor().clamp(0, songs.length - 1);

    final currentLetter = _getLetterForSong(songs[topIndex].title);
    if (_activeLetter != currentLetter) {
      setState(() {
        _activeLetter = currentLetter;
      });
    }
  }

  String _getLetterForSong(String title) {
    final clean = title.trim();
    if (clean.isEmpty) return '#';
    final firstChar = clean[0].toUpperCase();
    if (RegExp(r'[A-Z]').hasMatch(firstChar)) {
      return firstChar;
    }
    return '#';
  }

  void _scrollToLetter(String letter) {
    final songs = contoller.allsongs;
    if (songs.isEmpty || !_scrollController.hasClients) return;

    final targetUpper = letter.toUpperCase();
    int targetIndex = -1;

    if (targetUpper == '#') {
      for (int i = 0; i < songs.length; i++) {
        final title = songs[i].title.trim();
        if (title.isNotEmpty && !RegExp(r'[a-zA-Z]').hasMatch(title[0])) {
          targetIndex = i;
          break;
        }
      }
    } else {
      for (int i = 0; i < songs.length; i++) {
        final title = songs[i].title.trim();
        if (title.isNotEmpty) {
          final firstChar = title[0].toUpperCase();
          if (RegExp(r'[A-Z]').hasMatch(firstChar)) {
            if (firstChar.compareTo(targetUpper) >= 0) {
              targetIndex = i;
              break;
            }
          } else {
            // Reached non-letters ('#') at the bottom
            targetIndex = i;
            break;
          }
        }
      }
    }

    if (targetIndex == -1) {
      targetIndex = songs.length - 1;
    }

    const itemHeight = 78.0;
    final targetOffset = (targetIndex * itemHeight).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.jumpTo(targetOffset);
  }

  @override
  Widget build(BuildContext context) {
    final List<SongModel> songs = [];
    final themeController = Get.put(ThemeController());

    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final scaffoldBg = themeController.scaffoldBg;
      final cardBg = themeController.cardBg;
      final textPrimary = themeController.textPrimary;
      final textSecondary = themeController.textSecondary;
      final accentGreen = themeController.accentGreen;
      final accentBlue = themeController.accentBlue;
      final inactiveAlphabetColor =
          isDark ? Colors.white.withValues(alpha: 0.75) : const Color(0xff475569);

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          log('didPop: $didPop');

          if (didPop) return;

          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: cardBg,
              title: Text('Exit App?',
                  style: TextStyle(
                      color: textPrimary, fontWeight: FontWeight.bold)),
              content: Text('Do you really want to exit?',
                  style: TextStyle(color: textSecondary)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel', style: TextStyle(color: textSecondary)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Exit',
                      style: TextStyle(
                          color: accentGreen, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );

          if (shouldExit == true) {
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          drawer: const AppDrawer(),
          backgroundColor: scaffoldBg,
          body: Obx(
            () {
              if (contoller.loading.value) {
                return Center(
                  child: CircularProgressIndicator(color: accentGreen),
                );
              }

              if (contoller.allsongs.isEmpty) {
                return Center(
                  child: Text(
                    "No song found",
                    style: TextStyle(
                      fontSize: 15,
                      color: textSecondary,
                    ),
                  ),
                );
              }

              _activeLetter ??=
                  _getLetterForSong(contoller.allsongs.first.title);

              return Stack(
                children: [
                  // Song list with full width under the sorting bar
                  CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverAppBar(
                        backgroundColor: scaffoldBg,
                        pinned: true,
                        surfaceTintColor: scaffoldBg,
                        floating: true,
                        automaticallyImplyLeading: false,
                        elevation: 0,
                        centerTitle: true,
                        leading: Builder(
                          builder: (context) => IconButton(
                            icon: Icon(Icons.menu_rounded,
                                color: textPrimary, size: 26),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                        title: Text(
                          "Music Player",
                          style: GoogleFonts.acme(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: accentGreen,
                            letterSpacing: 0.5,
                          ),
                        ),
                        actions: [
                          IconButton(
                            onPressed: () {
                              showSearch(
                                context: context,
                                delegate: SearchSong(contoller.allsongs),
                              );
                            },
                            icon: Icon(Icons.search, color: textPrimary),
                          ),
                        ],
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final song = contoller.allsongs[index];
                            songs.add(song);

                            return Obx(
                              () => MusicListtile(
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
                                    child: Icon(
                                      Icons.music_note,
                                      color: textPrimary,
                                      size: 26,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  contoller.playOrNavigate(
                                    song,
                                    index,
                                    contoller.allsongs,
                                  );
                                },
                                musicName: song.title,
                                artistName: song.artist ?? "Unknown Artist",
                                trailing: contoller.playindex.value == index &&
                                        contoller.isplaying.value
                                    ? Icon(
                                        Icons.play_arrow_rounded,
                                        size: 28,
                                        color: accentGreen,
                                      )
                                    : null,
                              ),
                            );
                          },
                          childCount: contoller.allsongs.length,
                        ),
                      ),
                    ],
                  ),

                  // Vertical A-Z sorting bar aligned on the right side over the tiles
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          right: 4.0, top: 56.0, bottom: 8.0),
                      child: AlphabetScrollbar(
                        alphabets: _alphabets,
                        activeLetter: _activeLetter,
                        letterHeight: _letterHeight,
                        activeColor: accentBlue,
                        inactiveColor: inactiveAlphabetColor,
                        backgroundColor: isDark
                            ? const Color(0xff1f212c).withValues(alpha: 0.88)
                            : Colors.white.withValues(alpha: 0.92),
                        borderColor: isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : const Color(0xffcbd5e1),
                        isDark: isDark,
                        onLetterSelected: (letter) {
                          _isDraggingScrollbar = true;
                          setState(() {
                            _activeLetter = letter;
                            _showCenterPreview = true;
                          });
                          _scrollToLetter(letter);
                        },
                        onDragEnd: () {
                          _isDraggingScrollbar = false;
                          setState(() {
                            _showCenterPreview = false;
                          });
                        },
                      ),
                    ),
                  ),

                  // Floating letter preview capsule in the center of the screen
                  AnimatedOpacity(
                    opacity:
                        _showCenterPreview && _activeLetter != null ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 180),
                    child: IgnorePointer(
                      child: Center(
                        child: Container(
                          width: 80,
                          height: 88,
                          decoration: BoxDecoration(
                            color: isDark
                                ? cardBg.withValues(alpha: 0.94)
                                : Colors.white.withValues(alpha: 0.96),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: accentBlue.withValues(alpha: 0.8),
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withValues(alpha: 0.7)
                                    : const Color(0xff64748b)
                                        .withValues(alpha: 0.2),
                                blurRadius: 22,
                                spreadRadius: 3,
                                offset: const Offset(0, 6),
                              ),
                              if (isDark)
                                BoxShadow(
                                  color: accentBlue.withValues(alpha: 0.3),
                                  blurRadius: 18,
                                  spreadRadius: 1,
                                ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _activeLetter ?? '',
                              style: GoogleFonts.acme(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: accentBlue,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          bottomNavigationBar: BottomMusicView(songs: songs),
        ),
      );
    });
  }
}
