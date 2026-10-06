import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/js_challenge.dart';
import 'package:youtube_explode_dart/solvers.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

import '../../models/api_error.dart';

/// The single YouTube client used on this device, plus error mapping to the
/// app's [ApiErrorCode]s and network-status reporting (RF-29).
class YoutubeGateway {
  YoutubeGateway({this.onNetwork});

  /// Called with `false` when a request fails for lack of network and
  /// `true` when one succeeds again.
  void Function(bool online)? onNetwork;

  YoutubeExplode? _yt;
  Future<YoutubeExplode>? _starting;

  /// On desktop, Deno unlocks additional signature-protected formats.
  Future<YoutubeExplode> get client =>
      _starting ??= _start().catchError((Object e) {
        _starting = null;
        throw e;
      });

  Future<YoutubeExplode> _start() async {
    BaseJSChallengeSolver? solver;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final deno = await findExecutable('deno');
      if (deno != null) {
        try {
          solver = await DenoEJSSolver.init(denoExe: deno);
        } catch (_) {
          solver = null;
        }
      }
    }
    return _yt = YoutubeExplode(jsSolver: solver);
  }

  /// Runs [body], translating failures into [ApiException]s.
  Future<T> call<T>(Future<T> Function(YoutubeExplode yt) body) async {
    try {
      final result = await body(await client);
      onNetwork?.call(true);
      return result;
    } on ApiException {
      rethrow;
    } catch (e) {
      final api = mapError(e);
      if (api.code == ApiErrorCode.backendOffline) onNetwork?.call(false);
      throw api;
    }
  }

  static ApiException mapError(Object e) => switch (e) {
    ApiException() => e,
    SocketException() ||
    http.ClientException() ||
    TimeoutException() => const ApiException(
      ApiErrorCode.backendOffline,
      'Sin conexión a internet.',
    ),
    VideoUnavailableException() ||
    VideoUnplayableException() ||
    VideoRequiresPurchaseException() => const ApiException(
      ApiErrorCode.unavailable,
    ),
    RequestLimitExceededException() => const ApiException(
      ApiErrorCode.rateLimited,
    ),
    _ => ApiException(ApiErrorCode.extractionFailed, '$e'),
  };

  void close() {
    _yt?.close();
  }
}

/// Looks [name] up in PATH (and common install dirs). Null when missing.
Future<String?> findExecutable(String name) async {
  final exe = Platform.isWindows ? '$name.exe' : name;
  final home =
      Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
  final dirs = [
    ...?Platform.environment['PATH']?.split(Platform.isWindows ? ';' : ':'),
    if (home != null) ...['$home/.deno/bin', '$home/.local/bin'],
    '/usr/local/bin',
    '/opt/homebrew/bin',
  ];
  for (final d in dirs) {
    if (d.isEmpty) continue;
    final f = File('$d${Platform.pathSeparator}$exe');
    if (await f.exists()) return f.path;
  }
  return null;
}

/// yt-dlp's `visionos` client. For licensed music it is the only client
/// whose stream URLs serve the whole file without a PO token or JS player;
/// ANDROID URLs answer 403 after the first ~1 MB. Needs the watch page.
/// Keep in sync with yt-dlp's `INNERTUBE_CLIENTS['visionos']`.
const visionOsClient = yt.YoutubeApiClient(
  {
    'context': {
      'client': {
        'clientName': 'VISIONOS',
        'clientVersion': '1.02',
        'deviceMake': 'Apple',
        'deviceModel': 'RealityDevice17,1',
        'userAgent':
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 15_7_3) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.0 Safari/605.1.15',
        'osName': 'visionOS',
        'osVersion': '26.5.23O471',
        'hl': 'en',
        'timeZone': 'UTC',
        'utcOffsetMinutes': 0,
      },
    },
  },
  'https://www.youtube.com/youtubei/v1/player?prettyPrint=false',
  headers: {'X-YouTube-Client-Name': '101', 'X-YouTube-Client-Version': '1.02'},
);

/// Audio manifest whose streams can be read to the end (RF-07, RNF-02).
/// Tries VISIONOS (~1 s), then the fast `androidSdkless` client (~0.3 s, full
/// streams only for non-licensed videos), then the full multi-client lookup.
/// Throws `extractionFailed` when no client serves a whole stream, so the
/// caller can fall back to yt-dlp.
Future<yt.StreamManifest> audioManifest(
  yt.YoutubeExplode client,
  String videoId,
) async {
  final attempts = <Future<yt.StreamManifest> Function()>[
    () =>
        client.videos.streams.getManifest(videoId, ytClients: [visionOsClient]),
    () => client.videos.streams.getManifest(
      videoId,
      ytClients: [yt.YoutubeApiClient.androidSdkless],
      requireWatchPage: false,
    ),
    () => client.videos.streams.getManifest(videoId),
  ];
  Object? lastError;
  for (final attempt in attempts) {
    try {
      final m = await attempt();
      if (m.audioOnly.isEmpty) continue;
      if (await servesWholeStream(m.audioOnly.sortByBitrate().first)) {
        return m;
      }
    } on SocketException {
      rethrow;
    } on http.ClientException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } catch (e) {
      lastError = e;
    }
  }
  if (lastError != null) {
    final mapped = YoutubeGateway.mapError(lastError);
    if (mapped.code != ApiErrorCode.extractionFailed) throw mapped;
  }
  throw const ApiException(
    ApiErrorCode.extractionFailed,
    'YouTube solo entregó el inicio de la canción.',
  );
}

/// Reads the last byte: restricted URLs serve the start and answer 403
/// further in. Only YouTube media URLs with a known length are checked.
Future<bool> servesWholeStream(
  yt.StreamInfo info, [
  http.Client? client,
]) async {
  final url = info.url;
  final length = int.tryParse(url.queryParameters['clen'] ?? '');
  if (!url.host.endsWith('.googlevideo.com') || length == null || length < 2) {
    return true;
  }
  final httpClient = client ?? http.Client();
  try {
    final request = http.Request('GET', url)
      ..headers.addAll(yt.YoutubeHttpClient.defaultHeaders)
      ..headers['Range'] = 'bytes=${length - 1}-${length - 1}';
    final response = await httpClient
        .send(request)
        .timeout(const Duration(seconds: 15));
    await response.stream.drain<void>();
    return response.statusCode == 206 || response.statusCode == 200;
  } finally {
    if (client == null) httpClient.close();
  }
}
