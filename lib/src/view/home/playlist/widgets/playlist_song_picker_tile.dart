import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlaylistSongPickerTile extends StatelessWidget {
  final SongModel song;
  final bool isSelected;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderColor;
  final Color accentGreen;
  final VoidCallback onTap;

  const PlaylistSongPickerTile({
    super.key,
    required this.song,
    required this.isSelected,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderColor,
    required this.accentGreen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? accentGreen.withValues(alpha: 0.12) : cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? accentGreen.withValues(alpha: 0.5)
                    : borderColor,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                QueryArtworkWidget(
                  id: song.id,
                  type: ArtworkType.AUDIO,
                  nullArtworkWidget: Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black54 : const Color(0xffe2e8f0),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.music_note, color: textPrimary, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        song.artist ?? "Unknown Artist",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: isSelected ? accentGreen : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? accentGreen : borderColor,
                      width: 1.8,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded,
                          size: 16, color: Colors.black)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
