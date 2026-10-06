import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../../models/api_error.dart';
import '../../models/app_settings.dart';
import '../../models/track.dart';
import 'youtube_gateway.dart';
import 'yt_dlp.dart';

/// Turns a track into something playable: a downloaded file first, then an
/// audio-only stream from youtube_explode, then yt-dlp on PC (RF-07).
/// Stream URLs expire after a few hours, so they are cached until then.
class StreamResolver {
  StreamResolver(this._gateway, {required this.ytDlp, required this.localFile});

  final YoutubeGateway _gateway;
  final YtDlp ytDlp;

  /// Path of a downloaded copy, if any (RF-25: plays offline).
  final String? Function(String videoId) localFile;

  final _cache = <String, (Uri, DateTime)>{};

  Future<Uri> resolve(
    Track track, {
    AudioQuality quality = AudioQuality.high,
  }) async {
    final file = localFile(track.videoId);
    if (file != null) return Uri.file(file);

    final key = '${track.videoId}:${quality.name}';
    final cached = _cache[key];
    if (cached != null && cached.$2.isAfter(DateTime.now())) return cached.$1;

    Uri url;
    try {
      url = await _gateway((yt) async {
        final manifest = await audioManifest(yt, track.videoId);
        final audio = manifest.audioOnly;
        if (audio.isEmpty) throw const ApiException(ApiErrorCode.unavailable);
        final sorted = audio.sortByBitrate(); // highest first
        // One lookup serves both qualities (Wi-Fi ⇄ mobile data).
        for (final (q, info) in [
          (AudioQuality.high, sorted.first),
          (AudioQuality.low, sorted.last),
        ]) {
          _cache['${track.videoId}:${q.name}'] = (info.url, _expiry(info.url));
        }
        return (quality == AudioQuality.high ? sorted.first : sorted.last).url;
      });
    } on ApiException catch (e) {
      // Offline or unavailable: yt-dlp would fail the same way.
      if (e.code == ApiErrorCode.backendOffline ||
          e.code == ApiErrorCode.unavailable ||
          !YtDlp.supported) {
        rethrow;
      }
      url = await ytDlp.audioUrl(
        track.videoId,
        low: quality == AudioQuality.low,
      );
    }
    _cache[key] = (url, _expiry(url));
    return url;
  }

  /// Drops a cached URL after a playback error (likely expired).
  void invalidate(Track track) =>
      _cache.removeWhere((k, _) => k.startsWith('${track.videoId}:'));

  static DateTime _expiry(Uri url) {
    final s = int.tryParse(url.queryParameters['expire'] ?? '');
    final at = s == null
        ? DateTime.now().add(const Duration(hours: 1))
        : DateTime.fromMillisecondsSinceEpoch(s * 1000);
    return at.subtract(const Duration(minutes: 10));
  }
}
