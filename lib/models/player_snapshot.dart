import 'package:freezed_annotation/freezed_annotation.dart';

import 'api_error.dart';
import 'track.dart';

part 'player_snapshot.freezed.dart';

/// States exposed by `PlayerController`, per the requirements doc.
enum PlaybackStatus {
  idle,
  loading,
  buffering,
  playing,
  paused,
  completed,
  error,
}

enum QueueRepeat { off, all, one }

extension QueueRepeatLabel on QueueRepeat {
  String get label => switch (this) {
    QueueRepeat.off => 'Repetir: apagado',
    QueueRepeat.all => 'Repetir: todas',
    QueueRepeat.one => 'Repetir: una',
  };
}

@freezed
sealed class SleepTimer with _$SleepTimer {
  const factory SleepTimer.minutes(int minutes) = SleepAfterMinutes;
  const factory SleepTimer.endOfTrack() = SleepAtEndOfTrack;
}

@freezed
abstract class PlayerSnapshot with _$PlayerSnapshot {
  const PlayerSnapshot._();

  const factory PlayerSnapshot({
    @Default(<Track>[]) List<Track> queue,
    @Default(0) int index,

    /// How many tracks after [index] were added with "play next".
    @Default(0) int upNext,
    @Default(PlaybackStatus.idle) PlaybackStatus status,
    @Default(false) bool shuffle,
    @Default(QueueRepeat.off) QueueRepeat repeat,
    SleepTimer? sleep,
    @Default('Cola') String sourceLabel,
    ApiException? error,
  }) = _PlayerSnapshot;

  Track? get current =>
      index >= 0 && index < queue.length ? queue[index] : null;

  bool get isPlaying => status == PlaybackStatus.playing;

  bool get isBusy =>
      status == PlaybackStatus.loading || status == PlaybackStatus.buffering;

  List<Track> get playingNext => queue.skip(index + 1).take(upNext).toList();

  List<Track> get later => queue.skip(index + 1 + upNext).toList();
}
