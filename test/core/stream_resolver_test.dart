import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ongaku/core/local/stream_resolver.dart';
import 'package:ongaku/core/local/youtube_gateway.dart';
import 'package:ongaku/core/local/yt_dlp.dart';
import 'package:ongaku/models/app_settings.dart';
import 'package:ongaku/models/track.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

const track = Track(
  videoId: 'dQw4w9WgXcQ',
  title: 'Test',
  artists: [],
  duration: Duration(minutes: 3),
  coverUrl: '',
);

class AudioInfo implements AudioOnlyStreamInfo {
  AudioInfo(this.url, this.bitrate, this.container);
  @override
  final Uri url;
  @override
  final Bitrate bitrate;
  @override
  final StreamContainer container;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class Streams implements StreamClient {
  int calls = 0;
  final clients = <String?>[];

  /// Client names whose manifest request fails.
  final failing = <String>{};
  @override
  Future<StreamManifest> getManifest(
    dynamic videoId, {
    bool fullManifest = false,
    List<YoutubeApiClient>? ytClients,
    bool requireWatchPage = true,
  }) async {
    calls++;
    final name =
        (ytClients?.single.payload['context'] as Map?)?['client']?['clientName']
            as String?;
    clients.add(name);
    if (failing.contains(name)) throw VideoUnplayableException('x');
    return StreamManifest([
      AudioInfo(
        Uri.parse('https://example.com/$calls-high'),
        const Bitrate(128000),
        StreamContainer.mp4,
      ),
      AudioInfo(
        Uri.parse('https://example.com/$calls-low'),
        const Bitrate(48000),
        StreamContainer.mp4,
      ),
      AudioInfo(
        Uri.parse('https://example.com/$calls-opus'),
        const Bitrate(160000),
        StreamContainer.webM,
      ),
    ]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class Videos implements VideoClient {
  @override
  final Streams streams = Streams();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class Youtube implements YoutubeExplode {
  @override
  final Videos videos = Videos();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class Gateway extends YoutubeGateway {
  final youtube = Youtube();
  @override
  Future<T> call<T>(Future<T> Function(YoutubeExplode) body) => body(youtube);
}

void main() {
  test('replay and quality changes each resolve a fresh manifest', () async {
    final gateway = Gateway();
    final resolver = StreamResolver(
      gateway,
      ytDlp: YtDlp(),
      localFile: (_) => null,
    );
    expect((await resolver.resolve(track)).path, '/1-opus');
    expect((await resolver.resolve(track)).path, '/2-opus');
    expect(
      (await resolver.resolve(track, quality: AudioQuality.low)).path,
      '/3-low',
    );
    expect(gateway.youtube.videos.streams.calls, 3);
  });
  test(
    'existing download works offline; deleted download falls back to streaming',
    () async {
      final directory = await Directory.systemTemp.createTemp('ongaku-test-');
      addTearDown(() => directory.delete(recursive: true));
      final file = await File(
        '${directory.path}/song.m4a',
      ).writeAsBytes([1, 2, 3]);
      final gateway = Gateway();
      final resolver = StreamResolver(
        gateway,
        ytDlp: YtDlp(),
        localFile: (_) => file.path,
      );
      expect(await resolver.resolve(track), file.uri);
      expect(gateway.youtube.videos.streams.calls, 0);
      await file.delete();
      expect((await resolver.resolve(track)).scheme, 'https');
      expect(gateway.youtube.videos.streams.calls, 1);
    },
  );
  test('tries VISIONOS first, then the Android and default clients', () async {
    final yt = Youtube();
    yt.videos.streams.failing.addAll(['VISIONOS', 'ANDROID']);
    final m = await audioManifest(yt, track.videoId);
    expect(m.audioOnly, isNotEmpty);
    expect(yt.videos.streams.clients, ['VISIONOS', 'ANDROID', null]);
  });
}
