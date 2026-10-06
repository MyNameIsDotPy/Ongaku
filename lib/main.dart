import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/ongaku_app.dart';
import 'core/local/local_services.dart';
import 'core/local/ongaku_audio_handler.dart';
import 'providers/repository_providers.dart';
import 'providers/settings_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Windows and Linux play through libmpv.
  JustAudioMediaKit.ensureInitialized(linux: true, windows: true);

  final prefs = await SharedPreferences.getInstance();
  final local = await LocalServices.open();
  // Writes are debounced; don't lose the last change when the app is
  // backgrounded or closed.
  AppLifecycleListener(onHide: local.flush, onDetach: local.flush);

  // Music focus: duck for notifications, pause for calls (RF-13).
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());

  // Media session: foreground service + notification on Android, Now
  // Playing and media keys on macOS (RF-11, RF-12).
  OngakuAudioHandler? handler;
  if (Platform.isAndroid || Platform.isMacOS) {
    handler = await AudioService.init(
      builder: OngakuAudioHandler.new,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.example.ongaku.playback',
        androidNotificationChannelName: 'Reproducción',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );
  }

  runApp(
    ProviderScope(
      // Errors are shown with a "Reintentar" button; no silent auto-retry.
      retry: (_, _) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        localServicesProvider.overrideWithValue(local),
        audioHandlerProvider.overrideWithValue(handler),
      ],
      child: const OngakuApp(),
    ),
  );
}
