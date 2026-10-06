import '../models/download_entry.dart';
import '../models/track.dart';

abstract interface class DownloadManager {
  Map<String, DownloadEntry> get current;
  Stream<Map<String, DownloadEntry>> watch();

  /// Downloads every track, reporting progress per song.
  Future<void> download({
    required String collectionId,
    required DownloadKind kind,
    required String title,
    required List<Track> tracks,
  });
  Future<void> remove(String collectionId);
  Future<void> clear();
  bool isTrackDownloaded(String videoId);
}
