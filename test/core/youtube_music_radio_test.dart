import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ongaku/core/local/youtube_music_client.dart';
import 'package:ongaku/core/local/youtube_mapping.dart';

/// One item of YouTube Music's `next` panel, in the shape the API returns.
Map<String, Object?> _panelItem(
  String videoId,
  String title,
  String artist,
  String artistId,
  String length,
) => {
  'playlistPanelVideoRenderer': {
    'title': {
      'runs': [
        {'text': title},
      ],
    },
    'longBylineText': {
      'runs': [
        {
          'text': artist,
          'navigationEndpoint': {
            'browseEndpoint': {'browseId': artistId},
          },
        },
      ],
    },
    'shortBylineText': {
      'runs': [
        {'text': artist},
      ],
    },
    'lengthText': {
      'runs': [
        {'text': length},
      ],
    },
    'navigationEndpoint': {
      'watchEndpoint': {'videoId': videoId},
    },
  },
};

void main() {
  test('song radio reads songs with their lengths and artists', () async {
    final client = YoutubeMusicClient(
      client: MockClient((request) async {
        expect(jsonDecode(request.body)['playlistId'], 'RDAMVMabc');
        return http.Response(
          jsonEncode({
            'contents': {
              'watch': {
                'playlistPanelRenderer': {
                  'contents': [
                    _panelItem(
                      'abc',
                      'Shape of You',
                      'Ed Sheeran',
                      'UC1',
                      '4:24',
                    ),
                    _panelItem(
                      'def',
                      'Believer',
                      'Imagine Dragons',
                      'UC2',
                      '3:37',
                    ),
                  ],
                },
              },
            },
          }),
          200,
        );
      }),
    );

    final songs = await client.radio('abc');

    expect(
      [
        for (final t in songs)
          (t.videoId, t.title, t.primaryArtist.name, t.duration),
      ],
      [
        (
          'abc',
          'Shape of You',
          'Ed Sheeran',
          const Duration(minutes: 4, seconds: 24),
        ),
        (
          'def',
          'Believer',
          'Imagine Dragons',
          const Duration(minutes: 3, seconds: 37),
        ),
      ],
    );
  });

  test('only known lengths up to the song limit count as songs', () {
    expect(YoutubeMapping.isSongLength(Duration.zero), isFalse);
    expect(YoutubeMapping.isSongLength(const Duration(minutes: 3)), isTrue);
    expect(YoutubeMapping.isSongLength(YoutubeMapping.maxSongLength), isTrue);
    expect(YoutubeMapping.isSongLength(const Duration(hours: 3)), isFalse);
  });
}
