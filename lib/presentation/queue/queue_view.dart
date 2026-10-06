import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/track.dart';
import '../../providers/player_providers.dart';
import '../../shared/design_system/design_system.dart';
import '../common/track_actions.dart';

/// The queue (RF-08): playing now, "a continuación" and the rest. Reorder by
/// dragging the grip, remove, clear, or save as a playlist. Right column on
/// PC, a tab of the player on phones.
class QueueView extends ConsumerWidget {
  const QueueView({
    super.key,
    this.onDark = false,
    this.padding = EdgeInsets.zero,
  });

  final bool onDark;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(playerProvider);
    final player = ref.read(playerProvider.notifier);
    final current = s.current;
    final c = context.colors;
    if (current == null) {
      return Padding(
        padding: padding,
        child: const EmptyState(
          icon: OngakuIcons.queue,
          title: 'La cola está vacía',
          message: 'Reproduce una canción o una playlist.',
        ),
      );
    }
    final nextBase = s.index + 1;
    final laterBase = s.index + 1 + s.upNext;
    Widget label(String text, {Widget? trailing}) => Padding(
      padding: const EdgeInsets.fromLTRB(8, 18, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text.toUpperCase(),
              style: OngakuTypography.eyebrow(context),
            ),
          ),
          ?trailing,
        ],
      ),
    );

    Widget section(List<Track> tracks, int base) => ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: tracks.length,
      proxyDecorator: (child, _, _) => Material(
        color: Colors.transparent,
        elevation: 12,
        shadowColor: Colors.black54,
        borderRadius: OngakuRadii.mdAll,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: OngakuRadii.mdAll,
          ),
          child: child,
        ),
      ),
      onReorderItem: (from, to) => player.move(base + from, base + to),
      itemBuilder: (_, i) => Padding(
        key: ValueKey('${tracks[i].videoId}-${base + i}'),
        padding: const EdgeInsets.only(bottom: 2),
        child: QueueRow(
          track: tracks[i],
          onDark: onDark,
          onTap: () => player.jumpTo(base + i),
          onRemove: () => player.removeAt(base + i),
          dragHandle: ReorderableDragStartListener(
            index: i,
            child: const DragGrip(),
          ),
        ),
      ),
    );

    return ListView(
      padding: padding,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 0, 0, 0),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    'Cola',
                    style: context.text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              OngakuButton.ghost(
                label: 'Guardar como playlist',
                dense: true,
                onPressed: () => ref.createPlaylist(context, seed: s.queue),
              ),
            ],
          ),
        ),
        label('Sonando'),
        QueueRow(
          track: current,
          current: true,
          playing: s.isPlaying,
          onDark: onDark,
          onTap: player.toggle,
        ),
        if (s.playingNext.isNotEmpty) ...[
          label('A continuación'),
          section(s.playingNext, nextBase),
        ],
        label(
          s.shuffle ? 'Después · aleatorio' : 'Después',
          trailing: s.later.isEmpty
              ? null
              : QuietLink(
                  'Limpiar',
                  onTap: () {
                    player.clearUpcoming();
                    showOngakuToast(context, 'Cola limpia');
                  },
                ),
        ),
        if (s.later.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'No hay más canciones. Al terminar, la cola se detiene.',
              style: TextStyle(fontSize: 13, color: c.muted),
            ),
          )
        else
          section(s.later, laterBase),
      ],
    );
  }
}
