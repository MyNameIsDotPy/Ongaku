import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ongaku/core/beats/beat_analyzer.dart';
import 'package:ongaku/core/local/audio_decoder.dart';
import 'package:ongaku/core/local/beat_analysis.dart';
import 'package:ongaku/core/local/youtube_gateway.dart';
import 'package:ongaku/models/beat_map.dart';

/// Kick drum (decaying 60 Hz sine) every beat from [offset], over noise.
Float32List clickTrack(double bpm, double offset, {double seconds = 40}) {
  const sr = BeatAnalyzer.sampleRate;
  final rnd = math.Random(7);
  final pcm = Float32List((seconds * sr).round());
  for (var i = 0; i < pcm.length; i++) {
    pcm[i] = (rnd.nextDouble() - 0.5) * 0.05;
  }
  for (var t = offset; t < seconds; t += 60 / bpm) {
    final start = (t * sr).round();
    for (var i = 0; i < sr * 0.15 && start + i < pcm.length; i++) {
      final s = i / sr;
      pcm[start + i] +=
          0.8 * math.exp(-s * 30) * math.sin(2 * math.pi * 60 * s);
    }
  }
  return pcm;
}

void expectOnGrid(BeatMap map, double bpm, double offset) {
  expect(map.bpm, closeTo(bpm, 2));
  expect(map.beats.length, greaterThan(20));
  final period = 60000 / bpm;
  var aligned = 0;
  for (final b in map.beats) {
    final phase = ((b - offset * 1000) % period + period) % period;
    if (math.min(phase, period - phase) <= 30) aligned++;
  }
  expect(aligned / map.beats.length, greaterThan(0.9));
}

class FakeDecoder extends AudioDecoder {
  final decoded = <String>[];
  @override
  Future<Float32List?> decodeMono(String path) async {
    decoded.add(path.split('/').last);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    return clickTrack(120, 0.25, seconds: 10);
  }
}

void main() {
  test('finds tempo and beat positions of a 120 BPM track', () {
    expectOnGrid(BeatAnalyzer.analyze(clickTrack(120, 0.37)), 120, 0.37);
  });

  test('finds tempo and beat positions of a 95 BPM track', () {
    expectOnGrid(BeatAnalyzer.analyze(clickTrack(95, 1.1)), 95, 1.1);
  });

  test('too short or silent audio stays calm', () {
    expect(
      BeatAnalyzer.analyze(Float32List(BeatAnalyzer.sampleRate)).isEmpty,
      isTrue,
    );
  });

  test('beat envelope, energy and JSON round trip', () {
    final map = BeatMap(
      bpm: 120,
      beats: Int32List.fromList([500, 1000]),
      strengths: Uint8List.fromList([255, 102]),
      energy: Uint8List.fromList([0, 255]),
    );
    expect(map.beatAt(const Duration(milliseconds: 400)), 0);
    expect(map.beatAt(const Duration(milliseconds: 500)), 1);
    expect(map.beatAt(const Duration(milliseconds: 1000)), closeTo(0.4, 1e-9));
    expect(
      map.beatAt(const Duration(milliseconds: 1100)),
      closeTo(0.4 * math.exp(-0.7), 1e-9),
    );
    expect(map.energyAt(const Duration(milliseconds: 10)), closeTo(0.5, 1e-9));

    final copy = BeatMap.fromJson(map.toJson())!;
    expect(copy.beats, map.beats);
    expect(copy.strengths, map.strengths);
    expect(copy.energy, map.energy);
    expect(copy.frame, map.frame);
  });

  test(
    'skipping songs analyses only the latest, then serves the cache',
    () async {
      final dir = await Directory.systemTemp.createTemp('ongaku-beats-');
      addTearDown(() => dir.delete(recursive: true));
      for (final id in ['a', 'b', 'c']) {
        await File('${dir.path}/$id.m4a').writeAsBytes([0]);
      }
      final decoder = FakeDecoder();
      BeatAnalysis open() => BeatAnalysis(
        YoutubeGateway(),
        Directory('${dir.path}/beats'),
        localFile: (id) => '${dir.path}/$id.m4a',
        decoder: decoder,
      );
      final beats = open();
      final results = await Future.wait([
        beats.beatMap('a'),
        beats.beatMap('b'),
        beats.beatMap('c'),
      ]);
      // a and b were superseded by c before their turn came.
      expect(results[0], isNull);
      expect(results[1], isNull);
      expect(results[2]!.bpm, closeTo(120, 2));
      expect(decoder.decoded, ['c.m4a']);

      // A new session reads the disk cache instead of decoding again.
      final cached = await open().beatMap('c');
      expect(cached!.beats, results[2]!.beats);
      expect(decoder.decoded, ['c.m4a']);
    },
  );
}
