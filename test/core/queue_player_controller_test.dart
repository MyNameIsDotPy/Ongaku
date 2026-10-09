import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ongaku/core/local/ongaku_audio_handler.dart';
import 'package:ongaku/core/player/playback_engine.dart';
import 'package:ongaku/core/player/queue_player_controller.dart';
import 'package:ongaku/models/api_error.dart';
import 'package:ongaku/models/player_snapshot.dart';
import 'package:ongaku/models/track.dart';

const track = Track(
  videoId: 'one',
  title: 'One',
  artists: [],
  duration: Duration(minutes: 3),
  coverUrl: '',
);

class Engine implements PlaybackEngine {
  final loads = <Completer<void>>[];
  final playStates = StreamController<bool>.broadcast();
  final stalls = StreamController<bool>.broadcast();
  int plays = 0;
  int stops = 0;
  int pauses = 0;
  @override
  double volume = 1;
  @override
  Future<void> setVolume(double value) async => volume = value;
  @override
  Future<void> load(Track track, {Duration from = Duration.zero}) {
    final pending = Completer<void>();
    loads.add(pending);
    return pending.future;
  }

  @override
  Future<void> play() async {
    plays++;
  }

  @override
  Future<void> pause() async {
    pauses++;
  }

  @override
  Future<void> stop() async {
    stops++;
  }

  @override
  Future<void> seek(Duration position) async {}
  @override
  Stream<bool> get playing => playStates.stream;
  @override
  Stream<bool> get buffering => stalls.stream;
  @override
  Stream<void> get completed => const Stream.empty();
  @override
  Stream<Object> get errors => const Stream.empty();
  @override
  Stream<Duration> get positions => const Stream.empty();
  @override
  Duration get position => Duration.zero;
  @override
  Future<void> dispose() async {
    await playStates.close();
    await stalls.close();
  }
}

void main() {
  late Engine engine;
  late QueuePlayerController queue;
  setUp(() {
    engine = Engine();
    queue = QueuePlayerController(engine);
  });
  tearDown(() => queue.dispose());

  test('volume is kept by the engine and clamped to 0-1', () async {
    expect(queue.volume, 1);
    queue.setVolume(0.4);
    expect(queue.volume, 0.4);
    expect(engine.volume, 0.4);
    queue.setVolume(1.7);
    expect(queue.volume, 1);
  });

  test('pause while loading prevents autoplay', () async {
    queue.play([track]);
    queue.pause();
    engine.loads.single.complete();
    await Future<void>.delayed(Duration.zero);
    expect(engine.plays, 0);
    expect(queue.snapshot.status, PlaybackStatus.paused);
  });

  test('native interruption pauses UI and resume restores it', () async {
    queue.play([track]);
    engine.loads.single.complete();
    await Future<void>.delayed(Duration.zero);
    engine.playStates.add(false);
    await Future<void>.delayed(Duration.zero);
    expect(queue.snapshot.status, PlaybackStatus.paused);
    engine.playStates.add(true);
    await Future<void>.delayed(Duration.zero);
    expect(queue.snapshot.status, PlaybackStatus.playing);
  });

  test('media pause works while buffering and stop cancels a load', () async {
    final handler = OngakuAudioHandler()..attach(queue);
    queue.play([track]);
    engine.loads.single.complete();
    await Future<void>.delayed(Duration.zero);
    engine.stalls.add(true);
    await Future<void>.delayed(Duration.zero);
    expect(queue.snapshot.status, PlaybackStatus.buffering);
    await handler.pause();
    await Future<void>.delayed(Duration.zero);
    expect(queue.snapshot.status, PlaybackStatus.paused);
    await Future<void>.delayed(Duration.zero);
    expect(handler.playbackState.value.playing, false);
    queue.play([track]);
    await handler.stop();
    engine.loads.last.complete();
    await Future<void>.delayed(Duration.zero);
    expect(queue.snapshot.status, PlaybackStatus.idle);
    expect(engine.plays, 1);
  });

  test('offline errors keep the current track and allow retry', () async {
    queue.play([track, track.copyWith(videoId: 'two')]);
    engine.loads.single.completeError(
      const ApiException(ApiErrorCode.backendOffline),
    );
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(const Duration(milliseconds: 1700));
    expect(queue.snapshot.index, 0);
    expect(queue.snapshot.status, PlaybackStatus.error);
    expect(engine.loads, hasLength(1));
    queue.toggle();
    engine.loads.last.complete();
    await Future<void>.delayed(Duration.zero);
    expect(queue.snapshot.status, PlaybackStatus.playing);
  });

  test('repeat all cannot endlessly retry an unavailable queue', () async {
    queue.cycleRepeat();
    queue.play([track, track.copyWith(videoId: 'two')]);
    engine.loads.single.completeError(
      const ApiException(ApiErrorCode.unavailable),
    );
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(const Duration(milliseconds: 1700));
    engine.loads.last.completeError(
      const ApiException(ApiErrorCode.unavailable),
    );
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(const Duration(milliseconds: 1700));
    expect(engine.loads, hasLength(2));
    expect(queue.snapshot.status, PlaybackStatus.error);
  });

  test('dispose invalidates pending loads', () async {
    queue.play([track]);
    queue.dispose();
    engine.loads.single.complete();
    await Future<void>.delayed(Duration.zero);
    expect(engine.plays, 0);
    // Replace the disposed controller for tearDown.
    queue = QueuePlayerController(Engine());
  });
}
