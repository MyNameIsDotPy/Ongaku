import 'dart:async';
import 'dart:math';

import '../../models/api_error.dart';
import '../../models/player_snapshot.dart';
import '../../models/track.dart';
import '../player_controller.dart';

/// Simulated player that follows the `PlayerController` state contract
/// (idle → loading → playing ⇄ paused, buffering on seek, error → skip,
/// completed at the end of the queue) with a wall clock instead of audio.
class FakePlayerController implements PlayerController {
  FakePlayerController({List<Track> restoredQueue = const []})
    : _snapshot = PlayerSnapshot(
        queue: restoredQueue,
        sourceLabel: 'Para TransMilenio',
      ) {
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) => _tick());
  }

  static const _loadDelay = Duration(milliseconds: 420);
  static const _seekDelay = Duration(milliseconds: 240);

  PlayerSnapshot _snapshot;
  final _snapshots = StreamController<PlayerSnapshot>.broadcast();
  final _positions = StreamController<Duration>.broadcast();
  late final Timer _ticker;
  Timer? _pending;
  Timer? _sleepTimer;
  List<Track>? _unshuffled;

  final _clock = Stopwatch();
  Duration _base = Duration.zero;

  @override
  PlayerSnapshot get snapshot => _snapshot;

  @override
  Stream<PlayerSnapshot> get snapshots => _snapshots.stream;

  @override
  Duration get position {
    final p = _base + _clock.elapsed;
    final d = _snapshot.current?.duration ?? Duration.zero;
    return p > d ? d : p;
  }

  @override
  Stream<Duration> get positions => _positions.stream;

  void _set(PlayerSnapshot next) {
    _snapshot = next;
    _snapshots.add(next);
  }

  void _setStatus(PlaybackStatus s, {ApiException? error}) =>
      _set(_snapshot.copyWith(status: s, error: error));

  void _setPosition(Duration p, {bool running = false}) {
    _base = p;
    _clock
      ..reset()
      ..stop();
    if (running) _clock.start();
    _positions.add(p);
  }

  void _load([Duration from = Duration.zero]) {
    final track = _snapshot.current;
    if (track == null) return;
    _pending?.cancel();
    _setPosition(from);
    _setStatus(PlaybackStatus.loading);
    _pending = Timer(_loadDelay, () {
      if (track.unavailable) {
        _setStatus(
          PlaybackStatus.error,
          error: ApiException(
            ApiErrorCode.unavailable,
            '“${track.title}” no está disponible. Saltando a la siguiente.',
          ),
        );
        _pending = Timer(const Duration(milliseconds: 1600), next);
        return;
      }
      _setPosition(from, running: true);
      _setStatus(PlaybackStatus.playing);
    });
  }

  void _tick() {
    if (_snapshot.status != PlaybackStatus.playing) return;
    final pos = position;
    _positions.add(pos);
    final d = _snapshot.current!.duration;
    if (_snapshot.sleep is SleepAtEndOfTrack &&
        pos >= d - const Duration(milliseconds: 300)) {
      _setPosition(Duration.zero);
      _set(_snapshot.copyWith(status: PlaybackStatus.paused, sleep: null));
      return;
    }
    if (pos >= d) _advance(auto: true);
  }

  @override
  void play(List<Track> tracks, {int start = 0, String? sourceLabel}) {
    if (tracks.isEmpty) return;
    _unshuffled = null;
    _set(
      _snapshot.copyWith(
        queue: List.of(tracks),
        index: start.clamp(0, tracks.length - 1),
        upNext: 0,
        sourceLabel: sourceLabel ?? _snapshot.sourceLabel,
      ),
    );
    if (_snapshot.shuffle) _shuffleRest();
    _load();
  }

  @override
  void toggle() {
    if (_snapshot.current == null) return;
    switch (_snapshot.status) {
      case PlaybackStatus.playing:
        _setPosition(position);
        _setStatus(PlaybackStatus.paused);
      case PlaybackStatus.paused:
        _setPosition(_base, running: true);
        _setStatus(PlaybackStatus.playing);
      case PlaybackStatus.idle:
        _load(_base);
      case PlaybackStatus.completed:
        _set(_snapshot.copyWith(index: 0));
        _load();
      case PlaybackStatus.loading ||
          PlaybackStatus.buffering ||
          PlaybackStatus.error:
        break;
    }
  }

  @override
  void seek(Duration to) {
    final d = _snapshot.current?.duration ?? Duration.zero;
    final target = Duration(
      milliseconds: to.inMilliseconds.clamp(0, max(0, d.inMilliseconds - 500)),
    );
    if (_snapshot.status != PlaybackStatus.playing) {
      _setPosition(target);
      return;
    }
    _setPosition(target);
    _setStatus(PlaybackStatus.buffering);
    _pending?.cancel();
    _pending = Timer(_seekDelay, () {
      _setPosition(target, running: true);
      _setStatus(PlaybackStatus.playing);
    });
  }

  @override
  void next() => _advance();

  void _advance({bool auto = false}) {
    if (auto && _snapshot.repeat == QueueRepeat.one) return _load();
    final s = _snapshot;
    final upNext = max(0, s.upNext - 1);
    if (s.index < s.queue.length - 1) {
      _set(s.copyWith(index: s.index + 1, upNext: upNext));
      _load();
    } else if (s.repeat == QueueRepeat.all) {
      _set(s.copyWith(index: 0, upNext: upNext));
      _load();
    } else {
      _pending?.cancel();
      _setPosition(Duration.zero);
      _set(s.copyWith(status: PlaybackStatus.completed, upNext: 0));
    }
  }

  @override
  void previous() {
    if (position > const Duration(seconds: 3) || _snapshot.index == 0) {
      _snapshot.isPlaying ? seek(Duration.zero) : _load();
      return;
    }
    _set(_snapshot.copyWith(index: _snapshot.index - 1));
    _load();
  }

  void _shuffleRest() {
    final s = _snapshot;
    _unshuffled = List.of(s.queue);
    final rest = s.queue.sublist(s.index + 1)..shuffle(Random());
    _set(s.copyWith(queue: [...s.queue.take(s.index + 1), ...rest]));
  }

  @override
  void toggleShuffle() {
    final on = !_snapshot.shuffle;
    _set(_snapshot.copyWith(shuffle: on));
    if (on) {
      _shuffleRest();
    } else if (_unshuffled != null) {
      final cur = _snapshot.current;
      final original = _unshuffled!;
      _unshuffled = null;
      _set(
        _snapshot.copyWith(
          queue: original,
          index: max(0, original.indexWhere((t) => t.videoId == cur?.videoId)),
        ),
      );
    }
  }

  @override
  void cycleRepeat() => _set(
    _snapshot.copyWith(
      repeat: switch (_snapshot.repeat) {
        QueueRepeat.off => QueueRepeat.all,
        QueueRepeat.all => QueueRepeat.one,
        QueueRepeat.one => QueueRepeat.off,
      },
    ),
  );

  @override
  void playNext(Track track) {
    final s = _snapshot;
    if (s.queue.isEmpty) return play([track]);
    final q = List.of(s.queue)..insert(s.index + 1 + s.upNext, track);
    _set(s.copyWith(queue: q, upNext: s.upNext + 1));
  }

  @override
  void addToQueue(Track track) {
    if (_snapshot.queue.isEmpty) return play([track]);
    _set(_snapshot.copyWith(queue: [..._snapshot.queue, track]));
  }

  @override
  void jumpTo(int index) {
    if (index < 0 || index >= _snapshot.queue.length) return;
    final s = _snapshot;
    final upNext = index > s.index && index <= s.index + s.upNext
        ? s.index + s.upNext - index
        : 0;
    _set(s.copyWith(index: index, upNext: upNext));
    _load();
  }

  @override
  void removeAt(int i) {
    final s = _snapshot;
    if (i == s.index || i < 0 || i >= s.queue.length) return;
    final q = List.of(s.queue)..removeAt(i);
    _set(
      s.copyWith(
        queue: q,
        index: i < s.index ? s.index - 1 : s.index,
        upNext: i > s.index && i <= s.index + s.upNext
            ? max(0, s.upNext - 1)
            : s.upNext,
      ),
    );
  }

  @override
  void move(int from, int to) {
    final s = _snapshot;
    final q = List.of(s.queue);
    final t = q.removeAt(from);
    q.insert(to, t);
    var index = s.index;
    if (from == s.index) {
      index = to;
    } else if (from < s.index && to >= s.index) {
      index--;
    } else if (from > s.index && to <= s.index) {
      index++;
    }
    _set(s.copyWith(queue: q, index: index));
  }

  @override
  void clearUpcoming() => _set(
    _snapshot.copyWith(
      queue: _snapshot.queue.take(_snapshot.index + 1).toList(),
      upNext: 0,
    ),
  );

  @override
  void setSleepTimer(SleepTimer? timer) {
    _sleepTimer?.cancel();
    _set(_snapshot.copyWith(sleep: timer));
    if (timer case SleepAfterMinutes(:final minutes)) {
      _sleepTimer = Timer(Duration(minutes: minutes), () {
        if (_snapshot.isPlaying) toggle();
        _set(_snapshot.copyWith(sleep: null));
      });
    }
  }

  @override
  void dispose() {
    _ticker.cancel();
    _pending?.cancel();
    _sleepTimer?.cancel();
    _snapshots.close();
    _positions.close();
  }
}
