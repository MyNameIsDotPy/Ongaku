import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/catalog_repository.dart';
import '../core/player_controller.dart';
import '../models/player_snapshot.dart';
import '../models/track.dart';
import 'library_providers.dart';
import 'repository_providers.dart';

/// Mirrors `PlayerController` snapshots and exposes its commands. Records a
/// play in the history once a track starts playing (RF-21).
class PlayerNotifier extends Notifier<PlayerSnapshot> {
  @override
  PlayerSnapshot build() {
    final controller = ref.watch(playerControllerProvider);
    final sub = controller.snapshots.listen((s) {
      final previous = state;
      state = s;
      if (s.isPlaying &&
          (!previous.isPlaying || previous.current != s.current)) {
        ref.read(libraryProvider.notifier).recordPlay(s.current!);
      }
    });
    ref.onDispose(sub.cancel);
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
final positionProvider = StreamProvider<Duration>((ref) async* {
  final c = ref.watch(playerControllerProvider);
  yield c.position;
  yield* c.positions;
});

final currentTrackProvider = Provider<Track?>(
  (ref) => ref.watch(playerProvider.select((s) => s.current)),
);
