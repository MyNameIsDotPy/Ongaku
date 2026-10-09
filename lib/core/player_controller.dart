import '../models/player_snapshot.dart';
import '../models/track.dart';

/// Queue and playback. In the real core this wraps `just_audio` +
/// `audio_service`; the UI only depends on this contract.
abstract interface class PlayerController {
  PlayerSnapshot get snapshot;
  Stream<PlayerSnapshot> get snapshots;
  bool get playWhenReady;

  Duration get position;
  Stream<Duration> get positions;

  void play(List<Track> tracks, {int start = 0, String? sourceLabel});
  void toggle();
  void resume();
  void pause();
  void stop();
  void next();
  void previous();
  void seek(Duration position);
  void toggleShuffle();
  void cycleRepeat();
  void playNext(Track track);
  void addToQueue(Track track);
  void jumpTo(int index);
  void removeAt(int index);
  void move(int from, int to);

  /// Drops everything after the current track.
  void clearUpcoming();
  void setSleepTimer(SleepTimer? timer);

  /// Output level, 0–1 (desktop bar).
  double get volume;
  void setVolume(double volume);
  void dispose();
}
