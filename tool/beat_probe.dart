// Run on a device to check on-device beat analysis (decoder + analyzer):
// flutter run -d <device> -t tool/beat_probe.dart
// Uses a temporary cache; does not touch the app's library or settings.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ongaku/core/local/beat_analysis.dart';
import 'package:ongaku/core/local/youtube_gateway.dart';

/// Video id → expected tempo (BPM).
const songs = {
  'dQw4w9WgXcQ': 113.0, // Never Gonna Give You Up
  'kJQP7kiw5Fk': 89.0, // Despacito
};

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final status = ValueNotifier<String>('Preparing beat probe');
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
    debugPrint('BEAT_PROBE: $message');
  }

  final dir = await Directory.systemTemp.createTemp('ongaku-beat-probe-');
  final gateway = YoutubeGateway();
  final beats = BeatAnalysis(gateway, dir, localFile: (_) => null);
  var failed = false;
  try {
    for (final MapEntry(key: id, value: expected) in songs.entries) {
      final watch = Stopwatch()..start();
      final map = await beats.beatMap(id);
      if (map == null) {
        failed = true;
        report('FAIL: $id could not be analysed');
        continue;
      }
      final ok = (map.bpm - expected).abs() <= 3;
      failed |= !ok;
      report(
        '${ok ? 'PASS' : 'FAIL'}: $id ${map.bpm.toStringAsFixed(1)} BPM '
        '(expected ~$expected), ${map.beats.length} beats, '
        'first ${map.beats.take(3).toList()} ms, '
        '${watch.elapsedMilliseconds} ms',
      );
    }
    report(failed ? 'BEAT CHECKS FAILED' : 'ALL BEAT CHECKS PASSED');
  } catch (e, stack) {
    report('FAIL: $e');
    debugPrint('$stack');
  } finally {
    gateway.close();
    await dir.delete(recursive: true);
  }
}
