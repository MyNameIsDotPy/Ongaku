import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../../models/beat_map.dart';
import '../beats/beat_analyzer.dart';
import 'audio_decoder.dart';
import 'youtube_gateway.dart';

/// Beat maps for real songs, analysed on this device and cached on disk.
/// Uses the downloaded file when there is one; otherwise fetches the
/// smallest audio stream (~1–2 MB). One analysis runs at a time, and only
/// the most recent waiting request is kept, so skipping through a queue
/// does not download every song on the way.
class BeatAnalysis {
  BeatAnalysis(
    this._gateway,
    this._dir, {
    required this.localFile,
    AudioDecoder? decoder,
  }) : _decoder = decoder ?? AudioDecoder();

  final YoutubeGateway _gateway;
  final Directory _dir;
  final AudioDecoder _decoder;
  final String? Function(String videoId) localFile;

  final _memory = <String, BeatMap>{};
  final _requests = <String, Future<BeatMap?>>{};
  Future<void> _running = Future.value();
  String? _latest;

  /// Null when the song cannot be analysed (no decoder, offline, …).
  Future<BeatMap?> beatMap(String videoId) {
    final known = _memory[videoId];
    if (known != null) return Future.value(known);
    _latest = videoId;
    return _requests[videoId] ??= _queue(videoId).whenComplete(() {
      _requests.remove(videoId);
    });
  }

  Future<BeatMap?> _queue(String videoId) async {
    final cached = await _readCache(videoId);
    if (cached != null) return _memory[videoId] = cached;
    final previous = _running;
    final done = Completer<void>();
    _running = done.future;
    try {
      await previous;
      // A newer song was requested while this one waited.
      if (_latest != videoId) return null;
      final map = await _analyse(videoId);
      if (map != null) {
        _memory[videoId] = map;
        await _writeCache(videoId, map);
      }
      return map;
    } catch (_) {
      return null;
    } finally {
      done.complete();
    }
  }

  Future<BeatMap?> _analyse(String videoId) async {
    final local = localFile(videoId);
    if (local != null && await File(local).exists()) return _fromFile(local);

    await _dir.create(recursive: true);
    final tmp = File('${_dir.path}/$videoId.part');
    try {
      await _gateway((client) async {
        final manifest = await audioManifest(client, videoId);
        final smallest = manifest.audioOnly.sortByBitrate().last;
        final sink = tmp.openWrite();
        try {
          await sink.addStream(client.videos.streams.get(smallest));
        } finally {
          await sink.close();
        }
      });
      return await _fromFile(tmp.path);
    } finally {
      if (await tmp.exists()) await tmp.delete();
    }
  }

  Future<BeatMap?> _fromFile(String path) async {
    final pcm = await _decoder.decodeMono(path);
    if (pcm == null) return null;
    final map = await Isolate.run(() => BeatAnalyzer.analyze(pcm));
    return map.isEmpty ? null : map;
  }

  File _cacheFile(String videoId) => File('${_dir.path}/$videoId.json');

  Future<BeatMap?> _readCache(String videoId) async {
    try {
      final file = _cacheFile(videoId);
      if (!await file.exists()) return null;
      return BeatMap.fromJson(
        jsonDecode(await file.readAsString()) as Map<String, Object?>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(String videoId, BeatMap map) async {
    try {
      await _dir.create(recursive: true);
      await _cacheFile(videoId).writeAsString(jsonEncode(map.toJson()));
    } catch (_) {}
  }
}
