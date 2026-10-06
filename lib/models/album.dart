import 'package:freezed_annotation/freezed_annotation.dart';

import 'track.dart';

part 'album.freezed.dart';

@freezed
abstract class Album with _$Album {
  const Album._();

  const factory Album({
    required String id,
    required String title,
    required ArtistRef artist,
    required int year,
    required String genre,
    required String coverUrl,
    @Default(<int>[]) List<int> palette,
    @Default(<Track>[]) List<Track> tracks,
  }) = _Album;

  Duration get totalDuration =>
      tracks.fold(Duration.zero, (sum, t) => sum + t.duration);
}
