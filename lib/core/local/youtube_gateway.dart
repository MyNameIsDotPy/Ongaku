import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/js_challenge.dart';
import 'package:youtube_explode_dart/solvers.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

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

  /// On PC, a Deno install unlocks YouTube's JS challenges (more formats,
  /// fewer 403s). Phones run without it.
  Future<YoutubeExplode> get client => _starting ??= _start();

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

  void close() => _yt?.close();
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
