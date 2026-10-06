import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings.dart';
import '../models/demo_scenario.dart';
import 'network_providers.dart';
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

/// False when music cannot be fetched (RF-29): no network, YouTube not
/// answering, or the simulated "sin backend" state for sample data.
final backendOnlineProvider = Provider<bool>((ref) {
  if (ref.watch(musicSourceProvider) == MusicSource.sample) {
    return ref.watch(demoScenarioProvider) != DemoScenario.offline;
  }
  return ref.watch(youtubeReachableProvider) && !ref.watch(offlineByOsProvider);
});
