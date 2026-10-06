import 'dart:math' as math;
import 'dart:typed_data';

import '../../models/beat_map.dart';

/// Finds the beats of a song from mono PCM (Ellis 2007, as in librosa):
/// spectral-flux onset envelope → tempo from its autocorrelation →
/// beat times by dynamic programming. Also extracts a low-end loudness
/// curve for the aura. Pure Dart, meant to run in an isolate.
class BeatAnalyzer {
  static const sampleRate = 11025;
  static const _fft = 512;
  static const _hop = 220; // ~20 ms per frame
  static const _fps = sampleRate / _hop;

  /// Bass band for the loudness curve: bins 1–7 ≈ 20–150 Hz.
  static const _bassBins = 7;

  static BeatMap analyze(Float32List pcm) {
    final frames = pcm.length ~/ _hop;
    if (frames < _fps * 4) return BeatMap.calm;

    final (onset, bass) = _spectralFeatures(pcm, frames);
    final energy = _normalise(_smooth(bass, 0.25));
    final period = _tempo(onset);
    final local = _localScore(onset, period);
    final beatFrames = _track(local, period);

    final strengths = _beatStrengths(local, beatFrames);
    return BeatMap(
      bpm: 60 * _fps / period,
      beats: Int32List.fromList([
        for (final f in beatFrames) (f * 1000 / _fps).round(),
      ]),
      strengths: strengths,
      energy: Uint8List.fromList([for (final e in energy) (e * 255).round()]),
      frame: Duration(microseconds: (_hop * 1e6 / sampleRate).round()),
    );
  }

  /// Per frame: positive log-spectral flux, and RMS of the bass band.
  static (Float64List, Float64List) _spectralFeatures(
    Float32List pcm,
    int frames,
  ) {
    final window = Float64List(_fft);
    for (var i = 0; i < _fft; i++) {
      window[i] = 0.5 - 0.5 * math.cos(2 * math.pi * i / _fft);
    }
    final fft = _Fft(_fft);
    final re = Float64List(_fft), im = Float64List(_fft);
    const bins = _fft ~/ 2;
    var previous = Float64List(bins), current = Float64List(bins);
    final onset = Float64List(frames), bass = Float64List(frames);

    for (var f = 0; f < frames; f++) {
      // Frame f is centred on sample f·hop.
      final start = f * _hop - _fft ~/ 2;
      for (var i = 0; i < _fft; i++) {
        final s = start + i;
        re[i] = s >= 0 && s < pcm.length ? pcm[s] * window[i] : 0;
        im[i] = 0;
      }
      fft.transform(re, im);
      var flux = 0.0, low = 0.0;
      for (var k = 1; k < bins; k++) {
        final power = re[k] * re[k] + im[k] * im[k];
        if (k <= _bassBins) low += power;
        current[k] = math.log(1 + 10 * math.sqrt(power));
        final rise = current[k] - previous[k];
        if (f > 0 && rise > 0) flux += rise;
      }
      onset[f] = flux;
      bass[f] = math.sqrt(low / _bassBins);
      final swap = previous;
      previous = current;
      current = swap;
    }

    // Remove the slowly varying part so only attacks remain, then scale to
    // unit standard deviation (the DP tightness assumes this).
    final mean = _movingAverage(onset, (_fps * 0.5).round());
    for (var f = 0; f < frames; f++) {
      onset[f] = math.max(0, onset[f] - mean[f]);
    }
    final sd = _std(onset);
    if (sd > 0) {
      for (var f = 0; f < frames; f++) {
        onset[f] /= sd;
      }
    }
    return (onset, bass);
  }

  /// Beat period in frames: the autocorrelation peak of the onset envelope,
  /// weighted towards 120 BPM to avoid half/double-tempo picks.
  static double _tempo(Float64List onset) {
    final minLag = (60 * _fps / 200).floor(); // 200 BPM
    final maxLag = (60 * _fps / 60).ceil(); // 60 BPM
    final ac = Float64List(maxLag + 2);
    final n = onset.length;
    for (var lag = minLag - 1; lag <= maxLag + 1; lag++) {
      var sum = 0.0;
      for (var i = lag; i < n; i++) {
        sum += onset[i] * onset[i - lag];
      }
      ac[lag] = sum / (n - lag);
    }
    var best = minLag;
    var bestScore = double.negativeInfinity;
    for (var lag = minLag; lag <= maxLag; lag++) {
      final bpm = 60 * _fps / lag;
      final octaves = math.log(bpm / 120) / math.ln2;
      final score = ac[lag] * math.exp(-0.5 * octaves * octaves);
      if (score > bestScore) {
        bestScore = score;
        best = lag;
      }
    }
    // Parabolic interpolation for sub-frame precision.
    final a = ac[best - 1], b = ac[best], c = ac[best + 1];
    final denom = a - 2 * b + c;
    final shift = denom == 0 ? 0.0 : (0.5 * (a - c) / denom).clamp(-0.5, 0.5);
    return best + shift;
  }

  /// Onset envelope smoothed with a Gaussian of width period/32.
  static Float64List _localScore(Float64List onset, double period) {
    final half = period.round();
    final sigma = period / 32;
    final kernel = [
      for (var i = -half; i <= half; i++)
        math.exp(-0.5 * math.pow(i / sigma, 2)),
    ];
    final out = Float64List(onset.length);
    for (var f = 0; f < onset.length; f++) {
      var sum = 0.0;
      for (var k = 0; k < kernel.length; k++) {
        final i = f + k - half;
        if (i >= 0 && i < onset.length) sum += onset[i] * kernel[k];
      }
      out[f] = sum;
    }
    return out;
  }

  /// Dynamic programming: each beat adds its onset score and pays for
  /// deviating from the tempo, `tightness · log(gap / period)²`.
  static List<int> _track(Float64List local, double period) {
    const tightness = 100.0;
    final n = local.length;
    final score = Float64List(n);
    final back = Int32List(n)..fillRange(0, n, -1);
    final from = (period * 2).round(), to = (period / 2).round();
    for (var t = 0; t < n; t++) {
      var best = 0.0;
      var arg = -1;
      for (var prev = t - from; prev <= t - to; prev++) {
        if (prev < 0) continue;
        final gap = math.log((t - prev) / period);
        final s = score[prev] - tightness * gap * gap;
        if (arg < 0 || s > best) {
          best = s;
          arg = prev;
        }
      }
      score[t] = local[t] + (arg >= 0 ? best : 0);
      back[t] = arg;
    }

    // End on the best-scoring local maximum in the last period.
    var end = n - 1;
    for (var t = math.max(0, n - period.ceil()); t < n; t++) {
      if (score[t] > score[end]) end = t;
    }
    final beats = <int>[];
    for (var t = end; t >= 0; t = back[t]) {
      beats.add(t);
    }
    final ordered = beats.reversed.toList();

    // Drop beats in silent intros and outros.
    final values = [for (final b in ordered) local[b]];
    final rms = math.sqrt(
      values.fold(0.0, (s, v) => s + v * v) / math.max(1, values.length),
    );
    var first = 0, last = ordered.length - 1;
    while (first <= last && local[ordered[first]] < 0.5 * rms) {
      first++;
    }
    while (last >= first && local[ordered[last]] < 0.5 * rms) {
      last--;
    }
    return ordered.sublist(first, last + 1);
  }

  /// Each beat's onset relative to the song's strong beats, perceptually
  /// compressed so quiet passages still pulse a little.
  static Uint8List _beatStrengths(Float64List local, List<int> beats) {
    if (beats.isEmpty) return Uint8List(0);
    final values = [for (final b in beats) local[b]]..sort();
    final top =
        values[(values.length * 0.9).floor().clamp(0, values.length - 1)];
    return Uint8List.fromList([
      for (final b in beats)
        top <= 0
            ? 0
            : (math.sqrt((local[b] / top).clamp(0.0, 1.0)) * 255).round(),
    ]);
  }

  static Float64List _movingAverage(Float64List x, int radius) {
    final out = Float64List(x.length);
    var sum = 0.0;
    var count = 0;
    var lo = 0, hi = -1;
    for (var i = 0; i < x.length; i++) {
      while (hi < math.min(x.length - 1, i + radius)) {
        sum += x[++hi];
        count++;
      }
      while (lo < i - radius) {
        sum -= x[lo++];
        count--;
      }
      out[i] = sum / count;
    }
    return out;
  }

  static Float64List _smooth(Float64List x, double alpha) {
    final out = Float64List(x.length);
    var y = x.isEmpty ? 0.0 : x[0];
    for (var i = 0; i < x.length; i++) {
      y += (x[i] - y) * alpha;
      out[i] = y;
    }
    return out;
  }

  /// Maps the 10th–97th percentile range onto 0–1.
  static Float64List _normalise(Float64List x) {
    final sorted = Float64List.fromList(x)..sort();
    final lo = sorted[(sorted.length * 0.10).floor()];
    final hi = sorted[(sorted.length * 0.97).floor()];
    final span = hi - lo;
    return Float64List.fromList([
      for (final v in x) span <= 0 ? 0.0 : ((v - lo) / span).clamp(0.0, 1.0),
    ]);
  }

  static double _std(Float64List x) {
    final mean = x.fold(0.0, (s, v) => s + v) / x.length;
    final variance =
        x.fold(0.0, (s, v) => s + (v - mean) * (v - mean)) / x.length;
    return math.sqrt(variance);
  }
}

/// In-place iterative radix-2 FFT.
class _Fft {
  _Fft(this.n)
    : _cos = Float64List(n ~/ 2),
      _sin = Float64List(n ~/ 2),
      _rev = Int32List(n) {
    for (var i = 0; i < n ~/ 2; i++) {
      _cos[i] = math.cos(2 * math.pi * i / n);
      _sin[i] = -math.sin(2 * math.pi * i / n);
    }
    final bits = (math.log(n) / math.ln2).round();
    for (var i = 0; i < n; i++) {
      var r = 0;
      for (var b = 0; b < bits; b++) {
        r |= ((i >> b) & 1) << (bits - 1 - b);
      }
      _rev[i] = r;
    }
  }

  final int n;
  final Float64List _cos, _sin;
  final Int32List _rev;

  void transform(Float64List re, Float64List im) {
    for (var i = 0; i < n; i++) {
      final j = _rev[i];
      if (j > i) {
        final tr = re[i];
        re[i] = re[j];
        re[j] = tr;
        final ti = im[i];
        im[i] = im[j];
        im[j] = ti;
      }
    }
    for (var size = 2; size <= n; size <<= 1) {
      final half = size >> 1, step = n ~/ size;
      for (var start = 0; start < n; start += size) {
        for (var k = 0; k < half; k++) {
          final wr = _cos[k * step], wi = _sin[k * step];
          final a = start + k, b = a + half;
          final xr = re[b] * wr - im[b] * wi;
          final xi = re[b] * wi + im[b] * wr;
          re[b] = re[a] - xr;
          im[b] = im[a] - xi;
          re[a] += xr;
          im[a] += xi;
        }
      }
    }
  }
}
