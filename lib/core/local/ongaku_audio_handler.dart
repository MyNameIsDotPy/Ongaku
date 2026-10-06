import 'dart:async';

import 'package:audio_service/audio_service.dart';

import '../../models/player_snapshot.dart';
import '../player_controller.dart';

/// Bridges [PlayerController] to the OS media session: notification, lock
/// screen, Bluetooth and headset buttons (RF-12). The foreground service
/// keeps playback alive with the screen off (RF-11, RNF-04).
class OngakuAudioHandler extends BaseAudioHandler with SeekHandler {
  PlayerController? _player;
  final _subs = <StreamSubscription<Object?>>[];
  Duration _lastReported = Duration.zero;
  DateTime _reportedAt = DateTime.now();

  void attach(PlayerController player) {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    _player = player;
    _subs
      ..add(player.snapshots.listen(_publish))
      ..add(player.positions.listen(_onPosition));
    _publish(player.snapshot);
  }

  void _publish(PlayerSnapshot s) {
    final playing = _player?.playWhenReady ?? false;
    final t = s.current;
    if (t != null && mediaItem.value?.id != t.videoId) {
      mediaItem.add(
        MediaItem(
          id: t.videoId,
          title: t.title,
          artist: t.artistNames,
          album: t.album?.name,
          duration: t.duration,
          artUri: t.coverUrl.startsWith('http') ? Uri.parse(t.coverUrl) : null,
        ),
      );
    }
    final position = _player?.position ?? Duration.zero;
    _lastReported = position;
    _reportedAt = DateTime.now();
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {MediaAction.seek},
        androidCompactActionIndices: const [0, 1, 2],
        processingState: switch (s.status) {
          PlaybackStatus.idle => AudioProcessingState.idle,
          PlaybackStatus.loading => AudioProcessingState.loading,
          PlaybackStatus.buffering => AudioProcessingState.buffering,
          PlaybackStatus.playing ||
          PlaybackStatus.paused => AudioProcessingState.ready,
          PlaybackStatus.completed => AudioProcessingState.completed,
          PlaybackStatus.error => AudioProcessingState.error,
        },
        playing: playing,
        updatePosition: position,
        queueIndex: s.index,
        errorMessage: s.error?.message,
      ),
    );
  }

  /// The OS extrapolates the position; only re-sync after jumps (seeks).
  void _onPosition(Duration p) {
    final s = _player?.snapshot;
    if (s == null) return;
    final expected = s.isPlaying
        ? _lastReported + DateTime.now().difference(_reportedAt)
        : _lastReported;
    if ((p - expected).abs() > const Duration(milliseconds: 1500)) _publish(s);
  }

  @override
  Future<void> play() async {
    _player?.resume();
  }

  @override
  Future<void> pause() async {
    _player?.pause();
  }

  @override
  Future<void> stop() async => _player?.stop();

  @override
  Future<void> skipToNext() async => _player?.next();

  @override
  Future<void> skipToPrevious() async => _player?.previous();

  @override
  Future<void> seek(Duration position) async => _player?.seek(position);
}
