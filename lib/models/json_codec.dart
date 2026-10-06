import 'download_entry.dart';
import 'library_snapshot.dart';
import 'play_event.dart';
import 'playlist.dart';
import 'track.dart';

/// JSON for the on-device library and downloads (no codegen needed).
abstract final class JsonCodecs {
  static Map<String, Object?> track(Track t) => {
    'videoId': t.videoId,
    'title': t.title,
    'artists': [
      for (final a in t.artists) {'id': a.id, 'name': a.name},
    ],
    if (t.album != null) 'album': {'id': t.album!.id, 'name': t.album!.name},
    'durationMs': t.duration.inMilliseconds,
    'cover': t.coverUrl,
    if (t.palette.isNotEmpty) 'palette': t.palette,
  };

  static Track trackFrom(Map<String, Object?> m) {
    final album = m['album'] as Map<String, Object?>?;
    return Track(
      videoId: m['videoId']! as String,
      title: m['title']! as String,
      artists: [
        for (final a
            in (m['artists'] as List? ?? const []).cast<Map<String, Object?>>())
          ArtistRef(id: a['id']! as String, name: a['name']! as String),
      ],
      album: album == null
          ? null
          : AlbumRef(
              id: album['id']! as String,
              name: album['name']! as String,
            ),
      duration: Duration(milliseconds: (m['durationMs'] as num? ?? 0).toInt()),
      coverUrl: m['cover'] as String? ?? '',
      palette: (m['palette'] as List? ?? const []).cast<int>(),
    );
  }

  static Map<String, Object?> library(LibrarySnapshot s) => {
    'version': 1,
    'playlists': [
      for (final p in s.playlists)
        {
          'id': p.id,
          'name': p.name,
          'source': p.source.name,
          'sourceId': p.sourceId,
          'owner': p.owner,
          'createdAt': p.createdAt.toIso8601String(),
          'inLibrary': p.inLibrary,
          'tracks': [for (final t in p.tracks) track(t)],
        },
    ],
    'favorites': [for (final t in s.favorites) track(t)],
    'history': [
      for (final e in s.history)
        {
          'track': track(e.track),
          'playedAt': e.playedAt.toIso8601String(),
          'device': e.device.name,
        },
    ],
  };

  static LibrarySnapshot libraryFrom(Map<String, Object?> m) {
    List<Map<String, Object?>> list(Object? v) =>
        (v as List? ?? const []).cast<Map<String, Object?>>();
    return LibrarySnapshot(
      playlists: [
        for (final p in list(m['playlists']))
          Playlist(
            id: p['id']! as String,
            name: p['name']! as String,
            source: PlaylistSource.values.firstWhere(
              (s) => s.name == p['source'],
              orElse: () => PlaylistSource.own,
            ),
            sourceId: p['sourceId'] as String?,
            owner: p['owner'] as String?,
            createdAt:
                DateTime.tryParse(p['createdAt'] as String? ?? '') ??
                DateTime.now(),
            inLibrary: p['inLibrary'] as bool? ?? true,
            tracks: [for (final t in list(p['tracks'])) trackFrom(t)],
          ),
      ],
      favorites: [for (final t in list(m['favorites'])) trackFrom(t)],
      history: [
        for (final e in list(m['history']))
          PlayEvent(
            track: trackFrom(e['track']! as Map<String, Object?>),
            playedAt:
                DateTime.tryParse(e['playedAt'] as String? ?? '') ??
                DateTime.now(),
            device: DeviceKind.values.firstWhere(
              (d) => d.name == e['device'],
              orElse: () => DeviceKind.pc,
            ),
          ),
      ],
    );
  }

  static Map<String, Object?> download(
    DownloadEntry e,
    Map<String, String> files,
  ) => {
    'collectionId': e.collectionId,
    'kind': e.kind.name,
    'title': e.title,
    'trackIds': e.trackIds,
    'completedTracks': e.completedTracks,
    'sizeMb': e.sizeMb,
    'status': e.status.name,
    'files': {
      for (final id in e.trackIds)
        if (files[id] != null) id: files[id],
    },
  };

  static DownloadEntry downloadFrom(Map<String, Object?> m) => DownloadEntry(
    collectionId: m['collectionId']! as String,
    kind: DownloadKind.values.firstWhere(
      (k) => k.name == m['kind'],
      orElse: () => DownloadKind.playlist,
    ),
    title: m['title'] as String? ?? '',
    trackIds: (m['trackIds'] as List? ?? const []).cast<String>(),
    completedTracks: (m['completedTracks'] as num? ?? 0).toInt(),
    sizeMb: (m['sizeMb'] as num? ?? 0).toDouble(),
    // An interrupted download is not resumed automatically.
    status: m['status'] == 'done' ? DownloadStatus.done : DownloadStatus.failed,
  );
}
