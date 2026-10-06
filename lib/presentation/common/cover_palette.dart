import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/track.dart';
import '../../shared/design_system/design_system.dart';

/// Three dominant colors of a cover, extracted from a 32×32 downsample.
/// The player aura and page tints use them when the catalog provides none.
final coverPaletteProvider = FutureProvider.family<List<Color>, String>((
  ref,
  url,
) async {
  if (url.isEmpty) return const [];
  final image = await _decode(
    ResizeImage(coverImage(url), width: 32, height: 32),
  );
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  image.dispose();
  if (data == null) return const [];
  return dominantColors(data.buffer.asUint8List());
});

/// Track colors: the catalog's palette, or the cover's.
final trackPaletteProvider = Provider.family<List<Color>, Track>((ref, t) {
  if (t.palette.isNotEmpty) return [for (final c in t.palette) Color(c)];
  return ref.watch(coverPaletteProvider(t.coverUrl)).value ?? const [];
});

Future<ui.Image> _decode(ImageProvider provider) {
  final done = Completer<ui.Image>();
  final stream = provider.resolve(ImageConfiguration.empty);
  late final ImageStreamListener listener;
  listener = ImageStreamListener(
    (info, _) {
      done.complete(info.image.clone());
      info.dispose();
      stream.removeListener(listener);
    },
    onError: (e, s) {
      done.completeError(e, s);
      stream.removeListener(listener);
    },
  );
  stream.addListener(listener);
  return done.future;
}

/// Buckets pixels in a coarse RGB grid and returns the three most common
/// buckets, preferring saturated ones (the black bars of letterboxed
/// YouTube thumbnails are skipped).
List<Color> dominantColors(List<int> rgba) {
  final counts = <int, (int, int, int, int)>{};
  for (var i = 0; i + 3 < rgba.length; i += 4) {
    final r = rgba[i], g = rgba[i + 1], b = rgba[i + 2];
    final maxC = math.max(r, math.max(g, b)),
        minC = math.min(r, math.min(g, b));
    if (maxC < 24) continue; // letterbox / near-black
    final key = (r >> 5) << 6 | (g >> 5) << 3 | (b >> 5);
    final (n, sr, sg, sb) = counts[key] ?? (0, 0, 0, 0);
    final weight = 1 + (maxC - minC) ~/ 48; // favor saturated colors
    counts[key] = (
      n + weight,
      sr + r * weight,
      sg + g * weight,
      sb + b * weight,
    );
  }
  final top = counts.values.toList()..sort((a, b) => b.$1.compareTo(a.$1));
  return [
    for (final (n, r, g, b) in top.take(3))
      Color.fromARGB(255, r ~/ n, g ~/ n, b ~/ n),
  ];
}
