import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/library_repository.dart';
import '../models/demo_scenario.dart';
import '../models/library_snapshot.dart';
import '../models/play_event.dart';
import '../models/playlist.dart';
import '../models/track.dart';
import 'demo_providers.dart';
import 'repository_providers.dart';

/// Status of the library sync with the backend. The library itself is always
/// readable from the local copy; this drives skeleton / error states.
final librarySyncProvider = FutureProvider<void>((ref) async {
  ref.watch(demoScenarioProvider);
  await ref.watch(fakeBackendProvider).call(() {}, cacheable: true);
});

class LibraryNotifier extends Notifier<LibrarySnapshot> {
  @override
  LibrarySnapshot build() {
    final repo = ref.watch(libraryRepositoryProvider);
    final empty = ref.watch(demoScenarioProvider) == DemoScenario.empty;
    final sub = repo.watch().listen((s) {
      state = empty ? const LibrarySnapshot() : s;
    });
    ref.onDispose(sub.cancel);
    return empty ? const LibrarySnapshot() : repo.current;
  }

  LibraryRepository get _repo => ref.read(libraryRepositoryProvider);

  Future<Playlist> create(String name, {List<Track> tracks = const []}) =>
      _repo.createPlaylist(name, tracks: tracks);
  Future<void> rename(String id, String name) => _repo.renamePlaylist(id, name);
  Future<void> delete(String id) => _repo.deletePlaylist(id);
  Future<void> restore(String id) => _repo.restorePlaylist(id);
  Future<void> setTracks(String id, List<Track> tracks) =>
      _repo.setPlaylistTracks(id, tracks);
  Future<Playlist> import(Playlist p) => _repo.importPlaylist(p);
  Future<bool> toggleFavorite(Track t) => _repo.toggleFavorite(t);
  Future<void> recordPlay(Track t) => _repo.recordPlay(t, currentDevice);

  Future<void> addToPlaylist(String id, Track t) async {
    final p = state.playlist(id);
    if (p == null || p.tracks.any((x) => x.videoId == t.videoId)) return;
    await setTracks(id, [...p.tracks, t]);
  }
}

DeviceKind get currentDevice =>
    defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS
    ? DeviceKind.phone
    : DeviceKind.pc;

final libraryProvider = NotifierProvider<LibraryNotifier, LibrarySnapshot>(
  LibraryNotifier.new,
);

final isFavoriteProvider = Provider.family<bool, String>(
  (ref, videoId) =>
      ref.watch(libraryProvider.select((s) => s.isFavorite(videoId))),
);

final playlistProvider = Provider.family<Playlist?, String>(
  (ref, id) => ref.watch(libraryProvider.select((s) => s.playlist(id))),
);
