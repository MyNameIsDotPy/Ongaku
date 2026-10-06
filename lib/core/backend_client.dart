import '../models/app_settings.dart';
import '../models/connection_test.dart';

/// Backend health / connection test (RF-28, `GET /health`).
abstract interface class BackendClient {
  Future<ConnectionTestResult> testConnection(AppSettings settings);
}
