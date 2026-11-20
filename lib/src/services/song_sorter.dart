import 'package:on_audio_query/on_audio_query.dart';

/// Utility to sort songs alphabetically, prioritizing letters over symbols.
class SongSorter {
  static void sortLexicographically(List<SongModel> songs, {bool ascending = true}) {
    songs.sort((a, b) {
      final cleanA = a.title.trim();
      final cleanB = b.title.trim();
      if (cleanA.isEmpty && cleanB.isEmpty) return 0;
      if (cleanA.isEmpty) return ascending ? 1 : -1;
      if (cleanB.isEmpty) return ascending ? -1 : 1;

      final isLetterA = RegExp(r'[a-zA-Z]').hasMatch(cleanA[0]);
      final isLetterB = RegExp(r'[a-zA-Z]').hasMatch(cleanB[0]);

      if (isLetterA && !isLetterB) return ascending ? -1 : 1;
      if (!isLetterA && isLetterB) return ascending ? 1 : -1;

      final comp = cleanA.toLowerCase().compareTo(cleanB.toLowerCase());
      return ascending ? comp : -comp;
    });
  }
}
