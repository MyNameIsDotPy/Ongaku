import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ongaku/core/download_manager.dart';
import 'package:ongaku/core/local/json_file_store.dart';
import 'package:ongaku/core/local/local_download_manager.dart';
import 'package:ongaku/core/local/youtube_gateway.dart';
import 'package:ongaku/core/player/play_counter.dart';
import 'package:ongaku/models/app_settings.dart';
import 'package:ongaku/models/download_entry.dart';
import 'package:ongaku/models/track.dart';
import 'package:ongaku/providers/repository_providers.dart';
import 'package:ongaku/providers/search_providers.dart';
import 'package:ongaku/providers/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

Track song(String id, [Duration length = const Duration(minutes: 3)]) => Track(
  videoId: id,
  title: id,
  artists: const [],
  duration: length,
  coverUrl: '',
);

Future<ProviderContainer> container(MusicSource source) async {
  final prefs = await SharedPreferences.getInstance();
  final c = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      musicSourceProvider.overrideWithValue(source),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('settings', () {
    test('every setting survives a restart', () {
      const changed = AppSettings(
        backendUrl: 'http://x',
        token: 't',
        wifiQuality: AudioQuality.low,
        mobileQuality: AudioQuality.high,
        downloadOnWifiOnly: false,
        downloadLimitGb: 3,
        theme: ThemePreference.dark,
        motion: MotionLevel.reduced,
        reactiveVisuals: false,
        onboardingComplete: true,
        source: MusicSource.sample,
        ytDlpPath: '/opt/yt-dlp',
      );
      expect(AppSettings.fromPrefs(changed.toPrefs()), changed);
    });
  });

  group('recent searches', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('start empty with YouTube and persist across restarts', () async {
      final first = await container(MusicSource.youtube);
      expect(first.read(recentSearchesProvider), isEmpty);
      first.read(recentSearchesProvider.notifier)
        ..add('Bomba Estéreo ')
        ..add('juanes')
        ..add('bomba estéreo');
      final again = await container(MusicSource.youtube);
      expect(again.read(recentSearchesProvider), ['bomba estéreo', 'juanes']);
      again.read(recentSearchesProvider.notifier).clear();
      expect(
        (await container(MusicSource.youtube)).read(recentSearchesProvider),
        isEmpty,
      );
    });

    test('the sample catalog shows examples until a real search', () async {
      final c = await container(MusicSource.sample);
      expect(c.read(recentSearchesProvider), isNotEmpty);
      c.read(recentSearchesProvider.notifier).clear();
      expect(
        (await container(MusicSource.sample)).read(recentSearchesProvider),
        isEmpty,
      );
    });
  });

  group('play counter', () {
    late DateTime now;
    late PlayCounter counter;
    void wait(int s) => now = now.add(Duration(seconds: s));
    setUp(() {
      now = DateTime(2026);
      counter = PlayCounter(now: () => now);
    });

    test('a skipped song is not recorded', () {
      counter.update(song('a'), playing: true);
      wait(20);
      expect(counter.update(song('b'), playing: true), isNull);
      wait(20);
      expect(counter.update(song('b'), playing: true), isNull);
    });

    test('counts listening time across pauses, once', () {
      counter.update(song('a'), playing: true);
      wait(20);
      counter.update(song('a'), playing: false);
      wait(600); // paused: doesn't count
      counter.update(song('a'), playing: true);
      wait(9);
      expect(counter.update(song('a'), playing: true), isNull);
      wait(1);
      expect(counter.update(song('a'), playing: true)?.videoId, 'a');
      wait(60);
      expect(counter.update(song('a'), playing: true), isNull);
    });

    test('a short song counts after 80 %', () {
      final short = song('s', const Duration(seconds: 20));
      counter.update(short, playing: true);
      wait(16);
      expect(counter.update(short, playing: true)?.videoId, 's');
    });
  });

  group('downloads', () {
    late Directory root;
    late Directory dir;
    late File json;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('ongaku-dl-');
      dir = Directory('${root.path}/downloads')..createSync();
      json = File('${root.path}/downloads.json');
    });
    tearDown(() => root.delete(recursive: true));

    File file(String name, int bytes) =>
        File('${dir.path}/$name')..writeAsBytesSync(List.filled(bytes, 0));

    Map<String, Object?> entry(
      String id,
      List<String> tracks,
      Map<String, String> files,
    ) => {
      'collectionId': id,
      'kind': 'album',
      'title': id,
      'trackIds': tracks,
      'completedTracks': tracks.length,
      'sizeMb': 1.0,
      'status': 'done',
      'files': files,
    };

    Future<LocalDownloadManager> open() =>
        LocalDownloadManager.open(YoutubeGateway(), JsonFileStore(json), dir);

    test(
      'restart cleans leftovers and reopens albums with missing songs',
      () async {
        final a = file('a.mp4', 1048576);
        final b = file('b.mp4', 1048576);
        file('c.mp4.part', 10);
        file('orphan.mp4', 10);
        json.writeAsStringSync(
          jsonEncode({
            'entries': [
              entry('album1', ['a', 'b'], {'a': a.path, 'b': b.path}),
              entry(
                'album2',
                ['b', 'x'],
                {'b': b.path, 'x': '${dir.path}/x.mp4'},
              ),
            ],
          }),
        );
        final m = await open();
        expect(dir.listSync().map((f) => f.uri.pathSegments.last).toSet(), {
          'a.mp4',
          'b.mp4',
        });
        expect(m.current['album1']!.status, DownloadStatus.done);
        expect(m.current['album2']!.status, DownloadStatus.failed);
        expect(m.current['album2']!.completedTracks, 1);
        expect(m.isTrackDownloaded('x'), isFalse);
        // b belongs to both albums but takes space once.
        expect(m.usedMb, closeTo(2, 1e-9));
      },
    );

    test('stops at the download limit before fetching anything', () async {
      final a = file('a.mp4', 2048);
      json.writeAsStringSync(
        jsonEncode({
          'entries': [
            entry('album1', ['a'], {'a': a.path}),
          ],
        }),
      );
      final m = await open();
      await expectLater(
        m.download(
          collectionId: 'album2',
          kind: DownloadKind.album,
          title: 'Two',
          tracks: [song('a'), song('new')],
          limitBytes: 1024,
        ),
        throwsA(isA<DownloadLimitReached>()),
      );
      expect(m.current['album2']!.status, DownloadStatus.failed);
      expect(m.current['album2']!.completedTracks, 1); // a was already here
    });

    test('removing a download in progress does not bring it back', () async {
      final a = file('a.mp4', 10);
      final b = file('b.mp4', 10);
      json.writeAsStringSync(
        jsonEncode({
          'entries': [
            entry('other', ['a', 'b'], {'a': a.path, 'b': b.path}),
          ],
        }),
      );
      final m = await open();
      final running = m.download(
        collectionId: 'album',
        kind: DownloadKind.album,
        title: 'Album',
        tracks: [song('a'), song('b')],
      );
      await m.remove('album');
      await running;
      expect(m.current.containsKey('album'), isFalse);
    });
  });
}
