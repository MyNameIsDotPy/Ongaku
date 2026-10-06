import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

import '../../models/track.dart';

/// YouTube → Ongaku model conversions.
abstract final class YoutubeMapping {
  /// YouTube Music albums are auto-generated playlists with this prefix.
  static bool isAlbumId(String playlistId) => playlistId.startsWith('OLAK5uy_');

  /// Max-res thumbnail; the cover widget falls back to hqdefault when a video
  /// has none.
  static String cover(String videoId) =>
      'https://i.ytimg.com/vi/$videoId/maxresdefault.jpg';

  /// "Bomba Estéreo - Topic" → "Bomba Estéreo"; "ArtistVEVO" → "Artist".
  static String artistName(String author) => author
      .replaceAll(RegExp(r'\s*-\s*Topic$'), '')
      .replaceAll(RegExp(r'VEVO$'), '')
      .trim();

  static Track fromVideo(yt.Video v, {AlbumRef? album}) => Track(
    videoId: v.id.value,
    title: v.title,
    artists: [ArtistRef(id: v.channelId.value, name: artistName(v.author))],
    album: album,
    duration: v.duration ?? Duration.zero,
    coverUrl: cover(v.id.value),
  );

  static Track fromSearch(yt.SearchVideo v) => Track(
    videoId: v.id.value,
    title: v.title,
    artists: [ArtistRef(id: v.channelId, name: artistName(v.author))],
    duration: parseDuration(v.duration),
    coverUrl: cover(v.id.value),
  );

  /// "3:45" / "1:02:03" → Duration.
  static Duration parseDuration(String s) {
    final parts = s.split(':').map((p) => int.tryParse(p.trim()) ?? 0).toList();
    var seconds = 0;
    for (final p in parts) {
      seconds = seconds * 60 + p;
    }
    return Duration(seconds: seconds);
  }

  /// Best thumbnail URL from a search result thumbnail list.
  static String? bestThumb(List<yt.Thumbnail> thumbs) {
    if (thumbs.isEmpty) return null;
    final sorted = [...thumbs]..sort((a, b) => b.width.compareTo(a.width));
    final url = sorted.first.url.toString();
    return url.startsWith('//') ? 'https:$url' : url;
  }
}
