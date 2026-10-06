import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings.dart';
import '../providers/settings_providers.dart';
import '../shared/design_system/design_system.dart';
import 'router.dart';

class OngakuApp extends ConsumerWidget {
  const OngakuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp.router(
      title: 'Ongaku',
      debugShowCheckedModeBanner: false,
      theme: OngakuTheme.light(),
      darkTheme: OngakuTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      themeAnimationDuration: OngakuMotion.medium,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) => OngakuMotionSettings(
        reduced: settings.motion == MotionLevel.reduced,
        reactive: settings.reactiveVisuals,
        child: child!,
      ),
    );
  }
}
