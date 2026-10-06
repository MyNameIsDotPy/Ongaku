import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../models/track.dart';
import '../../providers/download_providers.dart';
import '../../providers/library_providers.dart';
import '../../providers/player_providers.dart';
import '../../shared/design_system/design_system.dart';
import '../common/async_states.dart';
import '../common/formatters.dart';
import '../common/ongaku_page.dart';
import '../common/retry.dart';
import '../common/track_actions.dart';
import '../common/media_cards.dart';

/// Inicio: keep listening (with the restored position), shortcuts to
/// favorites and downloads, own playlists and recently played (RF-16, RF-21).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(librarySyncProvider);
    final library = ref.watch(libraryProvider);
    final header = PageSection(
      child: PageHeader(greeting(), eyebrow: longDate(DateTime.now())),
    );

    if (sync.isLoading) {
      return OngakuPage(
        slivers: [
          header,
          const PageSection(child: _HomeSkeleton()),
        ],
      );
    }
    if (sync.hasError) {
      return OngakuPage(
        slivers: [
          header,
          PageSection(
            child: ApiErrorView(
              error: sync.error!,
              onRetry: () => retry(ref, [librarySyncProvider]),
            ),
          ),
        ],
      );
    }
    if (library.history.isEmpty && library.ownedPlaylists.isEmpty) {
      return OngakuPage(
        slivers: [
          header,
          PageSection(
            index: 1,
            child: EmptyState(
              icon: OngakuIcons.search,
              title: 'Todavía no has escuchado nada',
              message:
                  'Busca una canción o pega el enlace de una playlist de YouTube para empezar.',
              action: OngakuButton(
                label: 'Ir a buscar',
                onPressed: () => context.go(Routes.search),
              ),
            ),
          ),
        ],
      );
    }

    final seen = <String, Track>{};
    for (final e in library.history) {
      seen.putIfAbsent(e.track.videoId, () => e.track);
    }
    final albums = <String, AlbumRef>{};
    for (final t in seen.values) {
      if (t.album != null) albums.putIfAbsent(t.album!.id, () => t.album!);
    }
    final own = library.ownedPlaylists;
    final downloads = ref.watch(downloadsProvider);

    return OngakuPage(
      slivers: [
        header,
        PageSection(
          index: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(
                'Seguir escuchando',
                actionLabel: 'Historial',
                onAction: () => context.go(Routes.libraryTab('historial')),
              ),
              _ResumeRow(history: seen.values.toList()),
            ],
          ),
        ),
        PageSection(
          index: 2,
          top: OngakuSpacing.block,
          child: _Tiles(
            children: [
              ShortcutTile(
                leading: const OngakuIcon(OngakuIcons.heart, solid: true),
                title: 'Favoritos',
                subtitle: plural(
                  library.favorites.length,
                  'canción',
                  'canciones',
                ),
                onTap: () => context.go(Routes.libraryTab('favoritos')),
              ),
              ShortcutTile(
                leading: const OngakuIcon(OngakuIcons.download),
                title: 'Descargas',
                subtitle:
                    '${plural(downloads.length, 'lista', 'listas')} · disponibles sin conexión',
                onTap: () => context.go(Routes.libraryTab('descargas')),
              ),
              for (final p in own.take(2))
                ShortcutTile(
                  leading: OngakuCover(urls: p.covers, radius: 0),
                  title: p.name,
                  subtitle: plural(p.tracks.length, 'canción', 'canciones'),
                  onTap: () => context.go(Routes.playlist(p.id)),
                ),
            ],
          ),
        ),
        if (own.isNotEmpty)
          PageSection(
            index: 3,
            top: OngakuSpacing.block,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(
                  'Tus playlists',
                  actionLabel: 'Ver biblioteca',
                  onAction: () => context.go(Routes.library),
                ),
                CardGrid(
                  children: [for (final p in own) PlaylistCard(playlist: p)],
                ),
              ],
            ),
          ),
        if (albums.isNotEmpty)
          PageSection(
            index: 4,
            top: OngakuSpacing.block,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader('Escuchado recientemente'),
                CardGrid(
                  children: [
                    for (final a in albums.values)
                      AlbumRefCard(album: a, tracks: seen.values),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ResumeRow extends ConsumerWidget {
  const _ResumeRow({required this.history});

  final List<Track> history;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(playerProvider);
    final cur = s.current;
    final pos = ref.watch(positionProvider).value ?? Duration.zero;
    final items = [
      ?cur,
      ...history.where((t) => t.videoId != cur?.videoId),
    ].take(4).toList();
    final compact = OngakuBreakpoints.isCompact(context);

    void resume(Track t) {
      final player = ref.read(playerProvider.notifier);
      if (cur?.videoId == t.videoId) {
        if (!s.isPlaying) player.toggle();
        return;
      }
      player.play([t], from: t.album?.name ?? 'Historial');
    }

    return LayoutBuilder(
      builder: (context, box) {
        final w = compact
            ? box.maxWidth * 0.82
            : ((box.maxWidth - 36) / 4).clamp(280.0, 400.0);
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                    right: i == items.length - 1 ? 0 : 12,
                  ),
                  child: SizedBox(
                    width: w,
                    child: ResumeCard(
                      coverUrl: items[i].coverUrl,
                      title: items[i].title,
                      subtitle: i == 0 && cur != null
                          ? '${items[i].artistNames} · ${formatDuration(pos)} de ${formatDuration(items[i].duration)}'
                          : items[i].artistNames,
                      progress:
                          i == 0 &&
                              cur != null &&
                              items[i].duration.inMilliseconds > 0
                          ? pos.inMilliseconds /
                                items[i].duration.inMilliseconds
                          : null,
                      onTap: () => resume(items[i]),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Tiles extends StatelessWidget {
  const _Tiles({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final cols = ((box.maxWidth + 12) / (220 + 12)).floor().clamp(1, 4);
      final w = (box.maxWidth - 12 * (cols - 1)) / cols;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [for (final c in children) SizedBox(width: w, child: c)],
      );
    },
  );
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const OngakuSkeleton(width: 200, height: 20),
      const SizedBox(height: 14),
      Row(
        children: [
          for (var i = 0; i < 3; i++) ...[
            const Expanded(child: OngakuSkeleton(height: 76, radius: 14)),
            if (i < 2) const SizedBox(width: 12),
          ],
        ],
      ),
      const SizedBox(height: 40),
      const OngakuSkeleton(width: 160, height: 20),
      const SizedBox(height: 14),
      CardGrid(
        children: [
          for (var i = 0; i < 6; i++)
            const AspectRatio(
              aspectRatio: 1,
              child: OngakuSkeleton(radius: 12),
            ),
        ],
      ),
    ],
  );
}

/// Album card when only the [AlbumRef] is known (cover taken from a track).
class AlbumRefCard extends ConsumerWidget {
  const AlbumRefCard({super.key, required this.album, required this.tracks});

  final AlbumRef album;
  final Iterable<Track> tracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = tracks.firstWhere((t) => t.album?.id == album.id);
    return MediaCard(
      covers: [t.coverUrl],
      title: album.name,
      subtitle: t.artistNames,
      placeholder: OngakuIcons.album,
      heroTag: 'cover-${album.id}',
      onTap: () => context.go(Routes.album(album.id)),
      onPlay: () => playAlbumById(context, ref, album.id),
    );
  }
}
