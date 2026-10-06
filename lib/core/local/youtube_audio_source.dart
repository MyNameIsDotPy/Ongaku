import 'dart:async';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// ExoPlayer reads and seeks through just_audio's local proxy. Upstream requests
/// use bounded chunks: YouTube can reject open-ended or whole-file requests.
class YoutubeAudioSource extends StreamAudioSource {
  YoutubeAudioSource(this.uri, {required this.length, http.Client? client, super.tag})
      : _client = client ?? http.Client();

  static const chunkSize = 256 * 1024;
  final Uri uri;
  final int length;
  final http.Client _client;
  bool _closed = false;

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final from = start ?? 0;
    final to = end ?? length;
    if (from < 0 || from >= length || to <= from || to > length) {
      throw RangeError('Invalid audio byte range: $from-$to/$length');
    }
    final first = await _open(from, min(to, from + chunkSize));
    return StreamAudioResponse(
      sourceLength: length,
      contentLength: to - from,
      offset: from,
      contentType: uri.queryParameters['mime'] ?? 'audio/mp4',
      stream: _read(first, from, to),
    );
  }

  Future<http.StreamedResponse> _open(int from, int to) async {
    if (_closed) throw StateError('Audio source is closed');
    final request = http.Request('GET', uri)
      ..headers.addAll(YoutubeHttpClient.defaultHeaders)
      ..headers['Range'] = 'bytes=$from-${to - 1}';
    final response = await _client.send(request).timeout(const Duration(seconds: 15));
    if (response.statusCode != 206 &&
        !(response.statusCode == 200 && from == 0 && to == length)) {
      await response.stream.listen(null).cancel();
      throw http.ClientException('Audio request returned HTTP ${response.statusCode}');
    }
    if (response.contentLength != null && response.contentLength != to - from) {
      await response.stream.listen(null).cancel();
      throw http.ClientException('Audio server returned an unexpected byte range');
    }
    return response;
  }

  Stream<List<int>> _read(http.StreamedResponse first, int from, int to) async* {
    var response = first;
    while (from < to && !_closed) {
      final until = min(to, from + chunkSize);
      var received = 0;
      await for (final bytes in response.stream.timeout(const Duration(seconds: 15))) {
        received += bytes.length;
        yield bytes;
      }
      if (received != until - from) throw http.ClientException('Incomplete audio range');
      from = until;
      if (from < to && !_closed) response = await _open(from, min(to, from + chunkSize));
    }
  }

  void close() {
    _closed = true;
    _client.close();
  }
}
