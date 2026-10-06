import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../models/album.dart';
import '../../models/download_entry.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/player_providers.dart';
import '../../shared/design_system/design_system.dart';
import '../common/cover_palette.dart';
import '../common/async_states.dart';
import '../common/download_button.dart';
import '../common/media_cards.dart';
import '../common/ongaku_page.dart';
import '../common/retry.dart';
import '../common/track_actions.dart';
import '../common/track_list.dart';

/// Álbum (RF-04): cover, year, tracks and total time; play, shuffle,
/// download and save as playlist. The page takes the cover's color.
class AlbumScreen extends ConsumerWidget {
  const AlbumScreen({super.key, required this.albumId});

  final String albumId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(albumProvider(albumId))) {
      AsyncData(:final value) => _AlbumBody(album: value),
      AsyncError(:final error) => OngakuPage(
        slivers: [
          PageSection(
            child: ApiErrorView(
              error: error,
              onRetry: () => retry(ref, [albumProvider(albumId)]),
            ),
          ),
        ],
      ),
      _ => const OngakuPage(slivers: [PageSection(child: DetailSkeleton())]),
    };
  }
}

class _AlbumBody extends ConsumerWidget {
  const _AlbumBody({required this.album});

  final Album album;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = album;
    final player = ref.read(playerProvider.notifier);
    final glow = a.palette.isNotEmpty
        ? Color(a.palette.first)
        : ref.watch(coverPaletteProvider(a.coverUrl)).value?.firstOrNull;
    final more =
        ref
            .watch(artistProvider(a.artist.id))
            .value
            ?.albums
            .where((x) => x.id != a.id)
            .toList() ??
        const <Album>[];
    return OngakuPage(
      tint: glow,
      slivers: [
        PageSection(
          child: DetailHero(
            artwork: Hero(
              tag: 'cover-${a.id}',
              child: OngakuCover.single(
                a.coverUrl,
                radius: OngakuRadii.tile,
                semanticLabel: 'Portada de ${a.title}',
              ),
            ),
            glow: glow,
            eyebrow: 'Álbum · ${a.genre}',
            title: Text(a.title),
            facts: [
              QuietLink(
                a.artist.name,
                color: context.colors.fg,
                onTap: () => context.go(Routes.artist(a.artist.id)),
              ),
              if (a.year != null) HeroFact('${a.year}', mono: true),
              HeroFact(plural(a.tracks.length, 'canción', 'canciones')),
              HeroFact(formatLong(a.totalDuration), mono: true),
            ],
          ),
        ),
        PageSection(
          index: 1,
          child: DetailActions(
            children: [
              OngakuPlayButton(
                playing: false,
                onPressed: () => player.play(a.tracks, from: a.title),
              ),
              OngakuIconButton(
                icon: OngakuIcons.shuffle,
                tooltip: 'Reproducir en aleatorio',
                onPressed: () => player.shufflePlay(a.tracks, from: a.title),
              ),
              DownloadButton(
                id: a.id,
                kind: DownloadKind.album,
                title: a.title,
                tracks: a.tracks,
              ),
              OngakuButton.ghost(
                label: 'Guardar como playlist',
                icon: OngakuIcons.plus,
                onPressed: () => ref.createPlaylist(
                  context,
                  seed: a.tracks,
                  initialName: a.title,
                ),
              ),
            ],
          ),
        ),
        TrackListSliver(
          tracks: a.tracks,
          source: a.title,
          showAlbum: false,
          showArt: false,
        ),
        PageSection(
          top: 20,
          child: Text(
            '© ${[if (a.year != null) a.year, a.artist.name].join(' ')}',
            style: TextStyle(fontSize: 13, color: context.colors.muted),
          ),
        ),
        if (more.isNotEmpty)
          PageSection(
            top: OngakuSpacing.block,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(
                  'Más de ${a.artist.name}',
                  actionLabel: 'Ver artista',
                  onAction: () => context.go(Routes.artist(a.artist.id)),
                ),
                CardGrid(children: [for (final m in more) AlbumCard(album: m)]),
              ],
            ),
          ),
      ],
    );
  }
}

class DetailActions extends StatelessWidget {
  const DetailActions({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4, bottom: 20),
    child: Wrap(
      alignment: OngakuBreakpoints.isCompact(context)
          ? WrapAlignment.center
          : WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: children,
    ),
  );
}
