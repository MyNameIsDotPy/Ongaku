import 'package:freezed_annotation/freezed_annotation.dart';

import 'album.dart';
import 'track.dart';

part 'artist.freezed.dart';

@freezed
abstract class Artist with _$Artist {
  const factory Artist({
    required String id,
    required String name,
    String? photoUrl,
    String? photoCredit,
    @Default(<Track>[]) List<Track> popular,
    @Default(<Album>[]) List<Album> albums,
    @Default(<Album>[]) List<Album> singles,
  }) = _Artist;
}
