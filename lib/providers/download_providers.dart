import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/demo_scenario.dart';
import '../models/download_entry.dart';
import '../models/track.dart';
import 'demo_providers.dart';
import 'repository_providers.dart';
import 'settings_providers.dart';

class DownloadsNotifier extends Notifier<Map<String, DownloadEntry>> {
  @override
  Map<String, DownloadEntry> build() {
    final manager = ref.watch(downloadManagerProvider);
    final empty = ref.watch(demoScenarioProvider) == DemoScenario.empty;
    final sub = manager.watch().listen((s) => state = empty ? const {} : s);
    ref.onDispose(sub.cancel);
    return empty ? const {} : manager.current;
  }

  Future<void> download({
    required String id,
    required DownloadKind kind,
    required String title,
    required List<Track> tracks,
  }) => ref
      .read(downloadManagerProvider)
      .download(
        collectionId: id,
        kind: kind,
        title: title,
        tracks: tracks,
        limitBytes: ref.read(settingsProvider).downloadLimitGb * 1073741824,
      );

  Future<void> remove(String id) =>
      ref.read(downloadManagerProvider).remove(id);
  Future<void> clear() => ref.read(downloadManagerProvider).clear();
}

final downloadsProvider =
    NotifierProvider<DownloadsNotifier, Map<String, DownloadEntry>>(
      DownloadsNotifier.new,
    );

/// Whether the song's file is on this device (a failed song in a
/// downloaded album is not).
final isDownloadedProvider = Provider.family<bool, String>((ref, videoId) {
  if (ref.watch(downloadsProvider).isEmpty) return false;
  return ref.watch(downloadManagerProvider).isTrackDownloaded(videoId);
});

/// Megabytes on disk; songs shared by several lists count once.
final downloadsUsedMbProvider = Provider<double>((ref) {
  if (ref.watch(downloadsProvider).isEmpty) return 0;
  return ref.watch(downloadManagerProvider).usedMb;
});
