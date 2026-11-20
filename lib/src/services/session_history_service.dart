import 'package:music/src/services/audio_cache_service.dart';
import 'package:on_audio_query/on_audio_query.dart';

/// Manages played session history records and persistence.
class SessionHistoryService {
  static void recordSong(List<Map<String, dynamic>> list, SongModel? song) {
    if (song == null) return;
    list.removeWhere((item) => (item['id'] as num?)?.toInt() == song.id);
    list.insert(0, {
      'id': song.id,
      'title': song.title,
      'artist': song.artist ?? 'Unknown Artist',
      'uri': song.uri ?? '',
      'duration': song.duration ?? 0,
      'playedAt': DateTime.now().millisecondsSinceEpoch,
    });
    if (list.length > 100) list.removeRange(100, list.length);
    AudioCacheService.saveSessionHistory(list);
  }

  static List<SongModel> filterSongs(
      List<Map<String, dynamic>> played, List<SongModel> allSongs) {
    final idMap = {for (var s in allSongs) s.id: s};
    return played
        .map((i) => idMap[(i['id'] as num?)?.toInt()])
        .whereType<SongModel>()
        .toList();
  }
}
