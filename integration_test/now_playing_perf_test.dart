// Frame timings while opening and closing the player (sample catalog).
// Run in profile mode on a device:
// flutter drive --profile -d <device> --driver=test_driver/perf_driver.dart \
//   --target=integration_test/now_playing_perf_test.dart
// Results: build/integration_response_data.json
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ongaku/app/ongaku_app.dart';
import 'package:ongaku/app/router.dart';
import 'package:ongaku/app/routes.dart';
import 'package:ongaku/core/fakes/sample_data.dart';
import 'package:ongaku/providers/player_providers.dart';
import 'package:ongaku/providers/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> wait(int ms) => Future<void>.delayed(Duration(milliseconds: ms));

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('open and close the player', (tester) async {
    SharedPreferences.setMockInitialValues({
      'ongaku.settings.onboardingComplete': true,
    });
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const OngakuApp(),
      ),
    );
    await wait(2000);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(OngakuApp)),
    );
    final tracks = SampleData.instance.allTracks.take(6).toList();
    final router = container.read(routerProvider);

    await binding.watchPerformance(() async {
      for (var i = 0; i < 4; i++) {
        // Pick a song, then open the player as from the mini-player.
        container.read(playerProvider.notifier).play(tracks, start: i);
        await wait(400);
        router.push(Routes.nowPlaying);
        await wait(1500);
        router.pop();
        await wait(1200);
      }
    }, reportKey: 'now_playing');
  });
}
