import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ongaku/core/local/youtube_audio_source.dart';

void main() {
  final uri = Uri.parse(
    'https://example.googlevideo.com/audio?mime=audio%2Fmp4',
  );

  test(
    'initial reads and seeks use explicit inclusive upstream ranges',
    () async {
      final ranges = <String?>[];
      final client = MockClient((request) async {
        ranges.add(request.headers['Range']);
        final seek = ranges.length > 1;
        return http.Response.bytes(
          seek ? [2, 3] : [0, 1, 2, 3],
          206,
          headers: {'content-range': seek ? 'bytes 2-3/4' : 'bytes 0-3/4'},
        );
      });
      final source = YoutubeAudioSource(uri, length: 4, client: client);
      addTearDown(source.close);
      final first = await source.request();
      expect(first.sourceLength, 4);
      expect(first.contentLength, 4);
      expect(first.contentType, 'audio/mp4');
      expect(await first.stream.expand((bytes) => bytes).toList(), [
        0,
        1,
        2,
        3,
      ]);
      final seek = await source.request(2);
      expect(seek.offset, 2);
      expect(seek.contentLength, 2);
      expect(await seek.stream.expand((bytes) => bytes).toList(), [2, 3]);
      expect(ranges, ['bytes=0-3', 'bytes=2-3']);
    },
  );

  test('partial requests preserve the exclusive end', () async {
    final source = YoutubeAudioSource(
      uri,
      length: 100,
      client: MockClient((request) async {
        expect(request.headers['Range'], 'bytes=10-19');
        return http.Response.bytes(
          List.filled(10, 1),
          206,
          headers: {'content-range': 'bytes 10-19/100'},
        );
      }),
    );
    addTearDown(source.close);
    final response = await source.request(10, 20);
    expect(response.contentLength, 10);
    await response.stream.drain<void>();
  });

  test(
    'blocked or truncated responses fail instead of feeding corrupt audio',
    () async {
      for (final response in [
        http.Response('', 403),
        http.Response('x', 206),
      ]) {
        final source = YoutubeAudioSource(
          uri,
          length: 4,
          client: MockClient((_) async => response),
        );
        await expectLater(
          source.request(),
          throwsA(isA<http.ClientException>()),
        );
        source.close();
      }
    },
  );

  test('closed sources reject pending native reloads', () async {
    final source = YoutubeAudioSource(
      uri,
      length: 4,
      client: MockClient((_) async => http.Response('', 500)),
    );
    source.close();
    await expectLater(source.request(), throwsStateError);
  });
}
