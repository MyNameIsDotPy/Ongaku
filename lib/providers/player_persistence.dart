import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/json_codec.dart';
import '../models/player_snapshot.dart';
import '../models/track.dart';
import 'settings_providers.dart';

class SavedQueue {
  const SavedQueue(this.tracks, this.index, this.position, this.source);
  final List<Track> tracks;
  final int index;
  final Duration position;
  final String source;
}

const _key = 'ongaku.player.queue';

/// The queue saved by the last session (RF-16), if any.
final savedQueueProvider = Provider<SavedQueue?>((ref) {
  final raw = ref.watch(sharedPreferencesProvider).getString(_key);
  if (raw == null) return null;
  try {
    final m = jsonDecode(raw) as Map<String, Object?>;
    return SavedQueue(
      [
        for (final t in (m['queue'] as List).cast<Map<String, Object?>>())
          JsonCodecs.trackFrom(t),
      ],
      (m['index'] as num).toInt(),
      Duration(milliseconds: (m['positionMs'] as num).toInt()),
      m['source'] as String? ?? 'Cola',
    );
  } catch (_) {
    return null;
  }
});

/// Writes the queue, song and position; called on changes and periodically.
void saveQueue(Ref ref, PlayerSnapshot s, Duration position) {
  if (s.queue.isEmpty) return;
  ref
      .read(sharedPreferencesProvider)
      .setString(
        _key,
        jsonEncode({
          // Large queues (radio, 1000-song playlists) are trimmed around the
          // current song to keep the preference small.
          'queue': [
            for (final t in s.queue.skip(s.index).take(300))
              JsonCodecs.track(t),
          ],
          'index': 0,
          'positionMs': position.inMilliseconds,
          'source': s.sourceLabel,
        }),
      );
}
