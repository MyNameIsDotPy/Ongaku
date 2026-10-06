import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

/// Overridden in `main()` with the loaded instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override in main()'),
);

const _prefsKey = 'ongaku.settings.';

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return AppSettings.fromPrefs({
      for (final k in prefs.getKeys().where((k) => k.startsWith(_prefsKey)))
        k.substring(_prefsKey.length): prefs.get(k),
    });
  }

  Future<void> update(AppSettings Function(AppSettings) change) async {
    state = change(state);
    final prefs = ref.read(sharedPreferencesProvider);
    for (final MapEntry(:key, :value) in state.toPrefs().entries) {
      final k = '$_prefsKey$key';
      switch (value) {
        case final bool v:
          await prefs.setBool(k, v);
        case final int v:
          await prefs.setInt(k, v);
        case final String v:
          await prefs.setString(k, v);
      }
    }
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

final themeModeProvider = Provider<ThemeMode>((ref) {
  return switch (ref.watch(settingsProvider.select((s) => s.theme))) {
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
    ThemePreference.system => ThemeMode.system,
  };
});
