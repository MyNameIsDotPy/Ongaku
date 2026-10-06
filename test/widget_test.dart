import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ongaku/app/ongaku_app.dart';
import 'package:ongaku/providers/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('first run lands on the connection screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(ProviderScope(
      retry: (_, _) => null,
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const OngakuApp(),
    ));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Prepara tu música'), findsOneWidget);
  });
}
