import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

/// Rhythm of one song, analysed once from its audio: where each beat falls
/// and how loud the low end is over time. Drives the reactive visuals.
class BeatMap {
  BeatMap({
    required this.bpm,
    required this.beats,
    required this.strengths,
    required this.energy,
    this.frame = const Duration(milliseconds: 20),
  }) : assert(beats.length == strengths.length);

  /// No rhythm known (analysis pending or failed): calm visuals, no pulses.
  static final calm = BeatMap(
    bpm: 0,
    beats: Int32List(0),
    strengths: Uint8List(0),
    energy: Uint8List(0),
  );

  /// Evenly spaced beats with a slow swell per bar, for the sample catalog.
  factory BeatMap.steady(double bpm, Duration length) {
    const frame = Duration(milliseconds: 20);
    final period = 60000 / bpm;
    final beats = Int32List.fromList([
      for (var t = 0.0; t < length.inMilliseconds; t += period) t.round(),
    ]);
    final bar = period * 4;
    final energy = Uint8List.fromList([
      for (var i = 0; i * 20 < length.inMilliseconds; i++)
        ((0.5 + 0.4 * math.sin(i * 20 / bar * math.pi).abs()) * 255).round(),
    ]);
    return BeatMap(
      bpm: bpm,
      beats: beats,
      strengths: Uint8List(beats.length)..fillRange(0, beats.length, 200),
      energy: energy,
      frame: frame,
    );
  }

  final double bpm;

  /// Beat times in milliseconds, ascending.
  final Int32List beats;

  /// Onset strength of each beat (0–255): accented beats pulse harder.
  final Uint8List strengths;

  /// Low-end loudness per [frame] (0–255), normalised per song.
  final Uint8List energy;
  final Duration frame;

  bool get isEmpty => beats.isEmpty && energy.isEmpty;

  /// Kick envelope at [position]: the last beat's strength, decaying
  /// `exp(-t·7)` after it (0 before the first beat).
  double beatAt(Duration position) {
    final ms = position.inMilliseconds;
    var lo = 0, hi = beats.length - 1, last = -1;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      if (beats[mid] <= ms) {
        last = mid;
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }
    if (last < 0) return 0;
    final since = (ms - beats[last]) / 1000;
    return strengths[last] / 255 * math.exp(-since * 7);
  }

  /// Low-end loudness at [position] (0–1), interpolated between frames.
  double energyAt(Duration position) {
    if (energy.isEmpty) return 0;
    final f = position.inMicroseconds / frame.inMicroseconds;
    final i = f.floor().clamp(0, energy.length - 1);
    final j = math.min(i + 1, energy.length - 1);
    final t = (f - i).clamp(0.0, 1.0);
    return (energy[i] * (1 - t) + energy[j] * t) / 255;
  }

  Map<String, Object> toJson() => {
    'v': 1,
    'bpm': bpm,
    'frameUs': frame.inMicroseconds,
    'beats': base64.encode(
      beats.buffer.asUint8List(beats.offsetInBytes, beats.lengthInBytes),
    ),
    'strengths': base64.encode(strengths),
    'energy': base64.encode(energy),
  };

  static BeatMap? fromJson(Map<String, Object?> json) {
    if (json['v'] != 1) return null;
    final beats = base64.decode(json['beats']! as String);
    return BeatMap(
      bpm: (json['bpm']! as num).toDouble(),
      beats: Int32List.view(Uint8List.fromList(beats).buffer),
      strengths: base64.decode(json['strengths']! as String),
      energy: base64.decode(json['energy']! as String),
      frame: Duration(microseconds: json['frameUs']! as int),
    );
  }
}
