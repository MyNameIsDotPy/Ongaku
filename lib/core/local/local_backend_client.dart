import 'dart:async';

import '../../models/api_error.dart';
import '../../models/app_settings.dart';
import '../../models/connection_test.dart';
import '../backend_client.dart';
import 'youtube_gateway.dart';

/// "Probar conexión" for local mode: like the backend's `/health`, it
/// extracts a known video to check that YouTube still works.
class LocalBackendClient implements BackendClient {
  LocalBackendClient(this._gateway);

  final YoutubeGateway _gateway;

  /// A long-lived, embeddable music video.
  static const probeVideoId = 'dQw4w9WgXcQ';

  @override
  Future<ConnectionTestResult> testConnection(AppSettings settings) async {
    final watch = Stopwatch()..start();
    try {
      await _gateway((yt) async {
        final m = await audioManifest(yt, probeVideoId);
        if (m.audioOnly.isEmpty) {
          throw const ApiException(ApiErrorCode.extractionFailed);
        }
      }).timeout(const Duration(seconds: 40));
      return ConnectionTestResult.success(latencyMs: watch.elapsedMilliseconds);
    } on ApiException catch (e) {
      return ConnectionTestResult.failure(code: e.code);
    } on TimeoutException {
      // A request that never answers must not leave the spinner running.
      return ConnectionTestResult.failure(code: ApiErrorCode.backendOffline);
    }
  }
}
