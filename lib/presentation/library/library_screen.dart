import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../models/download_entry.dart';
import '../../models/play_event.dart';
import '../../providers/download_providers.dart';
import '../../providers/library_providers.dart';
import '../../providers/player_providers.dart';
import '../../providers/settings_providers.dart';
import '../../shared/design_system/design_system.dart';
import '../common/async_states.dart';
import '../common/formatters.dart';
import '../common/media_cards.dart';
import '../common/ongaku_page.dart';
import '../common/retry.dart';
import '../common/track_actions.dart';
import '../common/track_list.dart';

enum LibraryTab {
  playlists('playlists', 'Playlists'),
  favoritos('favoritos', 'Favoritos'),
  descargas('descargas', 'Descargas'),
  historial('historial', 'Historial');

  const LibraryTab(this.slug, this.label);
  final String slug;
  final String label;

  static LibraryTab fromSlug(String? s) =>
      values.firstWhere((t) => t.slug == s, orElse: () => playlists);
}

enum _Sort { recent, az }

/// Biblioteca (RF-19–21, RF-25–26): four tabs with a sliding indicator.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key, required this.tab});

  final LibraryTab tab;

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  _Sort _sort = _Sort.recent;

  @override
  Widget build(BuildContext context) {
    final tab = widget.tab;
    final sync = ref.watch(librarySyncProvider);
    final List<Widget> body;
    if (sync.isLoading) {
      body = [
        const PageSection(
          child: Column(
            children: [
              RowSkeleton(),
              RowSkeleton(),
              RowSkeleton(),
              RowSkeleton(),
            ],
          ),
        ),
      ];
    } else if (sync.hasError) {
      body = [
        PageSection(
          child: ApiErrorView(
            error: sync.error!,
            onRetry: () => retry(ref, [librarySyncProvider]),
          ),
        ),
      ];
    } else {
      body = switch (tab) {
        LibraryTab.playlists => _playlists(),
        LibraryTab.favoritos => _favorites(),
        LibraryTab.descargas => _downloads(),
        LibraryTab.historial => _history(),
      };
    }
    return OngakuPage(
      slivers: [
        PageSection(
          child: PageHeader(
            'Biblioteca',
            trailing: tab == LibraryTab.playlists
                ? OngakuButton(
                    label: 'Nueva playlist',
                    icon: OngakuIcons.plus,
                    onPressed: () => ref.createPlaylist(context),
                  )
                : null,
          ),
        ),
        PageSection(
          index: 1,
          child: OngakuTabs<LibraryTab>(
            tabs: [for (final t in LibraryTab.values) (t, t.label)],
            value: tab,
            onChanged: (t) => context.go(Routes.libraryTab(t.slug)),
          ),
        ),
        // Re-keyed per tab so the content swaps in with the liquid fade.
        SliverMainAxisGroup(key: ValueKey(tab), slivers: body),
      ],
    );
  }

  List<Widget> _playlists() {
    final all = ref.watch(libraryProvider).ownedPlaylists;
    if (all.isEmpty) {
      return [
        PageSection(
          child: EmptyState(
            icon: OngakuIcons.queue,
            title: 'Aún no tienes playlists',
            message:
                'Crea una o importa una playlist de YouTube pegando su enlace.',
            action: OngakuButton(
              label: 'Crear playlist',
              onPressed: () => ref.createPlaylist(context),
            ),
          ),
        ),
      ];
    }
    final ps = [...all]
      ..sort(
        (a, b) => _sort == _Sort.az
            ? a.name.toLowerCase().compareTo(b.name.toLowerCase())
            : b.createdAt.compareTo(a.createdAt),
      );
    return [
      PageSection(
        index: 2,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Align(
            alignment: Alignment.centerRight,
            child: OngakuSegmented<_Sort>(
              options: const [(_Sort.recent, 'Recientes'), (_Sort.az, 'A–Z')],
              value: _sort,
              onChanged: (v) => setState(() => _sort = v),
            ),
          ),
        ),
      ),
      PageSection(
        index: 3,
        child: CardGrid(
          children: [for (final p in ps) PlaylistCard(playlist: p)],
        ),
      ),
    ];
  }

  List<Widget> _favorites() {
    final favs = ref.watch(libraryProvider).favorites;
    if (favs.isEmpty) {
      return [
        const PageSection(
          child: EmptyState(
            icon: OngakuIcons.heart,
            title: 'Sin favoritos',
            message:
                'Toca el corazón de cualquier canción para guardarla aquí.',
          ),
        ),
      ];
    }
    return [TrackListSliver(tracks: favs, source: 'Favoritos')];
  }

  List<Widget> _downloads() {
    final c = context.colors;
    final entries = ref.watch(downloadsProvider).values.toList();
    final used = ref.watch(downloadsUsedMbProvider);
    final settings = ref.watch(settingsProvider);
    return [
      PageSection(
        index: 2,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: OngakuRadii.lgAll,
            border: Border.all(color: c.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Espacio usado',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    '${used.toStringAsFixed(1)} MB de ${settings.downloadLimitGb} GB',
                    style: OngakuTypography.mono(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              UsageBar(fraction: used / (settings.downloadLimitGb * 1024)),
              const SizedBox(height: 10),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                children: [
                  Text(
                    settings.downloadOnWifiOnly
                        ? 'Las descargas solo se hacen con Wi-Fi.'
                        : 'Las descargas también usan datos móviles.',
                    style: TextStyle(fontSize: 13, color: c.muted),
                  ),
                  QuietLink(
                    'Cambiar',
                    onTap: () => context.go(Routes.settings),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      if (entries.isEmpty)
        const PageSection(
          child: EmptyState(
            icon: OngakuIcons.download,
            title: 'Nada descargado',
            message: 'Descarga una playlist antes de quedarte sin señal.',
          ),
        )
      else
        SliverList.builder(
          itemCount: entries.length,
          itemBuilder: (context, i) => _DownloadRow(entry: entries[i]),
        ),
    ];
  }

  List<Widget> _history() {
    final history = ref.watch(libraryProvider).history;
    if (history.isEmpty) {
      return [
        const PageSection(
          child: EmptyState(
            icon: OngakuIcons.queue,
            title: 'Sin historial',
            message: 'Lo que escuches en el celular y en el PC aparece aquí.',
          ),
        ),
      ];
    }
    final groups = <String, List<PlayEvent>>{};
    for (final e in history) {
      (groups[dayLabel(e.playedAt)] ??= []).add(e);
    }
    final player = ref.read(playerProvider.notifier);
    return [
      for (final MapEntry(key: day, value: events) in groups.entries) ...[
        PageSection(top: 24, child: SectionHeader(day, small: true)),
        SliverList.builder(
          itemCount: events.length,
          itemBuilder: (context, i) {
            final e = events[i];
            return ConnectedTrackRow(
              track: e.track,
              index: i,
              number: '',
              showAlbum: false,
              onPlay: () => player.play(
                [for (final x in events) x.track],
                start: i,
                from: 'Historial',
              ),
              leadingTag: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: OngakuTag(
                  OngakuBreakpoints.isCompact(context)
                      ? hourMinute(e.playedAt)
                      : '${e.device.label} · ${hourMinute(e.playedAt)}',
                  icon: e.device == DeviceKind.pc
                      ? OngakuIcons.computer
                      : OngakuIcons.phone,
                ),
              ),
            );
          },
        ),
      ],
    ];
  }
}

class _DownloadRow extends ConsumerWidget {
  const _DownloadRow({required this.entry});

  final DownloadEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final e = entry;
    final playlist = ref.watch(playlistProvider(e.collectionId));
    final covers = playlist?.covers ?? const <String>[];
    final route = e.kind == DownloadKind.album
        ? Routes.album(e.collectionId)
        : playlist != null
        ? Routes.playlist(e.collectionId)
        : null;
    return OngakuPressable(
      onTap: route == null ? null : () => context.go(route),
      borderRadius: OngakuRadii.mdAll,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          OngakuCover(
            urls: e.kind == DownloadKind.album
                ? ['assets/images/covers/${e.collectionId}.jpg']
                : covers,
            size: 52,
            radius: OngakuRadii.sm,
            placeholder: OngakuIcons.download,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    OngakuIcon(
                      e.isDone ? OngakuIcons.check : OngakuIcons.download,
                      size: 14,
                      color: c.ok,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        e.isDone
                            ? '${plural(e.trackIds.length, 'canción', 'canciones')} descargadas'
                            : '${e.completedTracks} de ${e.trackIds.length} canciones…',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: c.muted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${e.sizeMb.toStringAsFixed(1)} MB',
            style: OngakuTypography.mono(context),
          ),
          const SizedBox(width: 8),
          OngakuIconButton(
            icon: OngakuIcons.trash,
            size: OngakuIconButtonSize.small,
            tooltip: 'Borrar descarga',
            onPressed: () {
              ref.read(downloadsProvider.notifier).remove(e.collectionId);
              showOngakuToast(context, 'Descarga borrada');
            },
          ),
        ],
      ),
    );
  }
}
