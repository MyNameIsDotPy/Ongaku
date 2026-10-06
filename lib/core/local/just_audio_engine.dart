import 'dart:async';

import 'package:just_audio/just_audio.dart';

import '../../models/api_error.dart';
import '../../models/app_settings.dart';
import '../../models/track.dart';
import '../player/playback_engine.dart';
import 'stream_resolver.dart';

/// Real audio through just_audio (ExoPlayer on Android, media_kit/libmpv on
/// Windows and Linux). Interruptions and unplugged headphones pause
/// playback via the audio session (RF-13).
class JustAudioEngine implements PlaybackEngine {
  JustAudioEngine(this._resolver, {required this.quality}) {
    _subs = [
      _player.errorStream.listen(_onError),
      _player.processingStateStream
          .where((s) => s == ProcessingState.completed)
          .listen((_) => _completed.add(null)),
      _player.playerStateStream
          .map(
            (s) => s.playing && s.processingState == ProcessingState.buffering,
          )
          .distinct()
          .listen(_buffering.add),
    ];
  }

  final StreamResolver _resolver;

  /// Wi-Fi or mobile-data quality, read at load time (RNF-07).
  final AudioQuality Function() quality;

  final _player = AudioPlayer();
  late final List<StreamSubscription<Object?>> _subs;
  late final Stream<Duration> _positions = _player
      .createPositionStream(
        minPeriod: const Duration(milliseconds: 100),
        maxPeriod: const Duration(milliseconds: 200),
      )
      .asBroadcastStream();
  final _completed = StreamController<void>.broadcast();
  final _buffering = StreamController<bool>.broadcast();
  final _errors = StreamController<Object>.broadcast();
  Track? _track;
  bool _retried = false;

  @override
  Duration get position => _player.position;
  @override
  Stream<Duration> get positions => _positions;
  @override
  Stream<void> get completed => _completed.stream;
  @override
  Stream<bool> get buffering => _buffering.stream;
  @override
  Stream<Object> get errors => _errors.stream;

  @override
  Future<void> load(Track track, {Duration from = Duration.zero}) async {
    _track = track;
    _retried = false;
    try {
      await _setSource(track, from);
    } on ApiException {
      rethrow;
    } catch (_) {
      // Most often an expired or blocked URL: resolve again once.
      _resolver.invalidate(track);
      try {
        await _setSource(track, from);
      } on ApiException {
        rethrow;
      } catch (e) {
        throw ApiException(ApiErrorCode.extractionFailed, '$e');
      }
    }
  }

  Future<void> _setSource(Track track, Duration from) async {
    final uri = await _resolver.resolve(track, quality: quality());
    if (_track != track) return; // superseded by a newer load
    await _player.setAudioSource(
      AudioSource.uri(uri, tag: track.videoId),
      initialPosition: from,
    );
  }

  Future<void> _onError(PlayerException e) async {
    final track = _track;
    if (track == null) return;
    if (!_retried) {
      _retried = true;
      final at = _player.position;
      _resolver.invalidate(track);
      try {
        await _setSource(track, at);
        unawaited(_player.play());
        return;
      } catch (_) {}
    }
    _errors.add(ApiException(ApiErrorCode.extractionFailed, e.message));
  }

  /// `AudioPlayer.play()` completes only when playback stops; don't await.
  @override
  Future<void> play() async => unawaited(_player.play());

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() async {
    for (final s in _subs) {
      await s.cancel();
    }
    await _player.dispose();
    await Future.wait([
      _completed.close(),
      _buffering.close(),
      _errors.close(),
    ]);
  }
}
