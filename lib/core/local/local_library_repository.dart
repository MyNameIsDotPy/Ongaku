import 'dart:async';

import '../../models/json_codec.dart';
import '../../models/library_snapshot.dart';
import '../../models/play_event.dart';
import '../../models/playlist.dart';
import '../../models/track.dart';
import '../library_repository.dart';
import 'json_file_store.dart';

/// The user's playlists, favorites and history, stored on this device.
class LocalLibraryRepository implements LibraryRepository {
  LocalLibraryRepository._(this._store, this._state);

  static Future<LocalLibraryRepository> open(JsonFileStore store) async {
    final json = await store.read();
    return LocalLibraryRepository._(
      store,
      json == null ? const LibrarySnapshot() : JsonCodecs.libraryFrom(json),
    );
  }

  /// History is capped so the file stays small.
  static const maxHistory = 500;

  final JsonFileStore _store;
  LibrarySnapshot _state;
  final _controller = StreamController<LibrarySnapshot>.broadcast();

  @override
  LibrarySnapshot get current => _state;

  @override
  Stream<LibrarySnapshot> watch() => _controller.stream;

  void _emit(LibrarySnapshot next) {
    _state = next;
    _controller.add(next);
    _store.write(JsonCodecs.library(next));
  }

  void _updatePlaylist(String id, Playlist Function(Playlist) f) => _emit(
    _state.copyWith(
      playlists: [for (final p in _state.playlists) p.id == id ? f(p) : p],
    ),
  );

  String _newId(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';

  @override
  Future<Playlist> createPlaylist(
    String name, {
    List<Track> tracks = const [],
  }) async {
    final p = Playlist(
      id: _newId('pl'),
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
    final copy = source.copyWith(
      id: _newId('pl-imp'),
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
          ..._state.history.take(maxHistory - 1),
        ],
      ),
    );
  }

  /// Permanently drops soft-deleted playlists (on app start).
  void compact() {
    if (_state.playlists.every((p) => p.inLibrary || !p.isOwn)) return;
    _emit(
      _state.copyWith(
        playlists: _state.playlists
            .where((p) => p.inLibrary || !p.isOwn)
            .toList(),
      ),
    );
  }
}
