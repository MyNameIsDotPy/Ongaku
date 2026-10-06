import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/lyrics.dart';
import '../../models/track.dart';

/// Lyrics from lrclib.net (free, no key): synced LRC when available, plain
/// text otherwise (RF-30). Titles from YouTube are cleaned up first.
class LrcLibLyrics {
  LrcLibLyrics({http.Client? client}) : _http = client ?? http.Client();

  final http.Client _http;
  static const _base = 'https://lrclib.net/api';
  static const _headers = {'User-Agent': 'Ongaku (personal music player)'};

  Future<Lyrics?> find(Track track) async {
    final (artist, title) = guessArtistAndTitle(track);
    final exact = await _get('$_base/get', {
      'artist_name': artist,
      'track_name': title,
      if (track.album != null) 'album_name': track.album!.name,
      'duration': '${track.duration.inSeconds}',
    });
    if (exact is Map<String, Object?>) return _parse(exact, track.duration);
    final results = await _get('$_base/search', {'q': '$artist $title'});
    if (results is List && results.isNotEmpty) {
      // Prefer a result whose length matches the video within 5 s.
      final best = results.cast<Map<String, Object?>>().firstWhere(
        (r) =>
            ((r['duration'] as num? ?? 0) - track.duration.inSeconds).abs() <=
            5,
        orElse: () => results.first as Map<String, Object?>,
      );
      return _parse(best, track.duration);
    }
    return null;
  }

  Future<Object?> _get(String url, Map<String, String> query) async {
    try {
      final r = await _http
          .get(
            Uri.parse(url).replace(queryParameters: query),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 8));
      if (r.statusCode != 200) return null;
      return jsonDecode(utf8.decode(r.bodyBytes));
    } catch (_) {
      return null;
    }
  }

  static Lyrics? _parse(Map<String, Object?> m, Duration trackLength) {
    final synced = m['syncedLyrics'] as String?;
    if (synced != null && synced.trim().isNotEmpty) {
      return Lyrics(synced: true, lines: parseLrc(synced, trackLength));
    }
    final plain = m['plainLyrics'] as String?;
    if (plain == null || plain.trim().isEmpty) return null;
    return Lyrics(
      synced: false,
      lines: [
        for (final l in plain.split('\n'))
          LyricLine(
            start: Duration.zero,
            end: Duration.zero,
            text: l.trim(),
            instrumental: l.trim().isEmpty,
          ),
      ],
    );
  }

  /// `[mm:ss.xx] text` lines → timed lines; empty lines become instrumental
  /// gaps, as do pauses longer than 8 s.
  static List<LyricLine> parseLrc(String lrc, Duration trackLength) {
    final re = RegExp(r'^\[(\d+):(\d+(?:\.\d+)?)\](.*)$');
    final raw = <(Duration, String)>[];
    for (final line in lrc.split('\n')) {
      final m = re.firstMatch(line.trim());
      if (m == null) continue;
      final at = Duration(
        milliseconds:
            (int.parse(m.group(1)!) * 60000 + double.parse(m.group(2)!) * 1000)
                .round(),
      );
      raw.add((at, m.group(3)!.trim()));
    }
    final out = <LyricLine>[];
    if (raw.isNotEmpty && raw.first.$1 > const Duration(seconds: 3)) {
      out.add(
        LyricLine(start: Duration.zero, end: raw.first.$1, instrumental: true),
      );
    }
    for (var i = 0; i < raw.length; i++) {
      final (start, text) = raw[i];
      final end = i + 1 < raw.length ? raw[i + 1].$1 : trackLength;
      if (text.isEmpty ||
          end - start > const Duration(seconds: 8) && text.isEmpty) {
        out.add(LyricLine(start: start, end: end, instrumental: true));
      } else {
        out.add(LyricLine(start: start, end: end, text: text));
      }
    }
    return out;
  }

  /// "Artist - Song (Official Video) [HD]" → ("Artist", "Song").
  static (String, String) guessArtistAndTitle(Track t) {
    var title = t.title
        .replaceAll(
          RegExp(
            r'\s*[\(\[][^\)\]]*(official|video|audio|lyric|letra|visualizer|hd|4k|remaster)[^\)\]]*[\)\]]',
            caseSensitive: false,
          ),
          '',
        )
        .trim();
    var artist = t.artistNames;
    final dash = RegExp(r'^(.+?)\s+[-–—]\s+(.+)$').firstMatch(title);
    if (dash != null) {
      artist = dash.group(1)!.trim();
      title = dash.group(2)!.trim();
    }
    return (artist, title);
  }
}
