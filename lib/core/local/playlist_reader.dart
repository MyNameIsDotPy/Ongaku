import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/api_error.dart';
import '../../models/track.dart';
import 'youtube_mapping.dart';

/// Reads a playlist's songs from YouTube's web page.
///
/// youtube_explode_dart 3.1.0 drops every item of the current layout
/// (`lockupViewModel`), so playlists and albums came back empty. This reader
/// accepts both that layout and the older `playlistVideoRenderer`, and
/// follows continuation pages.
class PlaylistReader {
  PlaylistReader({http.Client? client}) : _http = client ?? http.Client();

  final http.Client _http;

  static const _headers = {
    'User-Agent':
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/130.0 Safari/537.36',
    'Accept-Language': 'es-419,es;q=0.9,en;q=0.8',
  };

  Future<List<Track>> tracks(
    String playlistId, {
    int limit = 1000,
    AlbumRef? album,
  }) async {
    final page = await _http.get(
      Uri.https('www.youtube.com', '/playlist', {
        'list': playlistId,
        'hl': 'es',
      }),
      headers: _headers,
    );
    if (page.statusCode == 404) throw const ApiException(ApiErrorCode.notFound);
    final data = _initialData(page.body);
    if (data == null) {
      throw const ApiException(
        ApiErrorCode.extractionFailed,
        'Página de playlist sin datos.',
      );
    }
    final clientVersion =
        RegExp(
          r'"INNERTUBE_CLIENT_VERSION":"([^"]+)"',
        ).firstMatch(page.body)?.group(1) ??
        '2.20261002.10.00';

    final out = <Track>[];
    final seen = <String>{};
    Object? chunk = data;
    var pages = 0;
    while (chunk != null && out.length < limit && pages++ < 50) {
      final before = out.length;
      for (final t in parseItems(chunk, album: album)) {
        if (seen.add(t.videoId)) out.add(t);
      }
      final token = _continuation(chunk);
      if (token == null || out.length == before) break;
      final r = await _http.post(
        Uri.https('www.youtube.com', '/youtubei/v1/browse', {
          'prettyPrint': 'false',
        }),
        headers: {..._headers, 'Content-Type': 'application/json'},
        body: jsonEncode({
          'context': {
            'client': {
              'clientName': 'WEB',
              'clientVersion': clientVersion,
              'hl': 'es',
            },
          },
          'continuation': token,
        }),
      );
      chunk = r.statusCode == 200 ? jsonDecode(r.body) : null;
    }
    return out.take(limit).toList();
  }

  static Map<String, Object?>? _initialData(String html) {
    final m = RegExp(
      r'var ytInitialData\s*=\s*(\{.*?\});\s*</script>',
      dotAll: true,
    ).firstMatch(html);
    if (m == null) return null;
    return jsonDecode(m.group(1)!) as Map<String, Object?>;
  }

  /// Every playable item in [json], in order.
  static Iterable<Track> parseItems(Object? json, {AlbumRef? album}) sync* {
    for (final (key, item) in _walk(json)) {
      final track = switch (key) {
        'lockupViewModel' => _fromLockup(item, album),
        'playlistVideoRenderer' => _fromRenderer(item, album),
        _ => null,
      };
      if (track != null) yield track;
    }
  }

  static Track? _fromLockup(Map<String, Object?> m, AlbumRef? album) {
    if (m['contentType'] != 'LOCKUP_CONTENT_TYPE_VIDEO') return null;
    final id = m['contentId'] as String?;
    if (id == null) return null;
    final meta = _at(m, ['metadata', 'lockupMetadataViewModel']);
    final title = _at(meta, ['title', 'content']) as String? ?? '';
    final rows = _at(meta, [
      'metadata',
      'contentMetadataViewModel',
      'metadataRows',
    ]);
    final author =
        _at(rows, [0, 'metadataParts', 0, 'text', 'content']) as String? ?? '';
    final channel =
        _firstString(meta, 'browseId', (s) => s.startsWith('UC')) ?? '';
    final duration =
        _firstString(
          m['contentImage'],
          'text',
          (s) => RegExp(r'^\d+:\d{2}(:\d{2})?$').hasMatch(s),
        ) ??
        _firstString(
          m['contentImage'],
          'content',
          (s) => RegExp(r'^\d+:\d{2}(:\d{2})?$').hasMatch(s),
        ) ??
        '0:00';
    return _track(
      id,
      title,
      author,
      channel,
      YoutubeMapping.parseDuration(duration),
      album,
    );
  }

  static Track? _fromRenderer(Map<String, Object?> m, AlbumRef? album) {
    final id = m['videoId'] as String?;
    if (id == null || m['isPlayable'] == false) return null;
    final title =
        _at(m, ['title', 'runs', 0, 'text']) as String? ??
        _at(m, ['title', 'simpleText']) as String? ??
        '';
    final author =
        _at(m, ['shortBylineText', 'runs', 0, 'text']) as String? ?? '';
    final channel =
        _firstString(
          m['shortBylineText'],
          'browseId',
          (s) => s.startsWith('UC'),
        ) ??
        '';
    final seconds = int.tryParse('${m['lengthSeconds'] ?? ''}') ?? 0;
    return _track(
      id,
      title,
      author,
      channel,
      Duration(seconds: seconds),
      album,
    );
  }

  static Track _track(
    String id,
    String title,
    String author,
    String channel,
    Duration duration,
    AlbumRef? album,
  ) => Track(
    videoId: id,
    title: title,
    artists: [ArtistRef(id: channel, name: YoutubeMapping.artistName(author))],
    album: album,
    duration: duration,
    coverUrl: YoutubeMapping.cover(id),
  );

  static String? _continuation(Object? json) =>
      _firstString(json, 'token', (s) => s.length > 20);

  // ── JSON helpers ──

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

  /// Depth-first (key, map) pairs for every map value in [o].
  static Iterable<(String, Map<String, Object?>)> _walk(Object? o) sync* {
    if (o is Map) {
      for (final MapEntry(:key, :value) in o.entries) {
        if (value is Map<String, Object?>) {
          yield ('$key', value);
          // Items don't nest inside items; skip their (large) subtrees.
          if (key == 'lockupViewModel' || key == 'playlistVideoRenderer') {
            continue;
          }
        }
        yield* _walk(value);
      }
    } else if (o is List) {
      for (final v in o) {
        yield* _walk(v);
      }
    }
  }

  static String? _firstString(
    Object? o,
    String key,
    bool Function(String) test,
  ) {
    if (o is Map) {
      final v = o[key];
      if (v is String && test(v)) return v;
      for (final child in o.values) {
        final r = _firstString(child, key, test);
        if (r != null) return r;
      }
    } else if (o is List) {
      for (final child in o) {
        final r = _firstString(child, key, test);
        if (r != null) return r;
      }
    }
    return null;
  }
}
