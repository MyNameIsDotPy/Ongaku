import '../../models/api_error.dart';
import '../../models/app_settings.dart';
import '../../models/connection_test.dart';
import '../backend_client.dart';
import 'fake_backend.dart';

class FakeBackendClient implements BackendClient {
  FakeBackendClient(this._backend);

  final FakeBackend _backend;

  /// Any token starting with `od_` is accepted, like the prototype.
  @override
  Future<ConnectionTestResult> testConnection(AppSettings settings) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (_backend.isOffline) {
      return const ConnectionTestResult.failure(
        code: ApiErrorCode.backendOffline,
      );
    }
    if (!settings.token.startsWith('od_')) {
      return const ConnectionTestResult.failure(
        code: ApiErrorCode.unauthorized,
      );
    }
    return const ConnectionTestResult.success(latencyMs: 84);
  }
}
