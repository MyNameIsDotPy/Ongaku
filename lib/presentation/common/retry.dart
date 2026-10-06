import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import '../../models/demo_scenario.dart';
import '../../providers/demo_providers.dart';

/// "Reintentar": with the fakes, a simulated failure clears on retry (as in
/// the prototype); then the given providers are refreshed.
void retry(WidgetRef ref, [List<ProviderOrFamily> providers = const []]) {
  final scenario = ref.read(demoScenarioProvider);
  if (scenario == DemoScenario.error || scenario == DemoScenario.loading) {
    ref.read(demoScenarioProvider.notifier).set(DemoScenario.normal);
  }
  for (final p in providers) {
    ref.invalidate(p);
  }
}
