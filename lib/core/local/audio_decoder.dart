import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import '../beats/beat_analyzer.dart';
import 'youtube_gateway.dart';
import 'youtube_mapping.dart';

/// Decodes an audio file to mono float PCM at [BeatAnalyzer.sampleRate]:
/// MediaCodec on Android, a local ffmpeg on desktop. Null when the
/// platform has no decoder (e.g. desktop without ffmpeg).
class AudioDecoder {
  static const _channel = MethodChannel('ongaku/audio_decoder');

  Future<Float32List?> decodeMono(String path) async {
    if (Platform.isAndroid) {
      final bytes = await _channel.invokeMethod<Uint8List>('decode', {
        'path': path,
        'sampleRate': BeatAnalyzer.sampleRate,
      });
      return bytes == null ? null : _fromPcm16(bytes);
    }
    final ffmpeg = await findExecutable('ffmpeg');
    if (ffmpeg == null) return null;
    // Capped at the longest song: a multi-hour file would exhaust memory.
    final result = await Process.run(ffmpeg, [
      '-v',
      'error',
      '-i',
      path,
      '-t',
      '${YoutubeMapping.maxSongLength.inSeconds}', //
      '-ac', '1', '-ar', '${BeatAnalyzer.sampleRate}', '-f', 'f32le', '-',
    ], stdoutEncoding: null);
    if (result.exitCode != 0) return null;
    final bytes = Uint8List.fromList(result.stdout as List<int>);
    return Float32List.view(bytes.buffer, 0, bytes.length ~/ 4);
  }

  /// 16-bit little-endian samples → floats in [-1, 1].
  static Float32List _fromPcm16(Uint8List bytes) {
    final data = ByteData.sublistView(bytes);
    final out = Float32List(bytes.length ~/ 2);
    for (var i = 0; i < out.length; i++) {
      out[i] = data.getInt16(i * 2, Endian.little) / 32768;
    }
    return out;
  }
}
