import 'package:freezed_annotation/freezed_annotation.dart';

import 'album.dart';
import 'artist.dart';
import 'playlist.dart';
import 'track.dart';

part 'search_results.freezed.dart';

enum SearchFilter { all, songs, albums, artists, playlists }

extension SearchFilterLabel on SearchFilter {
  String get label => switch (this) {
    SearchFilter.all => 'Todo',
    SearchFilter.songs => 'Canciones',
    SearchFilter.albums => 'Álbumes',
    SearchFilter.artists => 'Artistas',
    SearchFilter.playlists => 'Playlists',
  };
}

@freezed
abstract class SearchResults with _$SearchResults {
  const SearchResults._();

  const factory SearchResults({
    @Default(<Track>[]) List<Track> tracks,
    @Default(<Album>[]) List<Album> albums,
    @Default(<Artist>[]) List<Artist> artists,
    @Default(<Playlist>[]) List<Playlist> playlists,
  }) = _SearchResults;

  bool get isEmpty =>
      tracks.isEmpty && albums.isEmpty && artists.isEmpty && playlists.isEmpty;
}
