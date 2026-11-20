import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

/// Handles runtime permissions and device music querying safely.
class AudioPermissionService {
  static bool _isQuerying = false;

  /// Checks whether storage or audio media permission is already granted.
  static Future<bool> hasAudioPermission(OnAudioQuery audioQuery) async {
    try {
      final onAudioStatus = await audioQuery.permissionsStatus();
      if (onAudioStatus) return true;

      final audioGranted = await Permission.audio.isGranted;
      if (audioGranted) return true;

      final storageGranted = await Permission.storage.isGranted;
      return storageGranted;
    } catch (e) {
      log("Error checking permission status: $e");
      return false;
    }
  }

  /// Requests necessary audio and notification permissions sequentially without race conditions.
  static Future<bool> requestPermission(OnAudioQuery audioQuery) async {
    try {
      // 1. Request notification permission on Android 13+ (non-blocking for query)
      try {
        if (!await Permission.notification.isGranted) {
          await Permission.notification.request();
        }
      } catch (_) {}

      // 2. Request using on_audio_query's native handler first
      bool granted = await audioQuery.checkAndRequest(retryRequest: true);
      if (granted) return true;

      // 3. Fallback to permission_handler: check Android 13+ audio permission
      final audioStatus = await Permission.audio.request();
      if (audioStatus.isGranted) return true;

      // 4. Fallback for Android 12 and below: check storage permission
      final storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) return true;

      return await audioQuery.permissionsStatus();
    } catch (e) {
      log("Error requesting permissions: $e");
      return false;
    }
  }

  /// Safely requests permissions and queries songs, avoiding concurrent execution and crash.
  static Future<List<SongModel>?> requestAndFetchSongs({
    required OnAudioQuery audioQuery,
    OrderType? orderType,
  }) async {
    if (_isQuerying) {
      log("Permission/Query request already running. Ignoring duplicate call.");
      return null;
    }

    _isQuerying = true;
    try {
      bool hasPermission = await hasAudioPermission(audioQuery);
      if (!hasPermission) {
        hasPermission = await requestPermission(audioQuery);
      }

      if (!hasPermission) {
        log("Permission denied by user. Skipping querySongs.");
        return null;
      }

      // Safe invocation of querySongs guarded against PlatformException
      return await audioQuery.querySongs(
        ignoreCase: true,
        orderType: orderType ?? OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
      );
    } on PlatformException catch (pe) {
      log("PlatformException in querySongs: ${pe.code} - ${pe.message}");
      return null;
    } catch (e) {
      log("Unexpected error querying songs: $e");
      return null;
    } finally {
      _isQuerying = false;
    }
  }
}
