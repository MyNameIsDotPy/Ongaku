import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/backend_client.dart';
import '../core/catalog_repository.dart';
import '../core/download_manager.dart';
import '../core/fakes/fake_backend.dart';
import '../core/fakes/fake_backend_client.dart';
import '../core/fakes/fake_catalog_repository.dart';
import '../core/fakes/fake_download_manager.dart';
import '../core/fakes/fake_library_repository.dart';
import '../core/fakes/fake_player_controller.dart';
import '../core/fakes/sample_data.dart';
import '../core/library_repository.dart';
import '../core/player_controller.dart';

/// Until the `core` package is ready, every contract is backed by a Fake*.
/// Swap these overrides for the real implementations; the UI does not change.
final fakeBackendProvider = Provider<FakeBackend>((ref) => FakeBackend());

final libraryRepositoryProvider = Provider<LibraryRepository>(
  (ref) => FakeLibraryRepository(),
);

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  final library = ref.watch(libraryRepositoryProvider);
  return FakeCatalogRepository(
    ref.watch(fakeBackendProvider),
    libraryPlaylists: () => library.current.playlists,
  );
});

final downloadManagerProvider = Provider<DownloadManager>(
  (ref) => FakeDownloadManager(),
);

final backendClientProvider = Provider<BackendClient>(
  (ref) => FakeBackendClient(ref.watch(fakeBackendProvider)),
);

final playerControllerProvider = Provider<PlayerController>((ref) {
  final library = ref.watch(libraryRepositoryProvider).current;
  // RF-16: the fake restores the first playlist as an idle queue.
  final controller = FakePlayerController(
    restoredQueue: library.playlists.isEmpty
        ? SampleData.instance.allTracks.take(10).toList()
        : library.playlists.first.tracks,
  );
  ref.onDispose(controller.dispose);
  return controller;
});
