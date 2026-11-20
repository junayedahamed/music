import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';

/// Utility to generate and cache persistent glowing waveform artwork for notifications.
class WaveformArtGenerator {
  static Future<Uri?> resolveArtwork(OnAudioQuery audioQuery, SongModel song) async {
    try {
      final bytes = await audioQuery.queryArtwork(
        song.id,
        ArtworkType.AUDIO,
        format: ArtworkFormat.JPEG,
        size: 500,
      );
      return await getOrCreateNotificationWaveformArt(
        song.id,
        song.title,
        albumArtBytes: (bytes != null && bytes.isNotEmpty) ? bytes : null,
      );
    } catch (_) {
      return await getOrCreateNotificationWaveformArt(song.id, song.title);
    }
  }

  static Future<Uri?> getOrCreateNotificationWaveformArt(
    int songId,
    String songTitle, {
    Uint8List? albumArtBytes,
  }) async {
    try {
      final baseDir = await getApplicationSupportDirectory();
      final artDir = Directory("${baseDir.path}/notification_art");
      if (!await artDir.exists()) {
        await artDir.create(recursive: true);
      }
      final hasArt = albumArtBytes != null && albumArtBytes.isNotEmpty;
      final file = File(
          "${artDir.path}/wave_art_${songId}_${hasArt ? 'art' : 'wave'}.png");
      if (await file.exists()) {
        return Uri.file(file.path);
      }

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 512, 512));

      if (hasArt) {
        try {
          final codec = await ui.instantiateImageCodec(albumArtBytes);
          final frame = await codec.getNextFrame();
          final img = frame.image;
          paintImage(
            canvas: canvas,
            rect: const Rect.fromLTWH(0, 0, 512, 512),
            image: img,
            fit: BoxFit.cover,
          );
          final darkPaint = Paint()
            ..color = Colors.black.withValues(alpha: 0.55);
          canvas.drawRect(const Rect.fromLTWH(0, 0, 512, 512), darkPaint);
        } catch (_) {
          _drawDefaultWaveBackground(canvas);
        }
      } else {
        _drawDefaultWaveBackground(canvas);
      }

      const int bars = 36;
      const double barWidth = 7.0;
      const double spacing = 6.0;
      const double startX = (512 - (bars * (barWidth + spacing))) / 2;

      final wavePaint = Paint();
      final random = math.Random(songId);

      for (int i = 0; i < bars; i++) {
        final x = startX + i * (barWidth + spacing);
        final norm = i / (bars - 1);
        final envelope = math.sin(norm * math.pi);
        final heightFactor =
            (0.3 + 0.7 * envelope) * (0.6 + 0.4 * random.nextDouble());
        final barHeight = (heightFactor * 220).clamp(16.0, 240.0);
        final y = 256.0 - (barHeight / 2);

        wavePaint.shader = ui.Gradient.linear(
          Offset(x, y),
          Offset(x, y + barHeight),
          const [
            Color(0xff00b0ff),
            Color(0xff60E95D),
          ],
        );

        final rrect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(4),
        );
        canvas.drawRRect(rrect, wavePaint);
      }

      final picture = recorder.endRecording();
      final image = await picture.toImage(512, 512);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        await file.writeAsBytes(byteData.buffer.asUint8List());
        return Uri.file(file.path);
      }
    } catch (_) {}
    return null;
  }

  static void _drawDefaultWaveBackground(Canvas canvas) {
    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        const Offset(512, 512),
        const [
          Color(0xff060910),
          Color(0xff121826),
          Color(0xff090c14),
        ],
      );
    canvas.drawRect(const Rect.fromLTWH(0, 0, 512, 512), bgPaint);

    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        const Offset(256, 256),
        200,
        [
          const Color(0xff00b0ff).withValues(alpha: 0.3),
          Colors.transparent,
        ],
      );
    canvas.drawCircle(const Offset(256, 256), 200, glowPaint);
  }
}
