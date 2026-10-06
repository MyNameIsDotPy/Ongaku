import 'dart:async';
import 'dart:io';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../../models/api_error.dart';
import '../../models/app_settings.dart';
import '../../models/track.dart';
import 'youtube_gateway.dart';
import 'yt_dlp.dart';

/// Downloads first, then a fresh audio-only stream, then yt-dlp on desktop.
/// Android client URLs can be single-use, even before their expiry time.
class StreamResolver {
  StreamResolver(this._gateway, {required this.ytDlp, required this.localFile});

  final YoutubeGateway _gateway;
  final YtDlp ytDlp;
  final String? Function(String videoId) localFile;

  Future<Uri> resolve(
    Track track, {
    AudioQuality quality = AudioQuality.high,
  }) async {
    final file = localFile(track.videoId);
    if (file != null && await File(file).exists()) return Uri.file(file);

    try {
      return await _gateway((yt) async {
        final manifest = await audioManifest(yt, track.videoId);
        final audio = manifest.audioOnly;
        if (audio.isEmpty) throw const ApiException(ApiErrorCode.unavailable);
        final sorted = audio.sortByBitrate();
        return (quality == AudioQuality.high ? sorted.first : sorted.last).url;
      }).timeout(const Duration(seconds: 45));
    } on TimeoutException {
      throw const ApiException(
        ApiErrorCode.backendOffline,
        'La conexión tardó demasiado. Vuelve a intentarlo.',
      );
    } on ApiException catch (e) {
      if (e.code == ApiErrorCode.backendOffline ||
          e.code == ApiErrorCode.unavailable ||
          e.code == ApiErrorCode.rateLimited ||
          !YtDlp.supported) {
        rethrow;
      }
      return ytDlp.audioUrl(track.videoId, low: quality == AudioQuality.low);
    }
  }
}
