import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/album.dart';
import '../../models/api_error.dart';
import '../../models/artist.dart';
import '../../models/track.dart';
import 'youtube_mapping.dart';

/// Minimal client for YouTube Music's public InnerTube API (what
/// `ytmusicapi` uses, no login): song, album and artist search, album pages
/// and artist pages. It gives the catalog real albums, years, square
/// artwork and artist photos, which plain YouTube search does not.
class YoutubeMusicClient {
  YoutubeMusicClient({http.Client? client}) : _http = client ?? http.Client();

  final http.Client _http;
  String _clientVersion = '1.20260930.01.00';

  static const _songs = 'EgWKAQIIAWoKEAMQBBAJEAoQBQ%3D%3D';
  static const _albums = 'EgWKAQIYAWoKEAMQBBAJEAoQBQ%3D%3D';
  static const _artists = 'EgWKAQIgAWoKEAMQBBAJEAoQBQ%3D%3D';

  static const _headers = {
    'Content-Type': 'application/json',
    'Origin': 'https://music.youtube.com',
    'Referer': 'https://music.youtube.com/',
    'User-Agent':
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/130.0 Safari/537.36',
  };

  // ── Search ──

  Future<List<Track>> searchSongs(String q) async {
    final items = _shelfItems(
      await _post('search', {'query': q, 'params': _songs}),
    );
    return [for (final i in items) ?_songFromItem(i)];
  }

  Future<List<Album>> searchAlbums(String q) async {
    final items = _shelfItems(
      await _post('search', {'query': q, 'params': _albums}),
    );
    return [for (final i in items) ?_albumFromListItem(i)];
  }

  Future<List<Artist>> searchArtists(String q) async {
    final items = _shelfItems(
      await _post('search', {'query': q, 'params': _artists}),
    );
    return [
      for (final i in items)
        if (_browseId(i['navigationEndpoint']) case final id?)
          Artist(
            id: id,
            name: _text(_flex(i, 0)),
            avatarUrl: _thumb(i['thumbnail'], size: 544),
          ),
    ];
  }

  // ── Pages ──

  /// Album page by `MPREb_…` browse id.
  Future<Album> album(String browseId) async {
    final res = await _post('browse', {'browseId': browseId});
    final tabs =
        _at(res, ['contents', 'twoColumnBrowseResultsRenderer']) as Map?;
    final header = _first(tabs?['tabs'], 'musicResponsiveHeaderRenderer');
    if (header == null) throw const ApiException(ApiErrorCode.notFound);
    final title = _text(header['title']);
    final subtitle = _runs(header['subtitle']);
    final artistRun = _runs(header['straplineTextOne']).firstOrNull;
    final artist = ArtistRef(
      id: _browseId(artistRun?['navigationEndpoint']) ?? '',
      name: artistRun?['text'] as String? ?? '',
    );
    final cover = _thumb(header['thumbnail'], size: 1200) ?? '';
    final ref = AlbumRef(id: browseId, name: title);
    final shelf = _first(tabs?['secondaryContents'], 'musicShelfRenderer');
    final tracks = <Track>[
      for (final it in (shelf?['contents'] as List? ?? const []))
        if (it is Map && it['musicResponsiveListItemRenderer'] is Map)
          ?_albumTrack(
            it['musicResponsiveListItemRenderer'] as Map,
            ref,
            artist,
            cover,
          ),
    ];
    return Album(
      id: browseId,
      title: title,
      artist: artist,
      year: _year(subtitle.map((r) => r['text']).join()),
      genre: subtitle.firstOrNull?['text'] as String? ?? 'Álbum',
      coverUrl: cover,
      tracks: tracks,
    );
  }

  /// Artist page by channel id. The top-songs shelf links to a playlist
  /// with the full list; its id is returned for the caller to expand.
  Future<(Artist, String?)> artist(String channelId) async {
    final res = await _post('browse', {'browseId': channelId});
    final header =
        (_at(res, ['header', 'musicImmersiveHeaderRenderer']) ??
                _at(res, ['header', 'musicVisualHeaderRenderer']))
            as Map?;
    if (header == null) throw const ApiException(ApiErrorCode.notFound);
    final name = _text(header['title']);
    final sections =
        _at(res, [
              'contents',
              'singleColumnBrowseResultsRenderer',
              'tabs',
              0,
              'tabRenderer', //
              'content', 'sectionListRenderer', 'contents',
            ])
            as List? ??
        const [];
    var popular = <Track>[];
    String? morePlaylist;
    final albums = <Album>[];
    final singles = <Album>[];
    for (final s in sections) {
      if (s is! Map) continue;
      if (s['musicShelfRenderer'] case final Map shelf) {
        popular = [
          for (final it in (shelf['contents'] as List? ?? const []))
            ?_songFromItem(
              it is Map ? it['musicResponsiveListItemRenderer'] as Map? : null,
            ),
        ];
        final more =
            _browseId(shelf['bottomEndpoint']) ??
            _browseId(_runs(shelf['title']).firstOrNull?['navigationEndpoint']);
        morePlaylist = more?.replaceFirst(RegExp('^VL'), '');
      }
      if (s['musicCarouselShelfRenderer'] case final Map carousel) {
        final title = _text(
          _at(carousel, [
            'header',
            'musicCarouselShelfBasicHeaderRenderer',
            'title',
          ]),
        ).toLowerCase();
        final target = title.startsWith('álbum') || title.startsWith('album')
            ? albums
            : title.startsWith('single') || title.startsWith('sencillo')
            ? singles
            : null;
        if (target == null) continue;
        for (final it in (carousel['contents'] as List? ?? const [])) {
          final r = it is Map ? it['musicTwoRowItemRenderer'] as Map? : null;
          final id = _browseId(r?['navigationEndpoint']);
          if (r == null || id == null || !id.startsWith('MPRE')) continue;
          target.add(
            Album(
              id: id,
              title: _text(r['title']),
              artist: ArtistRef(id: channelId, name: name),
              year: _year(_text(r['subtitle'])),
              genre: '',
              coverUrl: _thumb(r['thumbnailRenderer'], size: 544) ?? '',
            ),
          );
        }
      }
    }
    final photo = _thumb(header['thumbnail'], size: 0);
    return (
      Artist(
        id: channelId,
        name: name,
        photoUrl: photo,
        avatarUrl: photo,
        popular: popular,
        albums: albums,
        singles: singles,
      ),
      morePlaylist,
    );
  }

  // ── Parsing ──

  Track? _songFromItem(Map? i) {
    if (i == null) return null;
    final videoId =
        _at(i, ['playlistItemData', 'videoId']) as String? ??
        _at(_runs(_flex(i, 0)).firstOrNull, [
              'navigationEndpoint',
              'watchEndpoint',
              'videoId',
            ])
            as String?;
    if (videoId == null) return null;
    final meta = _runs(_flex(i, 1));
    final artists = <ArtistRef>[];
    AlbumRef? album;
    Duration duration = Duration.zero;
    for (final r in meta) {
      final text = (r['text'] as String? ?? '').trim();
      final id = _browseId(r['navigationEndpoint']);
      if (id != null && id.startsWith('MPRE')) {
        album = AlbumRef(id: id, name: text);
      } else if (id != null && id.startsWith('UC')) {
        artists.add(ArtistRef(id: id, name: text));
      } else if (RegExp(r'^\d+:\d{2}(:\d{2})?$').hasMatch(text)) {
        duration = YoutubeMapping.parseDuration(text);
      }
    }
    final fixed = _text(
      _at(i, [
        'fixedColumns',
        0,
        'musicResponsiveListItemFixedColumnRenderer',
        'text',
      ]),
    );
    if (duration == Duration.zero && fixed.contains(':')) {
      duration = YoutubeMapping.parseDuration(fixed);
    }
    if (artists.isEmpty && meta.isNotEmpty) {
      artists.add(
        ArtistRef(id: '', name: (meta.first['text'] as String? ?? '').trim()),
      );
    }
    return Track(
      videoId: videoId,
      title: _text(_flex(i, 0)),
      artists: artists,
      album: album,
      duration: duration,
      coverUrl:
          _thumb(i['thumbnail'], size: 544) ?? YoutubeMapping.cover(videoId),
    );
  }

  Track? _albumTrack(
    Map i,
    AlbumRef album,
    ArtistRef albumArtist,
    String cover,
  ) {
    final t = _songFromItem(i);
    if (t == null) return null;
    return t.copyWith(
      album: album,
      artists: t.artists.isEmpty || t.artists.first.name.isEmpty
          ? [albumArtist]
          : t.artists,
      coverUrl: cover.isEmpty ? t.coverUrl : cover,
    );
  }

  Album? _albumFromListItem(Map i) {
    final id = _browseId(i['navigationEndpoint']);
    if (id == null || !id.startsWith('MPRE')) return null;
    final meta = _runs(_flex(i, 1));
    final artistRun = meta.where(
      (r) => _browseId(r['navigationEndpoint'])?.startsWith('UC') ?? false,
    );
    return Album(
      id: id,
      title: _text(_flex(i, 0)),
      artist: ArtistRef(
        id: artistRun.isEmpty
            ? ''
            : _browseId(artistRun.first['navigationEndpoint'])!,
        name: artistRun.map((r) => r['text']).join(', '),
      ),
      year: _year(meta.map((r) => r['text']).join()),
      genre: (meta.firstOrNull?['text'] as String?) ?? 'Álbum',
      coverUrl: _thumb(i['thumbnail'], size: 544) ?? '',
    );
  }

  static int? _year(String s) {
    final m = RegExp(r'\b(19|20)\d{2}\b').allMatches(s).lastOrNull;
    return m == null ? null : int.parse(m.group(0)!);
  }

  static List<Map> _shelfItems(Map res) {
    final sections =
        _at(res, [
              'contents',
              'tabbedSearchResultsRenderer',
              'tabs',
              0,
              'tabRenderer', //
              'content', 'sectionListRenderer', 'contents',
            ])
            as List? ??
        const [];
    for (final s in sections) {
      final items = _at(s, ['musicShelfRenderer', 'contents']) as List?;
      if (items != null) {
        return [
          for (final it in items)
            if (it is Map && it['musicResponsiveListItemRenderer'] is Map)
              it['musicResponsiveListItemRenderer'] as Map,
        ];
      }
    }
    return const [];
  }

  static Object? _flex(Map i, int n) => _at(i, [
    'flexColumns',
    n,
    'musicResponsiveListItemFlexColumnRenderer',
    'text',
  ]);

  static List<Map> _runs(Object? text) => [
    for (final r in (_at(text, ['runs']) as List? ?? const []))
      if (r is Map) r,
  ];

  static String _text(Object? text) =>
      _runs(text).map((r) => r['text'] ?? '').join().trim();

  static String? _browseId(Object? endpoint) =>
      _at(endpoint, ['browseEndpoint', 'browseId']) as String?;

  /// Largest thumbnail, resized via the googleusercontent URL suffix.
  static String? _thumb(Object? o, {required int size}) {
    final thumbs = _findList(o, 'thumbnails');
    if (thumbs == null || thumbs.isEmpty) return null;
    var url = (thumbs.last as Map)['url'] as String;
    if (size > 0) {
      url = url.replaceFirst(RegExp(r'=w\d+-h\d+'), '=w$size-h$size');
    }
    return url.startsWith('//') ? 'https:$url' : url;
  }

  static List? _findList(Object? o, String key) {
    if (o is Map) {
      if (o[key] is List) return o[key] as List;
      for (final v in o.values) {
        final r = _findList(v, key);
        if (r != null) return r;
      }
    } else if (o is List) {
      for (final v in o) {
        final r = _findList(v, key);
        if (r != null) return r;
      }
    }
    return null;
  }

  static Map? _first(Object? o, String key) {
    if (o is Map) {
      if (o[key] is Map) return o[key] as Map;
      for (final v in o.values) {
        final r = _first(v, key);
        if (r != null) return r;
      }
    } else if (o is List) {
      for (final v in o) {
        final r = _first(v, key);
        if (r != null) return r;
      }
    }
    return null;
  }

  static Object? _at(Object? o, List<Object> path) {
    for (final k in path) {
      if (k is int && o is List && k < o.length) {
        o = o[k];
      } else if (k is String && o is Map) {
        o = o[k];
      } else {
        return null;
      }
    }
    return o;
  }

  Future<Map> _post(
    String endpoint,
    Map<String, Object?> body, {
    bool retried = false,
  }) async {
    final r = await _http
        .post(
          Uri.https('music.youtube.com', '/youtubei/v1/$endpoint', {
            'prettyPrint': 'false',
          }),
          headers: _headers,
          body: jsonEncode({
            'context': {
              'client': {
                'clientName': 'WEB_REMIX',
                'clientVersion': _clientVersion,
                'hl': 'es',
                'gl': 'CO',
              },
            },
            ...body,
          }),
        )
        .timeout(const Duration(seconds: 12));
    if (r.statusCode == 400 && !retried && await _refreshVersion()) {
      return _post(endpoint, body, retried: true);
    }
    if (r.statusCode == 404) throw const ApiException(ApiErrorCode.notFound);
    if (r.statusCode == 429) throw const ApiException(ApiErrorCode.rateLimited);
    if (r.statusCode != 200) {
      throw ApiException(
        ApiErrorCode.extractionFailed,
        'YouTube Music respondió ${r.statusCode}',
      );
    }
    return jsonDecode(utf8.decode(r.bodyBytes)) as Map;
  }

  /// YouTube rejects stale client versions; read the current one.
  Future<bool> _refreshVersion() async {
    try {
      final page = await _http.get(
        Uri.https('music.youtube.com', '/'),
        headers: _headers,
      );
      final v = RegExp(
        r'"INNERTUBE_CLIENT_VERSION":"([^"]+)"',
      ).firstMatch(page.body)?.group(1);
      if (v == null || v == _clientVersion) return false;
      _clientVersion = v;
      return true;
    } catch (_) {
      return false;
    }
  }
}
