import '../../models/album.dart';
import '../../models/api_error.dart';
import '../../models/artist.dart';
import '../../models/beat_map.dart';
import '../../models/lyrics.dart';
import '../../models/playlist.dart';
import '../../models/search_results.dart';
import '../../models/track.dart';
import '../catalog_repository.dart';
import 'fake_backend.dart';
import 'sample_data.dart';

class FakeCatalogRepository implements CatalogRepository {
  FakeCatalogRepository(this._backend, {required this.libraryPlaylists});

  final FakeBackend _backend;

  /// Own playlists are searchable too.
  final List<Playlist> Function() libraryPlaylists;

  SampleData get _data => SampleData.instance;

  @override
  Future<SearchResults> search(String query) => _backend(() {
    final n = normalize(query.trim());
    if (n.isEmpty || _backend.isEmpty) return const SearchResults();
    bool hit(String s) => normalize(s).contains(n);
    return SearchResults(
      tracks: _data.allTracks
          .where((t) => hit('${t.title} ${t.artistNames}'))
          .toList(),
      albums: _data.albums.values
          .where((a) => hit('${a.title} ${a.artist.name}'))
          .toList(),
      artists: _data.artistNames.keys
          .where((id) => hit(_data.artistNames[id]!))
          .map((id) => _data.artist(id)!)
          .toList(),
      playlists: libraryPlaylists()
          .where((p) => p.inLibrary && hit(p.name))
          .toList(),
    );
  });

  @override
  Future<List<String>> suggestions(String query) async {
    final n = normalize(query.trim());
    if (n.isEmpty || _backend.isOffline) return const [];
    final pool = {
      ..._data.artistNames.values,
      ..._data.albums.values.map((a) => a.title),
      ..._data.allTracks.map((t) => t.title),
    };
    return pool
        .where((s) => normalize(s).contains(n) && normalize(s) != n)
        .take(5)
        .toList();
  }

  @override
  Future<Album> album(String id) => _backend(() {
    return _data.albums[id] ??
        (throw const ApiException(ApiErrorCode.notFound));
  }, cacheable: true);

  @override
  Future<Artist> artist(String id) => _backend(() {
    return _data.artist(id) ??
        (throw const ApiException(ApiErrorCode.notFound));
  }, cacheable: true);

  @override
  Future<Playlist> youtubePlaylist(String idOrUrl) => _backend(() {
    final id = youtubePlaylistId(idOrUrl) ?? idOrUrl;
    final sample = _data.initialPlaylists().firstWhere(
      (p) => p.source == PlaylistSource.youtube,
    );
    // Any pasted id previews the sample YouTube playlist.
    return sample.copyWith(sourceId: id.isEmpty ? sample.sourceId : id);
  });

  @override
  Future<List<Track>> radio(String videoId) => _backend(() {
    final seed = _data.track(videoId);
    final genre = _data.albums[seed.album!.id]!.genre;
    final pool =
        _data.allTracks
            .where(
              (t) =>
                  t.videoId != videoId &&
                  !t.unavailable &&
                  (t.primaryArtist.id == seed.primaryArtist.id ||
                      _data.albums[t.album!.id]!.genre == genre),
            )
            .toList()
          ..shuffle();
    final rest =
        _data.allTracks
            .where(
              (t) =>
                  !pool.contains(t) && t.videoId != videoId && !t.unavailable,
            )
            .toList()
          ..shuffle();
    return [seed, ...pool, ...rest].take(25).toList();
  });

  @override
  Future<List<Album>> explore() =>
      _backend(() => _data.albums.values.take(6).toList(), cacheable: true);

  @override
  Future<Track?> track(String videoId) async => _data._safeTrack(videoId);

  @override
  Future<BeatMap> beatMap(Track track) async =>
      BeatMap.steady(88.0 + _hash(track.videoId) % 36, track.duration);

  @override
  Future<Lyrics?> lyrics(String videoId) async {
    final track = _data._safeTrack(videoId);
    if (track == null) return null;
    return _sampleLyrics(track);
  }

  /// Sample (non-real) lyrics laid out on the song's bar grid, ported from the
  /// prototype so the synced view has something to follow.
  Lyrics _sampleLyrics(Track track) {
    final bar = 240 / (88 + _hash(track.videoId) % 36);
    final totalBars = (track.duration.inMilliseconds / 1000 / bar).floor();
    Duration at(double seconds) =>
        Duration(milliseconds: (seconds * 1000).round());

    final lines = <LyricLine>[];
    var b = 0;
    var prevEnd = 0.0;
    for (final (name, len) in _plan) {
      if (b + len > totalBars - 2) break;
      final verse = _verses[name];
      if (verse != null) {
        for (var i = 0; i < verse.length; i++) {
          final span = len / verse.length;
          final t0 = (b + i * span) * bar;
          final t1 = (b + (i + 1) * span) * bar - bar * 0.25;
          if (t0 - prevEnd > bar * 2) {
            lines.add(
              LyricLine(start: at(prevEnd), end: at(t0), instrumental: true),
            );
          }
          lines.add(LyricLine(start: at(t0), end: at(t1), text: verse[i]));
          prevEnd = t1;
        }
      }
      b += len;
    }
    lines.add(
      LyricLine(start: at(prevEnd), end: track.duration, instrumental: true),
    );
    return Lyrics(synced: true, lines: lines);
  }

  static const _plan = [
    ('intro', 4), ('v1', 8), ('ch', 8), ('inter', 4), //
    ('v2', 8), ('ch', 8), ('br', 8), ('ch', 8),
  ];
  static const _verses = {
    'v1': [
      'Las luces de la calle se mueven al compás',
      'el bus dobla la esquina y yo no miro atrás',
      'llevo el mundo en los audífonos, la ciudad en la piel',
      'cada parada es un verso que aprendo a leer',
    ],
    'ch': [
      'Y suena, suena, no se corta',
      'aunque la noche sea larga y la pantalla esté apagada',
      'suena, suena, no se apaga',
      'la canción me sigue a casa',
    ],
    'v2': [
      'Guardé tus canciones para cuando no haya señal',
      'una lista para el viaje, otra para respirar',
      'el bajo late despacio debajo del pavimento',
      'y el coro llega justo cuando lo necesito',
    ],
    'br': ['Respira', 'deja que el ritmo te lleve', 'respira', 'todo vuelve'],
  };
}

int _hash(String s) {
  var h = 2166136261;
  for (final c in s.codeUnits) {
    h ^= c;
    h = (h * 16777619) & 0xFFFFFFFF;
  }
  return h;
}

extension on SampleData {
  Track? _safeTrack(String id) {
    try {
      return track(id);
    } catch (_) {
      return null;
    }
  }
}
