import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/backend_client.dart';
import '../core/catalog_repository.dart';
import '../core/download_manager.dart';
import '../core/fakes/fake_backend.dart';
import '../core/fakes/fake_backend_client.dart';
import '../core/fakes/fake_catalog_repository.dart';
import '../core/fakes/fake_download_manager.dart';
import '../core/fakes/fake_library_repository.dart';
import '../core/fakes/sample_data.dart';
import '../core/library_repository.dart';
import '../core/local/just_audio_engine.dart';
import '../core/local/local_backend_client.dart';
import '../core/local/local_catalog_repository.dart';
import '../core/local/local_services.dart';
import '../core/local/ongaku_audio_handler.dart';
import '../core/local/stream_resolver.dart';
import '../core/local/yt_dlp.dart';
import '../core/player/queue_player_controller.dart';
import '../core/player/simulated_engine.dart';
import '../core/player_controller.dart';
import '../models/app_settings.dart';
import 'network_providers.dart';
import 'player_persistence.dart';
import 'settings_providers.dart';

/// Opened in `main()`; null in tests and when running on sample data only.
final localServicesProvider = Provider<LocalServices?>((ref) => null);

/// The OS media session (Android); null where unsupported.
final audioHandlerProvider = Provider<OngakuAudioHandler?>((ref) => null);

/// YouTube on this device, unless sample data is selected or local storage
/// is unavailable (tests).
final musicSourceProvider = Provider<MusicSource>((ref) {
  final chosen = ref.watch(settingsProvider.select((s) => s.source));
  return ref.watch(localServicesProvider) == null ? MusicSource.sample : chosen;
});

bool _local(Ref ref) => ref.watch(musicSourceProvider) == MusicSource.youtube;

/// Simulates backend conditions for the sample catalog (Ajustes).
final fakeBackendProvider = Provider<FakeBackend>((ref) => FakeBackend());

final _fakeLibraryProvider = Provider((ref) => FakeLibraryRepository());
final _fakeDownloadsProvider = Provider((ref) => FakeDownloadManager());

final libraryRepositoryProvider = Provider<LibraryRepository>(
  (ref) => _local(ref)
      ? ref.watch(localServicesProvider)!.library
      : ref.watch(_fakeLibraryProvider),
);

final downloadManagerProvider = Provider<DownloadManager>(
  (ref) => _local(ref)
      ? ref.watch(localServicesProvider)!.downloads
      : ref.watch(_fakeDownloadsProvider),
);

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  final library = ref.watch(libraryRepositoryProvider);
  if (_local(ref)) {
    final gateway = ref.watch(localServicesProvider)!.gateway
      ..onNetwork = ref.read(youtubeReachableProvider.notifier).report;
    return LocalCatalogRepository(
      gateway,
      beats: ref.watch(localServicesProvider)!.beats,
      libraryPlaylists: () => library.current.playlists,
    );
  }
  return FakeCatalogRepository(
    ref.watch(fakeBackendProvider),
    libraryPlaylists: () => library.current.playlists,
  );
});

final backendClientProvider = Provider<BackendClient>(
  (ref) => _local(ref)
      ? LocalBackendClient(ref.watch(localServicesProvider)!.gateway)
      : FakeBackendClient(ref.watch(fakeBackendProvider)),
);

final streamResolverProvider = Provider<StreamResolver>((ref) {
  final local = ref.watch(localServicesProvider)!;
  return StreamResolver(
    local.gateway,
    ytDlp: YtDlp(
      configuredPath: ref.watch(settingsProvider.select((s) => s.ytDlpPath)),
    ),
    localFile: local.downloads.fileFor,
  );
});

final playerControllerProvider = Provider<PlayerController>((ref) {
  final PlayerController controller;
  if (_local(ref)) {
    // RF-16: restore the queue, song and position from the last session.
    final saved = ref.read(savedQueueProvider);
    controller = QueuePlayerController(
      JustAudioEngine(
        ref.watch(streamResolverProvider),
        quality: () => ref.read(audioQualityProvider),
      ),
      restoredQueue: saved?.tracks ?? const [],
      restoredIndex: saved?.index ?? 0,
      resumeAt: saved?.position ?? Duration.zero,
      sourceLabel: saved?.source ?? 'Cola',
    );
  } else {
    final library = ref.watch(libraryRepositoryProvider).current;
    controller = QueuePlayerController(
      SimulatedEngine(),
      sourceLabel: 'Para TransMilenio',
      restoredQueue: library.playlists.isEmpty
          ? SampleData.instance.allTracks.take(10).toList()
          : library.playlists.first.tracks,
    );
  }
  ref.read(audioHandlerProvider)?.attach(controller);
  ref.onDispose(controller.dispose);
  return controller;
});

/// Installed yt-dlp version on PC (null when missing or unsupported).
final ytDlpVersionProvider = FutureProvider<String?>((ref) async {
  if (!YtDlp.supported) return null;
  final path = ref.watch(settingsProvider.select((s) => s.ytDlpPath));
  return YtDlp(configuredPath: path).version();
});
