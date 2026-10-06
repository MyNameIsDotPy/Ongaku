import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

import '../../models/album.dart';
import '../../models/api_error.dart';
import '../../models/artist.dart';
import '../../models/lyrics.dart';
import '../../models/playlist.dart';
import '../../models/search_results.dart';
import '../../models/track.dart';
import '../catalog_repository.dart';
import '../fakes/sample_data.dart' show normalize;
import 'lrclib_lyrics.dart';
import 'playlist_reader.dart';
import 'youtube_gateway.dart';
import 'youtube_mapping.dart';

/// Catalog straight from YouTube on this device (no backend): search,
/// albums (YouTube Music `OLAK5uy_` playlists), artists (channels), public
/// playlists, radio (YouTube mixes) and lyrics (lrclib.net).
class LocalCatalogRepository implements CatalogRepository {
  LocalCatalogRepository(
    this._gateway, {
    required this.libraryPlaylists,
    LrcLibLyrics? lyrics,
    PlaylistReader? reader,
  }) : _lyrics = lyrics ?? LrcLibLyrics(),
       _reader = reader ?? PlaylistReader();

  final YoutubeGateway _gateway;
  final LrcLibLyrics _lyrics;
  final PlaylistReader _reader;

  /// Songs of a playlist: the layout-tolerant reader first, the library's
  /// own parser as a fallback.
  Future<List<Track>> _playlistTracks(
    yt.YoutubeExplode client,
    String id, {
    int limit = 1000,
    AlbumRef? album,
  }) async {
    final read = await _reader.tracks(id, limit: limit, album: album);
    if (read.isNotEmpty) return read;
    final videos = await client.playlists.getVideos(id).take(limit).toList();
    return [for (final v in videos) YoutubeMapping.fromVideo(v, album: album)];
  }

  final List<Playlist> Function() libraryPlaylists;

  final _albumCache = <String, Album>{};
  final _artistCache = <String, Artist>{};

  @override
  Future<SearchResults> search(String query) => _gateway((client) async {
    final q = query.trim();
    if (q.isEmpty) return const SearchResults();
    final [mixed, lists] = await Future.wait([
      client.search.searchContent(q),
      client.search.searchContent(q, filter: yt.TypeFilters.playlist),
    ]);
    final tracks = <Track>[];
    final artists = <Artist>[];
    final albums = <Album>[];
    final playlists = <Playlist>[];
    final seenLists = <String>{};
    for (final r in [...mixed, ...lists]) {
      switch (r) {
        case yt.SearchVideo() when !r.isLive && r.duration.isNotEmpty:
          tracks.add(YoutubeMapping.fromSearch(r));
        case yt.SearchChannel():
          artists.add(
            Artist(
              id: r.id.value,
              name: YoutubeMapping.artistName(r.name),
              avatarUrl: YoutubeMapping.bestThumb(r.thumbnails),
            ),
          );
        case yt.SearchPlaylist() when seenLists.add(r.id.value):
          final cover = YoutubeMapping.bestThumb(r.thumbnails) ?? '';
          if (YoutubeMapping.isAlbumId(r.id.value)) {
            albums.add(
              Album(
                id: r.id.value,
                title: _albumTitle(r.title),
                artist: const ArtistRef(id: '', name: ''),
                genre: '',
                coverUrl: cover,
              ),
            );
          } else {
            playlists.add(
              Playlist(
                id: r.id.value,
                name: r.title,
                source: PlaylistSource.youtube,
                sourceId: r.id.value,
                createdAt: DateTime.now(),
                inLibrary: false,
                artworkUrl: cover.isEmpty ? null : cover,
                declaredTrackCount: r.videoCount,
              ),
            );
          }
        default:
          break;
      }
    }
    final n = normalize(q);
    if (artists.isEmpty) artists.addAll(_artistsFrom(tracks, n));
    return SearchResults(
      tracks: tracks,
      albums: albums,
      artists: artists,
      playlists: [
        ...libraryPlaylists().where(
          (p) => p.inLibrary && normalize(p.name).contains(n),
        ),
        ...playlists,
      ],
    );
  });

  @override
  Future<List<String>> suggestions(String query) async {
    if (query.trim().isEmpty) return const [];
    try {
      return await _gateway(
        (client) => client.search.getQuerySuggestions(query.trim()),
      );
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<Album> album(String id) async {
    final cached = _albumCache[id];
    if (cached != null) return cached;
    return _albumCache[id] = await _gateway((client) async {
      final list = await client.playlists.get(id);
      final ref = AlbumRef(id: id, name: _albumTitle(list.title));
      final tracks = await _playlistTracks(client, id, limit: 200, album: ref);
      if (tracks.isEmpty) throw const ApiException(ApiErrorCode.notFound);
      final first = tracks.first;
      return Album(
        id: id,
        title: ref.name,
        artist: ArtistRef(
          id: first.primaryArtist.id,
          name: YoutubeMapping.artistName(
            list.author.isNotEmpty ? list.author : first.artistNames,
          ),
        ),
        genre: 'YouTube Music',
        coverUrl: tracks.first.coverUrl,
        tracks: tracks,
      );
    });
  }

  @override
  Future<Artist> artist(String id) async {
    final cached = _artistCache[id];
    if (cached != null) return cached;
    return _artistCache[id] = await _gateway((client) async {
      final channel = await client.channels.get(id);
      final name = YoutubeMapping.artistName(channel.title);
      var popular = <Track>[];
      try {
        popular = [
          for (final v
              in await client.channels.getUploads(id).take(10).toList())
            YoutubeMapping.fromVideo(v),
        ];
      } catch (_) {}
      final found = await client.search.searchContent(
        name,
        filter: yt.TypeFilters.playlist,
      );
      if (popular.isEmpty) {
        final videos = await client.search.search(name);
        popular = [
          for (final v in videos.take(10)) YoutubeMapping.fromVideo(v),
        ];
      }
      final albums = [
        for (final r in found.whereType<yt.SearchPlaylist>())
          if (YoutubeMapping.isAlbumId(r.id.value))
            Album(
              id: r.id.value,
              title: _albumTitle(r.title),
              artist: ArtistRef(id: id, name: name),
              genre: '',
              coverUrl: YoutubeMapping.bestThumb(r.thumbnails) ?? '',
            ),
      ];
      String? img(String url) =>
          url.isEmpty ? null : (url.startsWith('//') ? 'https:$url' : url);
      return Artist(
        id: id,
        name: name,
        photoUrl: img(channel.bannerUrl),
        avatarUrl: img(channel.logoUrl),
        popular: popular,
        albums: albums,
      );
    });
  }

  @override
  Future<Playlist> youtubePlaylist(String idOrUrl) => _gateway((client) async {
    final id = youtubePlaylistId(idOrUrl) ?? idOrUrl;
    final list = await client.playlists.get(id);
    final tracks = await _playlistTracks(client, id);
    return Playlist(
      id: id,
      name: list.title,
      source: PlaylistSource.youtube,
      sourceId: id,
      owner: list.author.isEmpty ? 'YouTube' : list.author,
      createdAt: DateTime.now(),
      inLibrary: false,
      tracks: tracks,
    );
  });

  /// RF-15: YouTube's own mix for the song, else its related videos.
  @override
  Future<List<Track>> radio(String videoId) => _gateway((client) async {
    try {
      final mix = await client.playlists
          .getVideos('RD$videoId')
          .take(25)
          .toList();
      if (mix.length > 1) {
        return [for (final v in mix) YoutubeMapping.fromVideo(v)];
      }
    } catch (_) {}
    final video = await client.videos.get(videoId);
    final related = await client.videos.getRelatedVideos(video);
    return [
      YoutubeMapping.fromVideo(video),
      for (final v in (related ?? const <yt.Video>[]).take(24))
        YoutubeMapping.fromVideo(v),
    ];
  });

  @override
  Future<Lyrics?> lyrics(String videoId) async {
    final t = await track(videoId);
    return t == null ? null : _lyrics.find(t);
  }

  /// Nothing to browse without a catalog; the search landing hides it.
  @override
  Future<List<Album>> explore() async => const [];

  final _trackCache = <String, Track>{};

  /// Remembers tracks the UI already knows so lyrics need no extra request.
  void remember(Track t) => _trackCache[t.videoId] = t;

  @override
  Future<Track?> track(String videoId) async {
    final cached = _trackCache[videoId];
    if (cached != null) return cached;
    try {
      final v = await _gateway((client) => client.videos.get(videoId));
      return _trackCache[videoId] = YoutubeMapping.fromVideo(v);
    } catch (_) {
      return null;
    }
  }

  /// Tempo is unknown without analysis; a stable per-song estimate keeps the
  /// visuals moving (the design proposes backend beat detection later).
  @override
  BeatGrid beatGrid(Track track) {
    var h = 0;
    for (final c in track.videoId.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return BeatGrid(bpm: 92.0 + h % 32);
  }

  /// Channels behind the songs, most frequent first, keeping those whose
  /// name matches the query (YouTube's channel search fails upstream).
  static List<Artist> _artistsFrom(List<Track> tracks, String query) {
    final counts = <String, (ArtistRef, int)>{};
    for (final t in tracks) {
      for (final a in t.artists) {
        if (a.id.isEmpty) continue;
        final (ref, n) = counts[a.id] ?? (a, 0);
        counts[a.id] = (ref, n + 1);
      }
    }
    final ranked =
        counts.values
            .where(
              (e) =>
                  normalize(e.$1.name).contains(query) ||
                  query.contains(normalize(e.$1.name)),
            )
            .toList()
          ..sort((a, b) => b.$2.compareTo(a.$2));
    return [
      for (final (a, _) in ranked.take(3)) Artist(id: a.id, name: a.name),
    ];
  }

  static String _albumTitle(String t) =>
      t.replaceFirst(RegExp(r'^Album\s*-\s*', caseSensitive: false), '');
}
