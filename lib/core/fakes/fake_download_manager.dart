import 'dart:async';

import '../../models/download_entry.dart';
import '../../models/track.dart';
import '../download_manager.dart';

class FakeDownloadManager implements DownloadManager {
  FakeDownloadManager() {
    // Two playlists are already available offline in the sample library.
    _state = {
      'pl-transmi': const DownloadEntry(
        collectionId: 'pl-transmi',
        kind: DownloadKind.playlist,
        title: 'Para TransMilenio',
        trackIds: [
          'ayo-3', 'amanecer-2', 'deja-1', 'ocean-2', 'juanes-4', 'vives-1', //
          'pipa-2', 'amanecer-5', 'mperine-1', 'shakira-1', 'deja-7',
        ],
        completedTracks: 11,
        sizeMb: 74.2,
        status: DownloadStatus.done,
      ),
      'pl-90s': const DownloadEntry(
        collectionId: 'pl-90s',
        kind: DownloadKind.playlist,
        title: 'Colombia 90',
        trackIds: [
          'vives-1', 'vives-2', 'vives-3', 'shakira-1', 'shakira-4', //
          'pipa-1', 'pipa-11', 'pipa-7', 'shakira-9',
        ],
        completedTracks: 9,
        sizeMb: 61.8,
        status: DownloadStatus.done,
      ),
    };
  }

  late Map<String, DownloadEntry> _state;
  final _controller = StreamController<Map<String, DownloadEntry>>.broadcast();

  @override
  Map<String, DownloadEntry> get current => _state;

  @override
  Stream<Map<String, DownloadEntry>> watch() => _controller.stream;

  void _put(DownloadEntry e) {
    _state = {..._state, e.collectionId: e};
    _controller.add(_state);
  }

  @override
  Future<void> download({
    required String collectionId,
    required DownloadKind kind,
    required String title,
    required List<Track> tracks,
  }) async {
    if (_state[collectionId]?.isDone ?? false) return;
    var entry = DownloadEntry(
      collectionId: collectionId,
      kind: kind,
      title: title,
      trackIds: tracks.map((t) => t.videoId).toList(),
    );
    _put(entry);
    for (var i = 0; i < tracks.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 260));
      if (!_state.containsKey(collectionId)) return; // cancelled
      entry = entry.copyWith(
        completedTracks: i + 1,
        sizeMb: double.parse(((i + 1) * 3.4).toStringAsFixed(1)),
      );
      _put(entry);
    }
    _put(entry.copyWith(status: DownloadStatus.done));
  }

  @override
  Future<void> remove(String collectionId) async {
    _state = {..._state}..remove(collectionId);
    _controller.add(_state);
  }

  @override
  Future<void> clear() async {
    _state = {};
    _controller.add(_state);
  }

  @override
  bool isTrackDownloaded(String videoId) => _state.values.any((e) {
    final i = e.trackIds.indexOf(videoId);
    return i >= 0 && i < e.completedTracks;
  });
}
