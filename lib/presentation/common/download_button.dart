import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/download_entry.dart';
import '../../models/track.dart';
import '../../providers/download_providers.dart';
import '../../shared/design_system/design_system.dart';
import 'track_actions.dart';

/// Download → progress ring (per song) → check (RF-25, flow 4).
class DownloadButton extends ConsumerWidget {
  const DownloadButton({
    super.key,
    required this.id,
    required this.kind,
    required this.title,
    required this.tracks,
  });

  final String id;
  final DownloadKind kind;
  final String title;
  final List<Track> tracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(downloadsProvider.select((d) => d[id]));
    if (entry != null && !entry.isDone) {
      return SizedBox.square(
        dimension: 44,
        child: Center(child: OngakuProgressRing(progress: entry.progress)),
      );
    }
    final done = entry?.isDone ?? false;
    return OngakuIconButton(
      icon: done ? OngakuIcons.check : OngakuIcons.download,
      tooltip: done ? 'Descargado' : 'Descargar',
      onPressed: () => ref.downloadCollection(
        context,
        id: id,
        kind: kind,
        title: title,
        tracks: tracks,
      ),
    );
  }
}
