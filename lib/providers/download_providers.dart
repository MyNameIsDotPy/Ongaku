import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/demo_scenario.dart';
import '../models/download_entry.dart';
import '../models/track.dart';
import 'demo_providers.dart';
import 'repository_providers.dart';

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
      .download(collectionId: id, kind: kind, title: title, tracks: tracks);

  Future<void> remove(String id) =>
      ref.read(downloadManagerProvider).remove(id);
  Future<void> clear() => ref.read(downloadManagerProvider).clear();
}

final downloadsProvider =
    NotifierProvider<DownloadsNotifier, Map<String, DownloadEntry>>(
      DownloadsNotifier.new,
    );

final isDownloadedProvider = Provider.family<bool, String>((ref, videoId) {
  final entries = ref.watch(downloadsProvider);
  return entries.values.any((e) {
    final i = e.trackIds.indexOf(videoId);
    return i >= 0 && i < e.completedTracks;
  });
});

/// Megabytes used by finished downloads.
final downloadsUsedMbProvider = Provider<double>(
  (ref) =>
      ref.watch(downloadsProvider).values.fold(0.0, (sum, e) => sum + e.sizeMb),
);
