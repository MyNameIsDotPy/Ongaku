import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../models/download_entry.dart';
import '../../models/playlist.dart';
import '../../models/track.dart';
import '../../providers/library_providers.dart';
import '../../providers/player_providers.dart';
import '../../shared/design_system/design_system.dart';
import '../album/album_screen.dart';
import '../common/async_states.dart';
import '../common/download_button.dart';
import '../common/formatters.dart';
import '../common/ongaku_page.dart';
import '../common/retry.dart';
import '../common/track_actions.dart';
import '../common/track_list.dart';

/// Playlist (RF-06, RF-19, RF-22). Own playlists can be renamed, reordered
/// by dragging and emptied with undo. A YouTube one is previewed first and
/// then imported as an editable copy.
class PlaylistScreen extends ConsumerWidget {
  const PlaylistScreen({super.key, required this.playlistId});

  final String playlistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(librarySyncProvider);
    final p = ref.watch(playlistProvider(playlistId));
    if (sync.isLoading) {
      return const OngakuPage(slivers: [PageSection(child: DetailSkeleton())]);
    }
    if (sync.hasError) {
      return OngakuPage(
        slivers: [
          PageSection(
            child: ApiErrorView(
              error: sync.error!,
              onRetry: () => retry(ref, [librarySyncProvider]),
            ),
          ),
        ],
      );
    }
    if (p == null) {
      return OngakuPage(
        slivers: [
          PageSection(
            child: EmptyState(
              icon: OngakuIcons.queue,
              title: 'Playlist no encontrada',
              message: 'Puede que se haya borrado en otro dispositivo.',
              action: OngakuButton(
                label: 'Ir a la biblioteca',
                onPressed: () => context.go(Routes.library),
              ),
            ),
          ),
        ],
      );
    }
    return _PlaylistBody(playlist: p);
  }
}

class _PlaylistBody extends ConsumerStatefulWidget {
  const _PlaylistBody({required this.playlist});

  final Playlist playlist;

  @override
  ConsumerState<_PlaylistBody> createState() => _PlaylistBodyState();
}

class _PlaylistBodyState extends ConsumerState<_PlaylistBody> {
  bool _editing = false;
  bool _importing = false;
  late final _name = TextEditingController(text: widget.playlist.name);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Playlist get p => widget.playlist;

  Future<void> _saveName() async {
    final n = _name.text.trim();
    if (n.isNotEmpty && n != p.name) {
      await ref.read(libraryProvider.notifier).rename(p.id, n);
      if (mounted) showOngakuToast(context, 'Nombre actualizado');
    }
    setState(() => _editing = false);
  }

  Future<void> _delete() async {
    final ok = await showOngakuDialog<bool>(
      context,
      title: '¿Borrar “${p.name}”?',
      subtitle: 'Se borrará también en tus otros dispositivos.',
      builder: (ctx) => DialogActions(
        children: [
          OngakuButton.ghost(
            label: 'Cancelar',
            onPressed: () => Navigator.pop(ctx),
          ),
          OngakuButton(
            label: 'Borrar playlist',
            variant: OngakuButtonVariant.danger,
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final lib = ref.read(libraryProvider.notifier);
    await lib.delete(p.id);
    if (!mounted) return;
    final id = p.id;
    context.go(Routes.library);
    showOngakuToast(
      context,
      'Playlist borrada',
      actionLabel: 'Deshacer',
      onAction: () => lib.restore(id),
    );
  }

  Future<void> _import() async {
    setState(() => _importing = true);
    final copy = await ref.read(libraryProvider.notifier).import(p);
    if (!mounted) return;
    context.go(Routes.playlist(copy.id));
    showOngakuToast(context, '“${copy.name}” importada como copia editable');
  }

  void _remove(int i) {
    final lib = ref.read(libraryProvider.notifier);
    final before = p.tracks;
    lib.setTracks(p.id, [...before]..removeAt(i));
    showOngakuToast(
      context,
      'Quitada de la playlist',
      actionLabel: 'Deshacer',
      onAction: () => lib.setTracks(p.id, before),
    );
  }

  void _reorder(int from, int to) {
    final tracks = [...p.tracks];
    tracks.insert(to, tracks.removeAt(from));
    ref.read(libraryProvider.notifier).setTracks(p.id, tracks);
    showOngakuToast(context, 'Orden guardado · se sincronizará');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final player = ref.read(playerProvider.notifier);
    final first = p.tracks.firstOrNull;
    final glow = first == null || first.palette.isEmpty
        ? null
        : Color(first.palette.first);
    final eyebrow = p.isOwn
        ? 'Playlist propia'
        : p.inLibrary
        ? 'Importada de YouTube'
        : 'Playlist de YouTube · vista previa';

    final title = _editing
        ? ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: OngakuTextField(
                      controller: _name,
                      large: true,
                      autofocus: true,
                      maxLength: 60,
                      onSubmitted: (_) => _saveName(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OngakuButton(label: 'Guardar', onPressed: _saveName),
                ],
              ),
            ),
          )
        : Text(p.name);

    return OngakuPage(
      tint: glow,
      slivers: [
        PageSection(
          child: DetailHero(
            artwork: Hero(
              tag: 'cover-${p.id}',
              child: OngakuCover(urls: p.covers, radius: OngakuRadii.tile),
            ),
            glow: glow,
            eyebrow: eyebrow,
            title: title,
            facts: [
              HeroFact(plural(p.tracks.length, 'canción', 'canciones')),
              HeroFact(formatLong(p.totalDuration), mono: true),
              if (p.isOwn)
                HeroFact('Creada el ${shortDate(p.createdAt)}')
              else
                OngakuTag(
                  'youtube.com/playlist?list=${p.sourceId}',
                  icon: OngakuIcons.link,
                ),
            ],
          ),
        ),
        PageSection(
          index: 1,
          child: DetailActions(
            children: [
              OngakuPlayButton(
                playing: false,
                onPressed: p.tracks.isEmpty
                    ? null
                    : () => player.play(p.tracks, from: p.name),
              ),
              OngakuIconButton(
                icon: OngakuIcons.shuffle,
                tooltip: 'Reproducir en aleatorio',
                onPressed: p.tracks.isEmpty
                    ? null
                    : () => player.shufflePlay(p.tracks, from: p.name),
              ),
              DownloadButton(
                id: p.id,
                kind: DownloadKind.playlist,
                title: p.name,
                tracks: p.tracks,
              ),
              if (p.isOwn) ...[
                OngakuIconButton(
                  icon: OngakuIcons.edit,
                  tooltip: 'Renombrar',
                  active: _editing,
                  onPressed: () => setState(() {
                    _name.text = p.name;
                    _editing = !_editing;
                  }),
                ),
                OngakuIconButton(
                  icon: OngakuIcons.trash,
                  tooltip: 'Borrar playlist',
                  onPressed: _delete,
                ),
              ] else if (!p.inLibrary)
                OngakuButton(
                  label: _importing
                      ? 'Importando…'
                      : 'Importar a mi biblioteca',
                  icon: OngakuIcons.plus,
                  loading: _importing,
                  onPressed: _import,
                ),
            ],
          ),
        ),
        if (p.tracks.isEmpty)
          PageSection(
            child: EmptyState(
              icon: OngakuIcons.search,
              title: 'Esta playlist está vacía',
              message:
                  'Agrega canciones desde la búsqueda con el menú ⋯ de cada fila.',
              action: OngakuButton(
                label: 'Buscar canciones',
                onPressed: () => context.go(Routes.search),
              ),
            ),
          )
        else if (p.isOwn) ...[
          const SliverToBoxAdapter(child: TrackListHeader(editable: true)),
          SliverReorderableList(
            itemCount: p.tracks.length,
            onReorderItem: _reorder,
            proxyDecorator: (child, _, _) => Material(
              color: c.surface,
              elevation: 12,
              shadowColor: Colors.black54,
              borderRadius: OngakuRadii.mdAll,
              child: child,
            ),
            itemBuilder: (context, i) => _ReorderableTrack(
              key: ValueKey('${p.tracks[i].videoId}-$i'),
              index: i,
              track: p.tracks[i],
              onPlay: () => player.play(p.tracks, start: i, from: p.name),
              onRemove: () => _remove(i),
            ),
          ),
          PageSection(
            top: 14,
            child: Text(
              'Arrastra desde ⠿ para reordenar. Los cambios se sincronizan con tus otros dispositivos.',
              style: TextStyle(fontSize: 13, color: c.muted),
            ),
          ),
        ] else
          TrackListSliver(tracks: p.tracks, source: p.name),
      ],
    );
  }
}

class _ReorderableTrack extends StatelessWidget {
  const _ReorderableTrack({
    super.key,
    required this.index,
    required this.track,
    required this.onPlay,
    required this.onRemove,
  });

  final int index;
  final Track track;
  final VoidCallback onPlay;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => ConnectedTrackRow(
    track: track,
    index: index,
    onPlay: onPlay,
    onRemove: onRemove,
    dragHandle: ReorderableDragStartListener(
      index: index,
      child: const DragGrip(),
    ),
  );
}
