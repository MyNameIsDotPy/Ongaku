import 'package:freezed_annotation/freezed_annotation.dart';

import 'track.dart';

part 'playlist.freezed.dart';

enum PlaylistSource { own, youtube }

@freezed
abstract class Playlist with _$Playlist {
  const Playlist._();

  const factory Playlist({
    required String id,
    required String name,
    required PlaylistSource source,
    String? sourceId,
    String? owner,
    required DateTime createdAt,
    @Default(<Track>[]) List<Track> tracks,

    /// False for a YouTube playlist being previewed before import.
    @Default(true) bool inLibrary,
  }) = _Playlist;

  bool get isOwn => source == PlaylistSource.own;

  Duration get totalDuration =>
      tracks.fold(Duration.zero, (sum, t) => sum + t.duration);

  /// Up to four distinct covers, for the mosaic artwork.
  List<String> get covers =>
      tracks.map((t) => t.coverUrl).toSet().take(4).toList();
}
