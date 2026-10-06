import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// A JSON document on disk. Writes are debounced and atomic (temp file +
/// rename) so a crash never leaves a half-written library.
class JsonFileStore {
  JsonFileStore(this.file);

  final File file;
  Timer? _debounce;
  Object? _pending;

  Future<Map<String, Object?>?> read() async {
    try {
      if (!await file.exists()) return null;
      return jsonDecode(await file.readAsString()) as Map<String, Object?>;
    } catch (_) {
      // Corrupt file: keep a copy for inspection and start fresh.
      if (await file.exists()) await file.copy('${file.path}.corrupt');
      return null;
    }
  }

  void write(Object json) {
    _pending = json;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), flush);
  }

  Future<void> flush() async {
    final json = _pending;
    if (json == null) return;
    _pending = null;
    await file.parent.create(recursive: true);
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(jsonEncode(json), flush: true);
    await tmp.rename(file.path);
  }
}
