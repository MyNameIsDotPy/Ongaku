import '../../models/album.dart';
import '../../models/artist.dart';
import '../../models/play_event.dart';
import '../../models/playlist.dart';
import '../../models/track.dart';
import 'sample_catalog.dart';

/// Sample catalog and library used by the Fake* repositories until the core
/// package talks to the real backend.
class SampleData {
  SampleData._() {
    for (final a in sampleAlbums) {
      final artistRef = ArtistRef(id: slug(a.artist), name: a.artist);
      final albumRef = AlbumRef(id: a.id, name: a.title);
      final tracks = [
        for (final t in a.tracks)
          Track(
            videoId: t.id,
            title: t.title,
            artists: [artistRef],
            album: albumRef,
            duration: Duration(seconds: t.seconds),
            coverUrl: a.cover,
            palette: a.palette,
            // Demonstrates RNF-12: skip and warn without stopping the queue.
            unavailable: t.id == 'deja-13',
          ),
      ];
      for (final t in tracks) {
        _tracks[t.videoId] = t;
      }
      albums[a.id] = Album(
        id: a.id,
        title: a.title,
        artist: artistRef,
        year: a.year,
        genre: a.genre,
        coverUrl: a.cover,
        palette: a.palette,
        tracks: tracks,
      );
      (artistAlbums[artistRef.id] ??= []).add(a.id);
      artistNames[artistRef.id] = a.artist;
    }
  }

  static final SampleData instance = SampleData._();

  final Map<String, Track> _tracks = {};
  final Map<String, Album> albums = {};
  final Map<String, List<String>> artistAlbums = {};
  final Map<String, String> artistNames = {};

  Track track(String id) => _tracks[id]!;
  Iterable<Track> get allTracks => _tracks.values;

  static const _artistPhotos = {
    'bomba-estereo': (
      'assets/images/artists/bomba-estereo.jpg',
      'Foto: CAMOGRAPHY · CC BY 2.0 · Wikimedia Commons',
    ),
  };
  static const _popular = {
    'bomba-estereo': [
      'ayo-3', 'amanecer-5', 'amanecer-2', 'deja-2', 'amanecer-4', 'ayo-1', //
    ],
  };

  Artist? artist(String id) {
    final albumIds = artistAlbums[id];
    if (albumIds == null) return null;
    final list = albumIds.map((a) => albums[a]!).toList();
    final popular =
        _popular[id]?.map(track).toList() ??
        list.expand((a) => a.tracks.take(3)).take(6).toList();
    final photo = _artistPhotos[id];
    return Artist(
      id: id,
      name: artistNames[id]!,
      photoUrl: photo?.$1,
      photoCredit: photo?.$2,
      popular: popular,
      albums: list,
    );
  }

  List<Playlist> initialPlaylists() {
    Playlist pl(
      String id,
      String name,
      String created,
      List<String> ids, {
      PlaylistSource source = PlaylistSource.own,
      String? sourceId,
      String? owner,
    }) => Playlist(
      id: id,
      name: name,
      source: source,
      sourceId: sourceId,
      owner: owner,
      createdAt: DateTime.parse(created),
      tracks: ids.map(track).toList(),
      inLibrary: source == PlaylistSource.own,
    );
    return [
      pl('pl-transmi', 'Para TransMilenio', '2026-08-02', [
        'ayo-3', 'amanecer-2', 'deja-1', 'ocean-2', 'juanes-4', 'vives-1', //
        'pipa-2', 'amanecer-5', 'mperine-1', 'shakira-1', 'deja-7',
      ]),
      pl('pl-code', 'Programando', '2026-07-14', [
        'ram-1', 'ram-5', 'ram-8', 'slowrush-1', 'slowrush-8', 'rainbows-1', //
        'rainbows-4', 'rainbows-7', 'ram-13', 'slowrush-3',
      ]),
      pl('pl-90s', 'Colombia 90', '2026-06-21', [
        'vives-1', 'vives-2', 'vives-3', 'shakira-1', 'shakira-4', 'pipa-1', //
        'pipa-11', 'pipa-7', 'shakira-9',
      ]),
      pl(
        'pl-yt-cumbia',
        'Cumbia electrónica',
        '2026-09-30',
        [
          'ayo-1', 'ayo-9', 'deja-7', 'amanecer-1', 'amanecer-6', //
          'mperine-5', 'mperine-9', 'vives-9',
        ],
        source: PlaylistSource.youtube,
        sourceId: 'PLx0ejemplo4kQm',
        owner: 'Canal de ejemplo',
      ),
    ];
  }

  List<Track> initialFavorites() => [
    'ayo-3', 'ram-8', 'rainbows-4', 'pipa-11', 'vives-2', 'deja-2', //
    'slowrush-8',
  ].map(track).toList();

  List<PlayEvent> initialHistory() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    PlayEvent e(String id, int daysAgo, int h, int m, DeviceKind d) =>
        PlayEvent(
          track: track(id),
          playedAt: today
              .subtract(Duration(days: daysAgo))
              .add(Duration(hours: h, minutes: m)),
          device: d,
        );
    return [
      e('ram-5', 0, 21, 42, DeviceKind.pc),
      e('ram-1', 0, 21, 36, DeviceKind.pc),
      e('rainbows-4', 0, 20, 58, DeviceKind.pc),
      e('ayo-3', 0, 7, 12, DeviceKind.phone),
      e('amanecer-2', 0, 7, 9, DeviceKind.phone),
      e('deja-1', 0, 7, 5, DeviceKind.phone),
      e('vives-1', 1, 18, 20, DeviceKind.phone),
      e('pipa-11', 1, 18, 16, DeviceKind.phone),
      e('slowrush-8', 2, 22, 40, DeviceKind.pc),
    ];
  }

  static const initialRecentSearches = [
    'bomba estéreo',
    'random access memories',
    'aterciopelados',
    'monsieur periné',
  ];
}

String normalize(String s) {
  const from = 'áàäâãéèëêíìïîóòöôõúùüûñç';
  const to = 'aaaaaeeeeiiiiooooouuuunc';
  final lower = s.toLowerCase();
  final b = StringBuffer();
  for (final ch in lower.split('')) {
    final i = from.indexOf(ch);
    b.write(i >= 0 ? to[i] : ch);
  }
  return b.toString();
}

String slug(String s) => normalize(
  s,
).replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'(^-|-$)'), '');
