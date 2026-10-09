import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/catalog_repository.dart';
import '../core/local/local_catalog_repository.dart';
import '../core/player/play_counter.dart';
import '../core/player_controller.dart';
import '../models/app_settings.dart';
import '../models/player_snapshot.dart';
import '../models/track.dart';
import 'library_providers.dart';
import 'player_persistence.dart';
import 'repository_providers.dart';

/// Mirrors `PlayerController` snapshots and exposes its commands. Records a
/// play in the history after 30 s of listening (RF-21).
class PlayerNotifier extends Notifier<PlayerSnapshot> {
  @override
  PlayerSnapshot build() {
    final controller = ref.watch(playerControllerProvider);
    final local = ref.watch(musicSourceProvider) == MusicSource.youtube;
    final counter = PlayCounter();
    void count(PlayerSnapshot s) {
      final played = counter.update(s.current, playing: s.isPlaying);
      if (played != null) ref.read(libraryProvider.notifier).recordPlay(played);
    }

    final sub = controller.snapshots.listen((s) {
      final previous = state;
      state = s;
      count(s);
      if (local) {
        final catalog = ref.read(catalogRepositoryProvider);
        if (catalog is LocalCatalogRepository && s.current != null) {
          catalog.remember(s.current!);
        }
        if (previous.current != s.current || previous.status != s.status) {
          saveQueue(ref, s, controller.position);
        }
      }
    });
    final ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => count(state),
    );
    // Keep the saved position fresh while playing (RF-16).
    final timer = local
        ? Timer.periodic(const Duration(seconds: 5), (_) {
            if (state.isPlaying) saveQueue(ref, state, controller.position);
          })
        : null;
    ref.onDispose(() {
      sub.cancel();
      ticker.cancel();
      timer?.cancel();
    });
    return controller.snapshot;
  }

  PlayerController get _c => ref.read(playerControllerProvider);

  void play(List<Track> tracks, {int start = 0, String? from}) =>
      _c.play(tracks, start: start, sourceLabel: from);

  /// Plays [tracks] in random order, turning shuffle on.
  void shufflePlay(List<Track> tracks, {String? from}) {
    if (!state.shuffle) _c.toggleShuffle();
    _c.play(tracks, sourceLabel: from);
  }

  void toggle() => _c.toggle();
  void next() => _c.next();
  void previous() => _c.previous();
  void seek(Duration d) => _c.seek(d);
  void toggleShuffle() => _c.toggleShuffle();
  void cycleRepeat() => _c.cycleRepeat();
  void playNext(Track t) => _c.playNext(t);
  void addToQueue(Track t) => _c.addToQueue(t);
  void jumpTo(int i) => _c.jumpTo(i);
  void removeAt(int i) => _c.removeAt(i);
  void move(int from, int to) => _c.move(from, to);
  void clearUpcoming() => _c.clearUpcoming();
  void setSleepTimer(SleepTimer? t) => _c.setSleepTimer(t);

  /// Builds a radio queue from [seed] (RF-15).
  Future<int> startRadio(Track seed) async {
    final CatalogRepository catalog = ref.read(catalogRepositoryProvider);
    final tracks = await catalog.radio(seed.videoId);
    play(tracks, from: 'Radio de ${seed.title}');
    return tracks.length;
  }
}

final playerProvider = NotifierProvider<PlayerNotifier, PlayerSnapshot>(
  PlayerNotifier.new,
);

/// Position updates (~10 Hz). Kept apart so only progress widgets rebuild.
/// Output volume, 0–1 (desktop bar). Starts from the engine's level and is
/// not kept across launches.
class VolumeNotifier extends Notifier<double> {
  double _lastAudible = 1;

  @override
  double build() => ref.read(playerControllerProvider).volume;

  void set(double value) {
    final v = value.clamp(0.0, 1.0);
    ref.read(playerControllerProvider).setVolume(v);
    if (v > 0) _lastAudible = v;
    state = v;
  }

  /// Mutes, or restores the level from before the last mute.
  void toggleMute() => set(state > 0 ? 0 : _lastAudible);
}

final volumeProvider = NotifierProvider<VolumeNotifier, double>(
  VolumeNotifier.new,
);

final positionProvider = StreamProvider<Duration>((ref) async* {
  final c = ref.watch(playerControllerProvider);
  yield c.position;
  yield* c.positions;
});

final currentTrackProvider = Provider<Track?>(
  (ref) => ref.watch(playerProvider.select((s) => s.current)),
);
