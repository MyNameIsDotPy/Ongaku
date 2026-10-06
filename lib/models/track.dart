import 'package:freezed_annotation/freezed_annotation.dart';

part 'track.freezed.dart';

@freezed
abstract class ArtistRef with _$ArtistRef {
  const factory ArtistRef({required String id, required String name}) =
      _ArtistRef;
}

@freezed
abstract class AlbumRef with _$AlbumRef {
  const factory AlbumRef({required String id, required String name}) =
      _AlbumRef;
}

/// A song as the whole UI sees it — mirrors the `GET /v1/tracks/{videoId}`
/// response shape from the requirements doc.
@freezed
abstract class Track with _$Track {
  const Track._();

  const factory Track({
    required String videoId,
    required String title,
    required List<ArtistRef> artists,
    AlbumRef? album,
    required Duration duration,

    /// Asset path (`assets/...`) or network URL.
    required String coverUrl,
    @Default(false) bool explicit,

    /// The backend could not extract this one (`UNAVAILABLE`).
    @Default(false) bool unavailable,

    /// Dominant cover colors (ARGB), used for tints and the player aura.
    @Default(<int>[]) List<int> palette,
  }) = _Track;

  String get artistNames => artists.map((a) => a.name).join(', ');
  ArtistRef get primaryArtist => artists.first;
}
