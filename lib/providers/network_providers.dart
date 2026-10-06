import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings.dart';
import 'settings_providers.dart';

/// Current link type, for quality (RNF-07) and Wi-Fi-only downloads (RF-27).
final connectionTypeProvider = StreamProvider<List<ConnectivityResult>>((
  ref,
) async* {
  final c = Connectivity();
  yield await c.checkConnectivity();
  yield* c.onConnectivityChanged;
});

final onMobileDataProvider = Provider<bool>((ref) {
  final types = ref.watch(connectionTypeProvider).value ?? const [];
  return types.contains(ConnectivityResult.mobile) &&
      !types.contains(ConnectivityResult.wifi) &&
      !types.contains(ConnectivityResult.ethernet);
});

final offlineByOsProvider = Provider<bool>((ref) {
  final types = ref.watch(connectionTypeProvider).value;
  return types != null && types.every((t) => t == ConnectivityResult.none);
});

/// Quality for the next song: Wi-Fi setting, or mobile-data setting.
final audioQualityProvider = Provider<AudioQuality>((ref) {
  final s = ref.watch(settingsProvider);
  return ref.watch(onMobileDataProvider) ? s.mobileQuality : s.wifiQuality;
});

/// Whether YouTube answered the last request (RF-29). Requests report back
/// through the gateway's `onNetwork` callback.
class YoutubeReachableNotifier extends Notifier<bool> {
  @override
  bool build() => true;
  void report(bool reachable) {
    if (state != reachable) state = reachable;
  }
}

final youtubeReachableProvider =
    NotifierProvider<YoutubeReachableNotifier, bool>(
      YoutubeReachableNotifier.new,
    );
