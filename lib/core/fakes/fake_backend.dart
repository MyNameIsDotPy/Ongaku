import 'dart:async';

import '../../models/api_error.dart';
import '../../models/demo_scenario.dart';

/// Shared switch that makes every Fake* repository behave like the backend
/// under a given [DemoScenario].
class FakeBackend {
  FakeBackend({this.latency = const Duration(milliseconds: 280)});

  final Duration latency;
  DemoScenario scenario = DemoScenario.normal;

  bool get isOffline => scenario == DemoScenario.offline;
  bool get isEmpty => scenario == DemoScenario.empty;

  /// Runs [body] after simulated latency, failing or hanging per scenario.
  Future<T> call<T>(T Function() body, {bool cacheable = false}) async {
    switch (scenario) {
      case DemoScenario.loading:
        // Never resolves; providers recompute when the scenario changes.
        return Completer<T>().future;
      case DemoScenario.error:
        await Future<void>.delayed(latency);
        throw const ApiException(ApiErrorCode.extractionFailed);
      case DemoScenario.offline when !cacheable:
        await Future<void>.delayed(latency);
        throw const ApiException(ApiErrorCode.backendOffline);
      default:
        await Future<void>.delayed(latency);
        return body();
    }
  }
}
