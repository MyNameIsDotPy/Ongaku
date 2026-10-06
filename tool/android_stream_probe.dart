// Run on a physical Android device:
// flutter run -d <device> -t tool/android_stream_probe.dart
// This probe does not change the app's library, settings, or saved queue.
import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:ongaku/core/local/just_audio_engine.dart';
import 'package:ongaku/core/local/ongaku_audio_handler.dart';
import 'package:ongaku/core/local/stream_resolver.dart';
import 'package:ongaku/core/local/youtube_gateway.dart';
import 'package:ongaku/core/local/yt_dlp.dart';
import 'package:ongaku/core/player/queue_player_controller.dart';
import 'package:ongaku/models/app_settings.dart';
import 'package:ongaku/models/player_snapshot.dart';
import 'package:ongaku/models/track.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final status = ValueNotifier<String>('Preparing stream probe');
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: ValueListenableBuilder<String>(
            valueListenable: status,
            builder: (_, text, _) => Text(text, textAlign: TextAlign.center),
          ),
        ),
      ),
    ),
  );
  void report(String message) {
    status.value = message;
    debugPrint('STREAM_PROBE: $message');
  }

  final gateway = YoutubeGateway();
  final engine = JustAudioEngine(
    StreamResolver(gateway, ytDlp: YtDlp(), localFile: (_) => null),
    quality: () => AudioQuality.high,
  );
  final queue = QueuePlayerController(engine);
  final handler = await AudioService.init(
    builder: OngakuAudioHandler.new,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.ongaku.playback',
      androidNotificationChannelName: 'Reproducción',
    ),
  );
  handler.attach(queue);
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());
  final sub = queue.snapshots.listen(
    (s) => report('${s.status.name}: ${s.error ?? s.current?.videoId ?? ""}'),
  );
  const track = Track(
    videoId: String.fromEnvironment(
      'STREAM_VIDEO_ID',
      defaultValue: '7xRWOylrLfI',
    ),
    title: 'Android streaming check',
    artists: [ArtistRef(id: 'test', name: 'Ongaku')],
    duration: Duration(minutes: 4),
    coverUrl: '',
  );
  Future<void> waitForPlayback() async {
    final deadline = DateTime.now().add(const Duration(seconds: 90));
    while (queue.snapshot.status != PlaybackStatus.playing) {
      if (queue.snapshot.status == PlaybackStatus.error) {
        throw queue.snapshot.error!;
      }
      if (DateTime.now().isAfter(deadline)) {
        throw TimeoutException('Playback did not start');
      }
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    final before = queue.position;
    await Future<void>.delayed(const Duration(seconds: 4));
    if (queue.position <= before + const Duration(seconds: 1)) {
      throw StateError(
        'Audio position did not advance: $before -> ${queue.position}',
      );
    }
  }

  try {
    queue.play([track]);
    await waitForPlayback();
    report('PASS: streaming advances');
    queue.seek(const Duration(seconds: 30));
    await Future<void>.delayed(const Duration(seconds: 4));
    if (queue.position < const Duration(seconds: 30)) {
      throw StateError('Seek failed');
    }
    await handler.pause();
    final paused = queue.position;
    await Future<void>.delayed(const Duration(seconds: 2));
    if ((queue.position - paused).abs() > const Duration(milliseconds: 500)) {
      throw StateError('Pause failed');
    }
    report('PASS: seek and media pause');
    await handler.play();
    await waitForPlayback();
    report('PASS: media resume; checking background playback for 20 seconds');
    final backgroundAt = queue.position;
    await Future<void>.delayed(const Duration(seconds: 20));
    if (queue.position < backgroundAt + const Duration(seconds: 15)) {
      throw StateError('Background playback stalled');
    }
    queue.play([track]);
    await waitForPlayback();
    report('PASS: replay resolves a fresh stream');
    queue.play([track]);
    await handler.stop();
    await Future<void>.delayed(const Duration(seconds: 5));
    if (queue.snapshot.status != PlaybackStatus.idle) {
      throw StateError('Stop did not cancel load');
    }
    report('ALL STREAM CHECKS PASSED');
  } catch (e, stack) {
    report('FAIL: $e');
    debugPrint('$stack');
  } finally {
    await sub.cancel();
    queue.dispose();
    gateway.close();
  }
}
