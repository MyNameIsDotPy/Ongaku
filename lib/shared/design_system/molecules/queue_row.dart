import 'package:flutter/material.dart';

import '../../../models/track.dart';
import '../atoms/atoms.dart';
import '../tokens/tokens.dart';

/// Row in the queue (`.qrow`): grip, cover, title/artist, remove — or an
/// equalizer for the current one.
class QueueRow extends StatelessWidget {
  const QueueRow({
    super.key,
    required this.track,
    required this.onTap,
    this.current = false,
    this.playing = false,
    this.onRemove,
    this.dragHandle,
    this.onDark = false,
  });

  final Track track;
  final VoidCallback onTap;
  final bool current;
  final bool playing;
  final VoidCallback? onRemove;
  final Widget? dragHandle;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return OngakuPressable(
      onTap: onTap,
      semanticLabel: '${track.title}, ${track.artistNames}',
      color: current ? (onDark ? c.fgSoft2 : c.fgSoft) : null,
      hoverColor: c.fgSoft,
      borderRadius: OngakuRadii.mdAll,
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          SizedBox(width: 20, height: 40, child: current ? null : dragHandle),
          const SizedBox(width: 10),
          OngakuCover.single(track.coverUrl, size: 40, radius: OngakuRadii.xs),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  track.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: current ? FontWeight.w700 : FontWeight.w600,
                    color: c.fg,
                  ),
                ),
                Text(
                  track.artistNames,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: c.muted),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 36,
            child: current
                ? Center(
                    child: OngakuEq(active: playing, color: c.fg),
                  )
                : onRemove == null
                ? null
                : OngakuIconButton(
                    icon: OngakuIcons.close,
                    size: OngakuIconButtonSize.small,
                    tooltip: 'Quitar de la cola',
                    onPressed: onRemove,
                  ),
          ),
        ],
      ),
    );
  }
}

/// ⠿ grip used as a drag handle.
class DragGrip extends StatelessWidget {
  const DragGrip({super.key});

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.grab,
    child: Semantics(
      label: 'Arrastrar para reordenar',
      child: Center(
        child: OngakuIcon(
          OngakuIcons.grip,
          size: 18,
          color: context.colors.muted,
        ),
      ),
    ),
  );
}
