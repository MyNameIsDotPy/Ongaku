import 'dart:async';

import 'package:just_audio/just_audio.dart';

import '../../models/api_error.dart';
import '../../models/app_settings.dart';
import '../../models/track.dart';
import '../player/playback_engine.dart';
import 'stream_resolver.dart';
import 'youtube_audio_source.dart';

/// Real audio through just_audio (ExoPlayer on Android, media_kit on desktop).
/// Each load owns its retries; superseded requests can never restart playback.
class JustAudioEngine implements PlaybackEngine {
  JustAudioEngine(this._resolver, {required this.quality, AudioPlayer? player})
    : _player = player ?? AudioPlayer(useProxyForRequestHeaders: false) {
    _subs = [
      _player.errorStream.listen(_onError),
      _player.processingStateStream
          .where((s) => s == ProcessingState.completed)
          .listen((_) {
            if (!_loading && !_recovering && _track != null) {
              _completed.add(null);
            }
          }),
      _player.playerStateStream.listen((s) {
        if (_loading || _recovering || _track == null) return;
        _wantsToPlay = s.playing;
        _playing.add(s.playing);
        _buffering.add(
          s.playing && s.processingState == ProcessingState.buffering,
        );
      }),
    ];
  }

  final StreamResolver _resolver;
  final AudioQuality Function() quality;
  final AudioPlayer _player;
  late final List<StreamSubscription<Object?>> _subs;
  late final Stream<Duration> _positions = _player
      .createPositionStream(
        minPeriod: const Duration(milliseconds: 100),
        maxPeriod: const Duration(milliseconds: 200),
      )
      .asBroadcastStream();
  final _completed = StreamController<void>.broadcast();
  final _buffering = StreamController<bool>.broadcast();
  final _playing = StreamController<bool>.broadcast();
  final _errors = StreamController<Object>.broadcast();
  Track? _track;
  YoutubeAudioSource? _source;
  int _generation = 0;
  bool _loading = false;
  bool _recovering = false;
  bool _retried = false;
  bool _wantsToPlay = false;
  bool _disposed = false;

  bool _current(int generation) => !_disposed && generation == _generation;

  @override
  Duration get position => _player.position;
  @override
  Stream<Duration> get positions => _positions;
  @override
  Stream<void> get completed => _completed.stream;
  @override
  Stream<bool> get buffering => _buffering.stream;
  @override
  Stream<bool> get playing => _playing.stream;
  @override
  Stream<Object> get errors => _errors.stream;

  @override
  Future<void> load(Track track, {Duration from = Duration.zero}) async {
    final generation = ++_generation;
    _track = track;
    _loading = true;
    _recovering = false;
    _retried = false;
    _wantsToPlay = false;
    try {
      // Silence the previous track while resolving the next one.
      await _player.pause();
      if (!_current(generation)) return;
      try {
        await _setSource(track, from, generation);
      } on ApiException {
        rethrow;
      } on PlayerInterruptedException {
        // Native loads are interrupted by skip, stop, or disposal.
        if (_current(generation)) rethrow;
      } catch (_) {
        if (!_current(generation)) return;
        _retried = true;
        await _setSource(track, from, generation);
      }
    } catch (e) {
      if (_current(generation)) {
        throw e is ApiException
            ? e
            : ApiException(ApiErrorCode.extractionFailed, '$e');
      }
    } finally {
      if (_current(generation)) _loading = false;
    }
  }

  Future<void> _setSource(Track track, Duration from, int generation) async {
    final uri = await _resolver.resolve(track, quality: quality());
    if (!_current(generation)) return;
    final length = int.tryParse(uri.queryParameters['clen'] ?? '');
    final source =
        uri.scheme == 'https' &&
            uri.host.endsWith('.googlevideo.com') &&
            length != null &&
            length > 0
        ? YoutubeAudioSource(uri, length: length, tag: track.videoId)
        : AudioSource.uri(uri, tag: track.videoId);
    _source?.close();
    _source = source is YoutubeAudioSource ? source : null;
    await _player.setAudioSource(source, initialPosition: from);
  }

  void _onError(PlayerException e) {
    // setAudioSource also throws this error. Only load() may retry it.
    if (_loading || _recovering || _disposed || _track == null) return;
    unawaited(_recover(e, _generation));
  }

  Future<void> _recover(Object error, int generation) async {
    if (!_current(generation) || _loading || _recovering) return;
    final track = _track;
    if (track == null) return;
    if (_retried) {
      _wantsToPlay = false;
      _errors.add(ApiException(ApiErrorCode.extractionFailed, '$error'));
      return;
    }
    _retried = true;
    _recovering = true;
    final at = _player.position;
    _buffering.add(_wantsToPlay);
    try {
      await _player.pause();
      if (!_current(generation)) return;
      await _setSource(track, at, generation);
      if (!_current(generation)) return;
      _recovering = false;
      _buffering.add(false);
      if (_wantsToPlay) await play();
    } catch (e) {
      if (_current(generation)) {
        _wantsToPlay = false;
        _errors.add(
          e is ApiException
              ? e
              : ApiException(ApiErrorCode.extractionFailed, '$e'),
        );
      }
    } finally {
      if (_current(generation)) _recovering = false;
    }
  }

  /// play() completes when playback stops, so observe errors without awaiting it.
  @override
  Future<void> play() async {
    if (_disposed || _track == null) return;
    _wantsToPlay = true;
    if (_loading || _recovering) return;
    final generation = _generation;
    unawaited(
      _player.play().catchError((Object e) async {
        if (_current(generation)) await _recover(e, generation);
      }),
    );
  }

  @override
  Future<void> pause() async {
    _wantsToPlay = false;
    await _player.pause();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    ++_generation;
    _track = null;
    _loading = false;
    _recovering = false;
    _wantsToPlay = false;
    _source?.close();
    _source = null;
    await _player.stop();
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    ++_generation;
    for (final s in _subs) {
      await s.cancel();
    }
    _source?.close();
    await _player.dispose();
    await Future.wait([
      _completed.close(),
      _buffering.close(),
      _playing.close(),
      _errors.close(),
    ]);
  }
}
