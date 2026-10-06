import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:ongaku/core/local/just_audio_engine.dart';
import 'package:ongaku/core/local/stream_resolver.dart';
import 'package:ongaku/models/app_settings.dart';
import 'package:ongaku/models/track.dart';

const track = Track(
  videoId: 'one',
  title: 'One',
  artists: [],
  duration: Duration(minutes: 3),
  coverUrl: '',
);
const other = Track(
  videoId: 'two',
  title: 'Two',
  artists: [],
  duration: Duration(minutes: 3),
  coverUrl: '',
);
Future<void> flush() => Future<void>.delayed(Duration.zero);

class Resolver implements StreamResolver {
  final requests = <Completer<Uri>>[];
  @override
  Future<Uri> resolve(Track track, {AudioQuality quality = AudioQuality.high}) {
    final request = Completer<Uri>();
    requests.add(request);
    return request.future;
  }

  void finish(int index) =>
      requests[index].complete(Uri.parse('https://example.com/$index.m4a'));
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class Player implements AudioPlayer {
  final failures = StreamController<PlayerException>.broadcast();
  final states = StreamController<PlayerState>.broadcast();
  final processing = StreamController<ProcessingState>.broadcast();
  final sources = <AudioSource>[];
  int plays = 0;
  int pauses = 0;
  bool failLoad = false;
  bool failPlay = false;
  @override
  Stream<PlayerException> get errorStream => failures.stream;
  @override
  Stream<PlayerState> get playerStateStream => states.stream;
  @override
  Stream<ProcessingState> get processingStateStream => processing.stream;
  @override
  Duration get position => const Duration(seconds: 12);
  @override
  Future<Duration?> setAudioSource(
    AudioSource source, {
    bool preload = true,
    int? initialIndex,
    Duration? initialPosition,
  }) async {
    sources.add(source);
    if (failLoad) {
      failLoad = false;
      final error = PlayerException(403, 'Forbidden', 0);
      failures.add(error);
      await flush();
      throw error;
    }
    return track.duration;
  }

  @override
  Future<void> play() async {
    plays++;
    if (failPlay) {
      failPlay = false;
      throw PlayerException(1, 'Play failed', 0);
    }
  }

  @override
  Future<void> pause() async {
    pauses++;
  }

  @override
  Future<void> stop() async {}
  @override
  Future<void> dispose() async {
    await failures.close();
    await states.close();
    await processing.close();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Resolver resolver;
  late Player player;
  late JustAudioEngine engine;
  setUp(() {
    resolver = Resolver();
    player = Player();
    engine = JustAudioEngine(
      resolver,
      quality: () => AudioQuality.high,
      player: player,
    );
  });
  tearDown(() => engine.dispose());

  Future<void> load() async {
    final pending = engine.load(track);
    await flush();
    resolver.finish(resolver.requests.length - 1);
    await pending;
  }

  test(
    'a superseded load of the SAME track never replaces the new source',
    () async {
      final first = engine.load(track);
      await flush();
      final second = engine.load(track);
      await flush();
      resolver.finish(1);
      await second;
      resolver.finish(0);
      await first;
      expect(player.sources, hasLength(1));
      expect((player.sources.single as UriAudioSource).uri.path, '/1.m4a');
    },
  );

  test('stop cancels a pending resolution', () async {
    final pending = engine.load(track);
    await flush();
    await engine.stop();
    resolver.finish(0);
    await pending;
    expect(player.sources, isEmpty);
    expect(player.plays, 0);
  });

  test('load error stream and thrown exception share a single retry', () async {
    player.failLoad = true;
    final pending = engine.load(track);
    await flush();
    resolver.finish(0);
    await flush();
    await flush();
    expect(resolver.requests, hasLength(2));
    resolver.finish(1);
    await pending;
    expect(player.sources, hasLength(2));
    expect(player.plays, 0);
  });

  test('pause during recovery never resumes playback', () async {
    await load();
    await engine.play();
    player.failures.add(PlayerException(403, 'Expired', 0));
    await flush();
    expect(resolver.requests, hasLength(2));
    await engine.pause();
    resolver.finish(1);
    await flush();
    expect(player.plays, 1);
  });

  test('skip during recovery cannot resume or replace the new track', () async {
    await load();
    await engine.play();
    player.failures.add(PlayerException(403, 'Expired', 0));
    await flush();
    final next = engine.load(other);
    await flush();
    resolver.finish(2);
    await next;
    resolver.finish(1);
    await flush();
    expect(player.sources, hasLength(2));
    expect((player.sources.last as UriAudioSource).tag, other.videoId);
    expect(player.plays, 1);
  });

  test('native interruptions are forwarded to the queue', () async {
    await load();
    final playing = <bool>[];
    engine.playing.listen(playing.add);
    player.states.add(PlayerState(false, ProcessingState.ready));
    await flush();
    expect(playing, [false]);
  });

  test('asynchronous play failure is handled', () async {
    await load();
    player.failPlay = true;
    await engine.play();
    await flush();
    expect(resolver.requests, hasLength(2));
    resolver.finish(1);
    await flush();
    expect(player.plays, 2);
  });
}
