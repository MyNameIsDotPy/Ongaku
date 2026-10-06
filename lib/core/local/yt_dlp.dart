import 'dart:convert';
import 'dart:io';

import '../../models/api_error.dart';
import 'youtube_gateway.dart';

/// PC fallback: asks a local yt-dlp for the best audio URL when
/// youtube_explode cannot extract it. yt-dlp updates itself (`yt-dlp -U`),
/// so a YouTube change is usually fixed without a new app release.
class YtDlp {
  YtDlp({this.configuredPath = ''});

  /// Path from Ajustes; empty means "look in PATH".
  final String configuredPath;

  static bool get supported =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  Future<String?> executable() async {
    if (!supported) return null;
    if (configuredPath.isNotEmpty) {
      return await File(configuredPath).exists() ? configuredPath : null;
    }
    return findExecutable('yt-dlp');
  }

  Future<String?> version() async {
    final exe = await executable();
    if (exe == null) return null;
    final r = await Process.run(exe, ['--version']);
    return r.exitCode == 0 ? (r.stdout as String).trim() : null;
  }

  /// Direct URL of the best (or smallest, for [low]) audio-only format.
  Future<Uri> audioUrl(String videoId, {bool low = false}) async {
    final exe = await executable();
    if (exe == null) {
      throw const ApiException(
        ApiErrorCode.extractionFailed,
        'yt-dlp no está instalado.',
      );
    }
    final r = await Process.run(
      exe,
      [
        '--no-warnings',
        '--no-playlist',
        '-f',
        low ? 'worstaudio[abr>=48]/worstaudio' : 'bestaudio',
        '-g',
        'https://www.youtube.com/watch?v=$videoId',
      ],
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    final out = (r.stdout as String).trim().split('\n').first;
    if (r.exitCode != 0 || out.isEmpty) {
      final err = (r.stderr as String).toLowerCase();
      if (err.contains('unavailable') || err.contains('private')) {
        throw const ApiException(ApiErrorCode.unavailable);
      }
      throw ApiException(
        ApiErrorCode.extractionFailed,
        (r.stderr as String).trim(),
      );
    }
    return Uri.parse(out);
  }
}
