import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/demo_scenario.dart';
import 'repository_providers.dart';

/// Which backend condition the fakes simulate (Ajustes → Simulación).
class DemoScenarioNotifier extends Notifier<DemoScenario> {
  @override
  DemoScenario build() => DemoScenario.normal;

  void set(DemoScenario scenario) {
    ref.read(fakeBackendProvider).scenario = scenario;
    state = scenario;
  }
}

final demoScenarioProvider =
    NotifierProvider<DemoScenarioNotifier, DemoScenario>(
      DemoScenarioNotifier.new,
    );

/// False when the backend does not answer (RF-29).
final backendOnlineProvider = Provider<bool>(
  (ref) => ref.watch(demoScenarioProvider) != DemoScenario.offline,
);
