import '../models/library_snapshot.dart';
import '../models/play_event.dart';
import '../models/playlist.dart';
import '../models/track.dart';

/// Own playlists, favorites and history, synced through `/v1/library`.
abstract interface class LibraryRepository {
  LibrarySnapshot get current;
  Stream<LibrarySnapshot> watch();

  Future<Playlist> createPlaylist(String name, {List<Track> tracks});
  Future<void> renamePlaylist(String id, String name);

  /// Soft delete (`deleted_at`), so it can be undone.
  Future<void> deletePlaylist(String id);
  Future<void> restorePlaylist(String id);

  /// Replaces the ordered track list (covers add, remove and reorder).
  Future<void> setPlaylistTracks(String id, List<Track> tracks);

  /// Copies a YouTube playlist as an editable own playlist (RF-22).
  Future<Playlist> importPlaylist(Playlist source);

  /// Returns the new favorite state.
  Future<bool> toggleFavorite(Track track);
  Future<void> recordPlay(Track track, DeviceKind device);
}
