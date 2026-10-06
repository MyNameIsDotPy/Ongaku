import 'dart:async';
import 'dart:io';

import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

import '../../models/api_error.dart';
import '../../models/download_entry.dart';
import '../../models/json_codec.dart';
import '../../models/track.dart';
import '../download_manager.dart';
import 'json_file_store.dart';
import 'youtube_gateway.dart';

/// Saves audio files to the app's storage so playlists play offline (RF-25,
/// CU-05). Each song is downloaded once even if it is in several lists.
class LocalDownloadManager implements DownloadManager {
  LocalDownloadManager._(
    this._gateway,
    this._store,
    this._dir,
    this._state,
    this._files,
  );

  static Future<LocalDownloadManager> open(
    YoutubeGateway gateway,
    JsonFileStore store,
    Directory dir,
  ) async {
    final json = await store.read();
    final entries = <String, DownloadEntry>{};
    final files = <String, String>{};
    for (final m
        in (json?['entries'] as List? ?? const [])
            .cast<Map<String, Object?>>()) {
      final e = JsonCodecs.downloadFrom(m);
      entries[e.collectionId] = e;
      (m['files'] as Map? ?? const {}).forEach((k, v) => files['$k'] = '$v');
    }
    // Forget files that were deleted outside the app.
    files.removeWhere((_, path) => !File(path).existsSync());
    return LocalDownloadManager._(gateway, store, dir, entries, files);
  }

  final YoutubeGateway _gateway;
  final JsonFileStore _store;
  final Directory _dir;
  Map<String, DownloadEntry> _state;

  /// videoId → file path.
  final Map<String, String> _files;
  final _controller = StreamController<Map<String, DownloadEntry>>.broadcast();

  @override
  Map<String, DownloadEntry> get current => _state;

  @override
  Stream<Map<String, DownloadEntry>> watch() => _controller.stream;

  /// Path of a downloaded song, for the stream resolver.
  String? fileFor(String videoId) => _files[videoId];

  void _put(DownloadEntry e) {
    _state = {..._state, e.collectionId: e};
    _publish();
  }

  void _publish() {
    _controller.add(_state);
    _store.write({
      'entries': [
        for (final e in _state.values) JsonCodecs.download(e, _files),
      ],
    });
  }

  @override
  bool isTrackDownloaded(String videoId) => _files.containsKey(videoId);

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
      trackIds: [for (final t in tracks) t.videoId],
    );
    _put(entry);
    var bytes = 0;
    var failed = 0;
    for (var i = 0; i < tracks.length; i++) {
      if (!_state.containsKey(collectionId)) return; // cancelled
      try {
        bytes += await _downloadTrack(tracks[i]);
      } on ApiException catch (e) {
        if (e.code == ApiErrorCode.backendOffline) {
          _put(entry.copyWith(status: DownloadStatus.failed));
          rethrow;
        }
        failed++;
      }
      entry = entry.copyWith(
        completedTracks: i + 1,
        sizeMb: double.parse((bytes / 1048576).toStringAsFixed(1)),
      );
      _put(entry);
    }
    _put(
      entry.copyWith(
        status: failed == tracks.length
            ? DownloadStatus.failed
            : DownloadStatus.done,
      ),
    );
  }

  /// Returns the file size in bytes.
  Future<int> _downloadTrack(Track t) async {
    final existing = _files[t.videoId];
    if (existing != null) return File(existing).length();
    return _gateway((client) async {
      final manifest = await audioManifest(client, t.videoId);
      final audio = manifest.audioOnly;
      if (audio.isEmpty) throw const ApiException(ApiErrorCode.unavailable);
      // Prefer m4a: every platform's decoder handles it.
      final mp4 = audio.where((s) => s.container == yt.StreamContainer.mp4);
      final info = (mp4.isNotEmpty ? mp4 : audio).sortByBitrate().first;
      await _dir.create(recursive: true);
      final file = File('${_dir.path}/${t.videoId}.${info.container.name}');
      final tmp = File('${file.path}.part');
      final sink = tmp.openWrite();
      try {
        await sink.addStream(client.videos.streams.get(info));
      } finally {
        await sink.close();
      }
      await tmp.rename(file.path);
      _files[t.videoId] = file.path;
      return file.length();
    });
  }

  @override
  Future<void> remove(String collectionId) async {
    final removed = _state[collectionId];
    _state = {..._state}..remove(collectionId);
    if (removed != null) {
      final stillUsed = {for (final e in _state.values) ...e.trackIds};
      for (final id in removed.trackIds.where(
        (id) => !stillUsed.contains(id),
      )) {
        final path = _files.remove(id);
        if (path != null) {
          await File(path).delete().catchError((_) => File(path));
        }
      }
    }
    _publish();
  }

  @override
  Future<void> clear() async {
    _state = {};
    _files.clear();
    if (await _dir.exists()) await _dir.delete(recursive: true);
    _publish();
  }
}
