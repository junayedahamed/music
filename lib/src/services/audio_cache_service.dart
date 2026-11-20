import 'package:hive/hive.dart';
import 'package:on_audio_query/on_audio_query.dart';

/// Service for caching audio sessions, playlists, and history in Hive.
class AudioCacheService {
  static late Box<Map> _box;

  static void init(Box<Map> box) {
    _box = box;
  }

  static bool isValidSession(Map? d) {
    if (d == null) return false;
    final id = (d["songId"] as num?)?.toInt();
    final uri = d["songUri"] as String?;
    return (id != null && id > 0) || (uri != null && uri.isNotEmpty);
  }

  static bool hasValidSession() {
    try {
      final d = _box.get("last_session") ?? _box.get("data");
      return isValidSession(d);
    } catch (_) {
      return false;
    }
  }

  static Map? getLastSessionData() {
    try {
      final d = _box.get("last_session") ?? _box.get("data");
      return isValidSession(d) ? d : null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveSessionData(Map<String, dynamic> data) async {
    try {
      if (isValidSession(data)) {
        await _box.put("last_session", data);
        await _box.put("data", data);
      }
    } catch (_) {}
  }

  static Future<void> clearSessionData() async {
    try {
      await _box.delete("last_session");
      await _box.delete("data");
    } catch (_) {}
  }

  static void applySessionData(Map d, {
    required Function(int) setIndex,
    required Function(String) setName,
    required Function(String) setArtist,
    required Function(int) setId,
    required Function(double) setMax,
    required Function(double) setValue,
    required Function(String) setDuration,
    required Function(String) setPosition,
    required Function(String?) setUri,
    required Function(double) setSpeed,
    required Function(int) setLoop,
    required Function(bool) setShuffle,
  }) {
    setIndex((d["playIndex"] as num?)?.toInt() ?? 0);
    setName(d["songName"] ?? "Please select a song to play");
    setArtist(d["artist"] ?? "Unknown Artist");
    setId((d["songId"] as num?)?.toInt() ?? 0);
    setMax((d['max'] as num?)?.toDouble() ?? 0.0);
    setValue((d["value"] as num?)?.toDouble() ?? 0.0);
    setDuration(d["duration"] ?? "0:00");
    setPosition(d["position"] ?? "0:00");
    setUri(d["songUri"]);
    setSpeed((d["playbackSpeed"] as num?)?.toDouble() ?? 1.0);
    if (d["loopMode"] is int) setLoop((d["loopMode"] as int).clamp(0, 2));
    setShuffle(d["isShuffle"] ?? false);
  }

  static List<SongModel>? loadCachedSongs() {
    try {
      final cached = _box.get("cached_song_list");
      if (cached != null && cached["songs"] is List) {
        final list = cached["songs"] as List;
        return list
            .whereType<Map>()
            .map((e) => SongModel(Map<dynamic, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {}
    return null;
  }

  static Future<void> saveCachedSongs(List<SongModel> songs) async {
    try {
      final list = songs.map((s) => s.getMap).toList();
      await _box.put("cached_song_list", {"songs": list});
    } catch (_) {}
  }

  static List<Map<String, dynamic>> loadSessionHistory() {
    try {
      final saved = _box.get("session_played_songs");
      if (saved != null && saved["songs"] is List) {
        final list = saved["songs"] as List;
        return list
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<void> saveSessionHistory(
      List<Map<String, dynamic>> songs) async {
    try {
      await _box.put("session_played_songs", {"songs": songs});
    } catch (_) {}
  }

  static Future<void> clearSessionHistory() async {
    try {
      await _box.delete("session_played_songs");
    } catch (_) {}
  }
}
