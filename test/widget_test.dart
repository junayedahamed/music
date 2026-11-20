import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('MediaItem correctly maps music metadata', () {
    final item = MediaItem(
      id: 'content://media/external/audio/media/101',
      title: 'Echoes of Silence',
      artist: 'The Weeknd',
      album: 'Trilogy',
      duration: const Duration(minutes: 4, seconds: 2),
      artUri: Uri.parse('file:///data/user/0/com.example.music/files/art.png'),
    );

    expect(item.id, 'content://media/external/audio/media/101');
    expect(item.title, 'Echoes of Silence');
    expect(item.artist, 'The Weeknd');
    expect(item.album, 'Trilogy');
    expect(item.duration?.inSeconds, 242);
    expect(item.artUri?.scheme, 'file');
  });
}
