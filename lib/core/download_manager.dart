import '../models/download_entry.dart';
import '../models/track.dart';

abstract interface class DownloadManager {
  Map<String, DownloadEntry> get current;
  Stream<Map<String, DownloadEntry>> watch();

  /// Downloads every track, reporting progress per song. Stops with
  /// [DownloadLimitReached] once the files on disk reach [limitBytes].
  Future<void> download({
    required String collectionId,
    required DownloadKind kind,
    required String title,
    required List<Track> tracks,
    int? limitBytes,
  });
  Future<void> remove(String collectionId);
  Future<void> clear();
  bool isTrackDownloaded(String videoId);

  /// Space taken by downloaded songs; each file counts once even when it
  /// belongs to several albums or playlists (RF-26).
  double get usedMb;
}

/// The download limit from Ajustes was reached (RF-26).
class DownloadLimitReached implements Exception {
  const DownloadLimitReached();
}
