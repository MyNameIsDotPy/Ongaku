import 'dart:async';

import '../../models/library_snapshot.dart';
import '../../models/play_event.dart';
import '../../models/playlist.dart';
import '../../models/track.dart';
import '../library_repository.dart';
import 'sample_data.dart';

/// In-memory library seeded with sample data. Writes are instant, like the
/// local Drift copy that later syncs with `/v1/sync`.
class FakeLibraryRepository implements LibraryRepository {
  FakeLibraryRepository()
    : _state = LibrarySnapshot(
        playlists: SampleData.instance.initialPlaylists(),
        favorites: SampleData.instance.initialFavorites(),
        history: SampleData.instance.initialHistory(),
      );

  LibrarySnapshot _state;
  final _controller = StreamController<LibrarySnapshot>.broadcast();

  @override
  LibrarySnapshot get current => _state;

  @override
  Stream<LibrarySnapshot> watch() => _controller.stream;

  void _emit(LibrarySnapshot next) {
    _state = next;
    _controller.add(next);
  }

  void _updatePlaylist(String id, Playlist Function(Playlist) update) {
    _emit(
      _state.copyWith(
        playlists: [
          for (final p in _state.playlists) p.id == id ? update(p) : p,
        ],
      ),
    );
  }

  @override
  Future<Playlist> createPlaylist(
    String name, {
    List<Track> tracks = const [],
  }) async {
    final p = Playlist(
      id: 'pl-${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}',
      name: name,
      source: PlaylistSource.own,
      createdAt: DateTime.now(),
      tracks: tracks,
    );
    _emit(_state.copyWith(playlists: [p, ..._state.playlists]));
    return p;
  }

  @override
  Future<void> renamePlaylist(String id, String name) async =>
      _updatePlaylist(id, (p) => p.copyWith(name: name));

  @override
  Future<void> deletePlaylist(String id) async =>
      _updatePlaylist(id, (p) => p.copyWith(inLibrary: false));

  @override
  Future<void> restorePlaylist(String id) async =>
      _updatePlaylist(id, (p) => p.copyWith(inLibrary: true));

  @override
  Future<void> setPlaylistTracks(String id, List<Track> tracks) async =>
      _updatePlaylist(id, (p) => p.copyWith(tracks: tracks));

  @override
  Future<Playlist> importPlaylist(Playlist source) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final copy = source.copyWith(
      id: 'pl-imp-${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}',
      source: PlaylistSource.own,
      createdAt: DateTime.now(),
      inLibrary: true,
    );
    _emit(_state.copyWith(playlists: [copy, ..._state.playlists]));
    return copy;
  }

  @override
  Future<bool> toggleFavorite(Track track) async {
    final on = !_state.isFavorite(track.videoId);
    _emit(
      _state.copyWith(
        favorites: on
            ? [track, ..._state.favorites]
            : _state.favorites
                  .where((t) => t.videoId != track.videoId)
                  .toList(),
      ),
    );
    return on;
  }

  @override
  Future<void> recordPlay(Track track, DeviceKind device) async {
    if (_state.history.isNotEmpty &&
        _state.history.first.track.videoId == track.videoId) {
      return;
    }
    _emit(
      _state.copyWith(
        history: [
          PlayEvent(track: track, playedAt: DateTime.now(), device: device),
          ..._state.history,
        ],
      ),
    );
  }
}
