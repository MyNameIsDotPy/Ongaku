import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/album.dart';
import '../models/artist.dart';
import '../models/beat_map.dart';
import '../models/lyrics.dart';
import '../models/playlist.dart';
import '../models/track.dart';
import 'demo_providers.dart';
import 'repository_providers.dart';

final albumProvider = FutureProvider.family<Album, String>((ref, id) {
  ref.watch(demoScenarioProvider);
  return ref.watch(catalogRepositoryProvider).album(id);
});

final artistProvider = FutureProvider.family<Artist, String>((ref, id) {
  ref.watch(demoScenarioProvider);
  return ref.watch(catalogRepositoryProvider).artist(id);
});

final exploreProvider = FutureProvider<List<Album>>((ref) {
  ref.watch(demoScenarioProvider);
  return ref.watch(catalogRepositoryProvider).explore();
});

final lyricsProvider = FutureProvider.family<Lyrics?, String>(
  (ref, videoId) => ref.watch(catalogRepositoryProvider).lyrics(videoId),
);

final beatMapProvider = FutureProvider.autoDispose.family<BeatMap, Track>(
  (ref, track) => ref.watch(catalogRepositoryProvider).beatMap(track),
);

/// A YouTube playlist that is not in the library yet (preview → import).
final remotePlaylistProvider = FutureProvider.family<Playlist, String>((
  ref,
  id,
) {
  ref.watch(demoScenarioProvider);
  return ref.watch(catalogRepositoryProvider).youtubePlaylist(id);
});
