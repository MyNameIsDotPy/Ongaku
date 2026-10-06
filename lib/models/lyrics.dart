import 'package:freezed_annotation/freezed_annotation.dart';

part 'lyrics.freezed.dart';

@freezed
abstract class LyricLine with _$LyricLine {
  const factory LyricLine({
    required Duration start,
    required Duration end,
    @Default('') String text,

    /// A gap between sung lines; rendered as three dots that pulse.
    @Default(false) bool instrumental,
  }) = _LyricLine;
}

/// `GET /v1/lyrics/{id}` as proposed in the design notes: `synced` lines with
/// timestamps, falling back to static text.
@freezed
abstract class Lyrics with _$Lyrics {
  const factory Lyrics({required bool synced, required List<LyricLine> lines}) =
      _Lyrics;
}
