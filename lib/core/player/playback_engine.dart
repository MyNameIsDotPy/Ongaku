import '../../models/track.dart';

/// Plays one track at a time. [QueuePlayerController] owns the queue and
/// the state machine; engines only load, play and report progress.
abstract interface class PlaybackEngine {
  /// Prepares [track] at [from]. Throws `ApiException` when it cannot play.
  Future<void> load(Track track, {Duration from = Duration.zero});
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> stop();

  Duration get position;

  /// Periodic position updates while playing.
  Stream<Duration> get positions;

  /// True while stalled mid-playback waiting for data.
  Stream<bool> get buffering;

  /// Native play/pause changes, including audio focus and unplugged headsets.
  Stream<bool> get playing;

  /// The loaded track reached its end.
  Stream<void> get completed;

  /// Playback failed after loading (e.g. the stream URL expired).
  Stream<Object> get errors;

  Future<void> dispose();
}
