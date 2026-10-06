import '../../models/track.dart';

/// Decides when a play goes into the history (RF-21): after 30 s of actual
/// listening, or 80 % of a shorter song. Skipped songs don't count, and
/// pausing doesn't reset the time already listened.
class PlayCounter {
  PlayCounter({
    this.threshold = const Duration(seconds: 30),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final Duration threshold;
  final DateTime Function() _now;

  Track? _track;
  Duration _listened = Duration.zero;
  DateTime? _since;
  bool _counted = false;

  /// Feed every player change and a periodic tick. Returns the track exactly
  /// once, when its play should be recorded.
  Track? update(Track? current, {required bool playing}) {
    final now = _now();
    if (_since != null) _listened += now.difference(_since!);
    _since = null;
    if (current?.videoId != _track?.videoId) {
      _track = current;
      _listened = Duration.zero;
      _counted = false;
    }
    if (current == null) return null;
    if (playing) _since = now;
    if (_counted || _listened < _needed(current)) return null;
    _counted = true;
    return current;
  }

  Duration _needed(Track t) {
    final short = t.duration * 0.8;
    return t.duration > Duration.zero && short < threshold ? short : threshold;
  }
}
