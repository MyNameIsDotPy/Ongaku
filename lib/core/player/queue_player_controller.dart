import 'dart:async';
import 'dart:math';

import '../../models/api_error.dart';
import '../../models/player_snapshot.dart';
import '../../models/track.dart';
import '../player_controller.dart';
import 'playback_engine.dart';

/// [PlayerController] with the full queue state machine (RF-08/09/12/16/17,
/// RNF-12): idle → loading → playing ⇄ paused, buffering on seek and stalls,
/// error → skip to the next track, completed at the end of the queue.
class QueuePlayerController implements PlayerController {
  QueuePlayerController(
    this._engine, {
    List<Track> restoredQueue = const [],
    int restoredIndex = 0,
    Duration resumeAt = Duration.zero,
    String sourceLabel = 'Cola',
    // Named parameters cannot be private initializing formals.
    // ignore: prefer_initializing_formals
  }) : _resumeAt = resumeAt,
       _snapshot = PlayerSnapshot(
         queue: restoredQueue,
         index: restoredQueue.isEmpty
             ? 0
             : restoredIndex.clamp(0, restoredQueue.length - 1),
         sourceLabel: sourceLabel,
       ) {
    _subs = [
      _engine.positions.listen(_onPosition),
      _engine.completed.listen((_) => _advance(auto: true)),
      _engine.buffering.listen(_onBuffering),
      _engine.errors.listen((e) => _fail(_snapshot.current, e)),
    ];
  }

  final PlaybackEngine _engine;
  late final List<StreamSubscription<Object?>> _subs;
  PlayerSnapshot _snapshot;
  final _snapshots = StreamController<PlayerSnapshot>.broadcast();
  final _positions = StreamController<Duration>.broadcast();
  List<Track>? _unshuffled;
  Timer? _skipTimer;
  Timer? _sleepTimer;
  int _loadToken = 0;

  /// Where a restored (idle) queue resumes.
  Duration _resumeAt;

  @override
  PlayerSnapshot get snapshot => _snapshot;

  @override
  Stream<PlayerSnapshot> get snapshots => _snapshots.stream;

  @override
  Duration get position =>
      _snapshot.status == PlaybackStatus.idle ? _resumeAt : _engine.position;

  @override
  Stream<Duration> get positions => _positions.stream;

  void _set(PlayerSnapshot next) {
    _snapshot = next;
    if (!_snapshots.isClosed) _snapshots.add(next);
  }

  void _setStatus(PlaybackStatus s, {ApiException? error}) =>
      _set(_snapshot.copyWith(status: s, error: error));

  void _onPosition(Duration p) {
    if (!_positions.isClosed) _positions.add(p);
    final cur = _snapshot.current;
    if (cur != null &&
        _snapshot.isPlaying &&
        _snapshot.sleep is SleepAtEndOfTrack &&
        p >= cur.duration - const Duration(milliseconds: 300)) {
      _engine.pause();
      _set(_snapshot.copyWith(status: PlaybackStatus.paused, sleep: null));
    }
  }

  void _onBuffering(bool stalled) {
    if (stalled && _snapshot.isPlaying) _setStatus(PlaybackStatus.buffering);
    if (!stalled && _snapshot.status == PlaybackStatus.buffering) {
      _setStatus(PlaybackStatus.playing);
    }
  }

  Future<void> _load([Duration from = Duration.zero]) async {
    final track = _snapshot.current;
    if (track == null) return;
    final token = ++_loadToken;
    _skipTimer?.cancel();
    _setStatus(PlaybackStatus.loading);
    if (!_positions.isClosed) _positions.add(from);
    try {
      await _engine.load(track, from: from);
      if (token != _loadToken) return;
      _setStatus(PlaybackStatus.playing);
      await _engine.play();
    } catch (e) {
      if (token == _loadToken) _fail(track, e);
    }
  }

  /// RNF-12: warn and jump to the next song without stopping the queue.
  void _fail(Track? track, Object e) {
    final api = e is ApiException
        ? e
        : ApiException(ApiErrorCode.extractionFailed, '$e');
    final message =
        '“${track?.title ?? 'La canción'}” no está disponible. '
        'Saltando a la siguiente.';
    _setStatus(PlaybackStatus.error, error: ApiException(api.code, message));
    _skipTimer = Timer(const Duration(milliseconds: 1600), next);
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
      case PlaybackStatus.playing || PlaybackStatus.buffering:
        _engine.pause();
        _setStatus(PlaybackStatus.paused);
      case PlaybackStatus.paused:
        _setStatus(PlaybackStatus.playing);
        _engine.play();
      case PlaybackStatus.idle:
        _load(_resumeAt);
      case PlaybackStatus.completed:
        _set(_snapshot.copyWith(index: 0));
        _load();
      case PlaybackStatus.loading || PlaybackStatus.error:
        break;
    }
  }

  @override
  void seek(Duration to) {
    final d = _snapshot.current?.duration ?? Duration.zero;
    final target = Duration(
      milliseconds: to.inMilliseconds.clamp(0, max(0, d.inMilliseconds - 500)),
    );
    if (_snapshot.status == PlaybackStatus.idle) {
      _resumeAt = target;
      if (!_positions.isClosed) _positions.add(target);
      return;
    }
    final wasPlaying = _snapshot.isPlaying;
    if (wasPlaying) _setStatus(PlaybackStatus.buffering);
    _engine.seek(target).then((_) {
      if (!_positions.isClosed) _positions.add(target);
      if (wasPlaying && _snapshot.status == PlaybackStatus.buffering) {
        _setStatus(PlaybackStatus.playing);
      }
    });
  }

  @override
  void next() => _advance();

  void _advance({bool auto = false}) {
    if (auto && _snapshot.repeat == QueueRepeat.one) {
      _load();
      return;
    }
    final s = _snapshot;
    final upNext = max(0, s.upNext - 1);
    if (s.index < s.queue.length - 1) {
      _set(s.copyWith(index: s.index + 1, upNext: upNext));
      _load();
    } else if (s.repeat == QueueRepeat.all) {
      _set(s.copyWith(index: 0, upNext: upNext));
      _load();
    } else {
      _loadToken++;
      _skipTimer?.cancel();
      _engine.stop();
      if (!_positions.isClosed) _positions.add(Duration.zero);
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
    q.insert(to, q.removeAt(from));
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
    _skipTimer?.cancel();
    _sleepTimer?.cancel();
    for (final s in _subs) {
      s.cancel();
    }
    _engine.dispose();
    _snapshots.close();
    _positions.close();
  }
}
