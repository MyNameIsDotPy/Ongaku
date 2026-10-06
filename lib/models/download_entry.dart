import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_entry.freezed.dart';

enum DownloadKind { album, playlist }

enum DownloadStatus { downloading, done, failed }

/// A downloaded (or downloading) album or playlist (RF-25).
@freezed
abstract class DownloadEntry with _$DownloadEntry {
  const DownloadEntry._();

  const factory DownloadEntry({
    required String collectionId,
    required DownloadKind kind,
    required String title,
    required List<String> trackIds,
    @Default(0) int completedTracks,
    @Default(0.0) double sizeMb,
    @Default(DownloadStatus.downloading) DownloadStatus status,
  }) = _DownloadEntry;

  double get progress =>
      trackIds.isEmpty ? 1 : completedTracks / trackIds.length;

  bool get isDone => status == DownloadStatus.done;
}
