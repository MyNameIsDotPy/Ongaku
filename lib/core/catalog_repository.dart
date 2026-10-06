import '../models/album.dart';
import '../models/artist.dart';
import '../models/lyrics.dart';
import '../models/playlist.dart';
import '../models/search_results.dart';
import '../models/track.dart';

/// Search and catalog detail. Backed by `/v1/search`, `/v1/albums`,
/// `/v1/artists`, `/v1/yt-playlists`, `/v1/radio` and `/v1/lyrics`.
abstract interface class CatalogRepository {
  Future<SearchResults> search(String query);
  Future<List<String>> suggestions(String query);
  Future<Album> album(String id);
  Future<Artist> artist(String id);

  /// Accepts a playlist id or a full YouTube URL.
  Future<Playlist> youtubePlaylist(String idOrUrl);
  Future<List<Track>> radio(String videoId);
  Future<Lyrics?> lyrics(String videoId);

  /// Albums to fill the search landing ("Explorar tu catálogo").
  Future<List<Album>> explore();
  Future<Track?> track(String videoId);
  BeatGrid beatGrid(Track track);
}

/// Detects a YouTube playlist link (`list=` query parameter).
String? youtubePlaylistId(String input) {
  final match = RegExp(
    r'(youtube\.com|youtu\.be).*[?&]list=([\w-]+)',
    caseSensitive: false,
  ).firstMatch(input.trim());
  return match?.group(2);
}
