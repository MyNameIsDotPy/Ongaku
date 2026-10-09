import 'dart:async';

import '../../models/api_error.dart';
import '../../models/track.dart';
import 'playback_engine.dart';

/// Wall-clock engine for the sample catalog and tests: no audio, but the
/// same timing as a real player (420 ms to load, 240 ms to seek).
class SimulatedEngine implements PlaybackEngine {
  SimulatedEngine() {
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) => _tick());
  }

  late final Timer _ticker;
  final _clock = Stopwatch();
  Duration _base = Duration.zero;
  Track? _track;
  bool _ended = false;

  final _positions = StreamController<Duration>.broadcast();
  final _completed = StreamController<void>.broadcast();
  final _buffering = StreamController<bool>.broadcast();
  final _errors = StreamController<Object>.broadcast();

  @override
  Duration get position {
    final p = _base + _clock.elapsed;
    final d = _track?.duration ?? Duration.zero;
    return p > d ? d : p;
  }

  @override
  Stream<Duration> get positions => _positions.stream;
  @override
  Stream<void> get completed => _completed.stream;
  @override
  Stream<bool> get buffering => _buffering.stream;

  @override
  Stream<bool> get playing => const Stream.empty();
  @override
  Stream<Object> get errors => _errors.stream;

  void _tick() {
    if (!_clock.isRunning || _track == null) return;
    final p = position;
    _positions.add(p);
    if (p >= _track!.duration && !_ended) {
      _ended = true;
      _clock.stop();
      _completed.add(null);
    }
  }

  @override
  Future<void> load(Track track, {Duration from = Duration.zero}) async {
    _clock
      ..stop()
      ..reset();
    _track = track;
    _base = from;
    _ended = false;
    await Future<void>.delayed(const Duration(milliseconds: 420));
    if (track.unavailable) throw const ApiException(ApiErrorCode.unavailable);
  }

  @override
  Future<void> play() async => _clock.start();

  @override
  Future<void> pause() async {
    _base = position;
    _clock
      ..stop()
      ..reset();
  }

  @override
  Future<void> seek(Duration to) async {
    final running = _clock.isRunning;
    _clock
      ..stop()
      ..reset();
    _base = to;
    _ended = false;
    if (running) {
      await Future<void>.delayed(const Duration(milliseconds: 240));
      _clock.start();
    }
  }

  double _volume = 1;

  @override
  double get volume => _volume;
  @override
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
  }

  @override
  Future<void> stop() async {
    _clock
      ..stop()
      ..reset();
    _base = Duration.zero;
  }

  @override
  Future<void> dispose() async {
    _ticker.cancel();
    await Future.wait([
      _positions.close(),
      _completed.close(),
      _buffering.close(),
      _errors.close(),
    ]);
  }
}
