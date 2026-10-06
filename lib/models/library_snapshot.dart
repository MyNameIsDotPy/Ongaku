import 'package:freezed_annotation/freezed_annotation.dart';

import 'play_event.dart';
import 'playlist.dart';
import 'track.dart';

part 'library_snapshot.freezed.dart';

/// Everything the user owns: playlists, favorites and history (RF-19–21).
@freezed
abstract class LibrarySnapshot with _$LibrarySnapshot {
  const LibrarySnapshot._();

  const factory LibrarySnapshot({
    @Default(<Playlist>[]) List<Playlist> playlists,
    @Default(<Track>[]) List<Track> favorites,
    @Default(<PlayEvent>[]) List<PlayEvent> history,
  }) = _LibrarySnapshot;

  List<Playlist> get ownedPlaylists =>
      playlists.where((p) => p.inLibrary).toList();

  bool isFavorite(String videoId) => favorites.any((t) => t.videoId == videoId);

  Playlist? playlist(String id) {
    for (final p in playlists) {
      if (p.id == id) return p;
    }
    return null;
  }
}
