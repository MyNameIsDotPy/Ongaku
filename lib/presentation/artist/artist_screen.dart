import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/artist.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/player_providers.dart';
import '../../shared/design_system/design_system.dart';
import '../album/album_screen.dart';
import '../common/async_states.dart';
import '../common/media_cards.dart';
import '../common/ongaku_page.dart';
import '../common/retry.dart';
import '../common/track_actions.dart';
import '../common/track_list.dart';

/// Artista (RF-05, RF-15): photo, popular songs, albums and singles; play
/// the popular ones or start the artist radio.
class ArtistScreen extends ConsumerWidget {
  const ArtistScreen({super.key, required this.artistId});

  final String artistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(artistProvider(artistId))) {
      AsyncData(:final value) => _ArtistBody(artist: value),
      AsyncError(:final error) => OngakuPage(
        slivers: [
          PageSection(
            child: ApiErrorView(
              error: error,
              onRetry: () => retry(ref, [artistProvider(artistId)]),
            ),
          ),
        ],
      ),
      _ => const OngakuPage(slivers: [PageSection(child: DetailSkeleton())]),
    };
  }
}

class _ArtistBody extends ConsumerWidget {
  const _ArtistBody({required this.artist});

  final Artist artist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = artist;
    final c = context.colors;
    final first = a.albums.firstOrNull;
    final glow = first == null || first.palette.isEmpty
        ? null
        : Color(first.palette.first);
    final hero = a.photoUrl != null
        ? _PhotoHero(artist: a)
        : DetailHero(
            circle: true,
            glow: glow,
            artwork: OngakuCover(
              urls: [?first?.coverUrl],
              circle: true,
              placeholder: OngakuIcons.user,
            ),
            eyebrow: 'Artista',
            title: Text(a.name),
            facts: [
              HeroFact(
                '${plural(a.albums.length, 'álbum', 'álbumes')} en el catálogo de ejemplo',
              ),
            ],
          );
    return OngakuPage(
      tint: a.photoUrl == null ? glow : null,
      slivers: [
        PageSection(child: hero),
        PageSection(
          index: 1,
          child: DetailActions(
            children: [
              OngakuPlayButton(
                playing: false,
                onPressed: () => ref
                    .read(playerProvider.notifier)
                    .play(a.popular, from: 'Populares de ${a.name}'),
              ),
              OngakuButton(
                label: 'Radio del artista',
                icon: OngakuIcons.radio,
                onPressed: a.popular.isEmpty
                    ? null
                    : () => ref.startRadio(context, a.popular.first),
              ),
            ],
          ),
        ),
        const PageSection(index: 2, child: SectionHeader('Populares')),
        TrackListSliver(tracks: a.popular, source: 'Populares de ${a.name}'),
        PageSection(
          top: OngakuSpacing.block,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader('Álbumes'),
              CardGrid(
                children: [for (final al in a.albums) AlbumCard(album: al)],
              ),
            ],
          ),
        ),
        PageSection(
          top: OngakuSpacing.block,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader('Sencillos'),
              if (a.singles.isEmpty)
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text:
                            'Los datos de ejemplo no incluyen sencillos; en la app los entrega ',
                      ),
                      TextSpan(
                        text: 'GET /v1/artists/{id}',
                        style: OngakuTypography.mono(context),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                  style: TextStyle(fontSize: 13, color: c.muted),
                )
              else
                CardGrid(
                  children: [for (final s in a.singles) AlbumCard(album: s)],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Full-bleed photo with the name over a bottom scrim (`.artist-hero`).
class _PhotoHero extends StatelessWidget {
  const _PhotoHero({required this.artist});

  final Artist artist;

  @override
  Widget build(BuildContext context) {
    final compact = OngakuBreakpoints.isCompact(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: ClipRRect(
        borderRadius: OngakuRadii.xlAll,
        child: SizedBox(
          height: compact ? 260 : 360,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image(
                image: coverImage(artist.photoUrl!),
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.4),
                semanticLabel: '${artist.name} en vivo',
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.4, 1],
                    colors: [Color(0x00000000), Color(0x99000000)],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'ARTISTA',
                          style: OngakuTypography.eyebrow(
                            context,
                            color: const Color(0xFFE6E6E6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Semantics(
                          header: true,
                          child: Text(
                            artist.name,
                            style: TextStyle(
                              color: const Color(0xFFFCFCFC),
                              fontSize: compact ? 40 : 72,
                              fontWeight: FontWeight.w800,
                              letterSpacing: compact ? -0.8 : -1.4,
                              height: 1,
                              shadows: const [
                                Shadow(
                                  color: Color(0x73000000),
                                  blurRadius: 24,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (artist.photoCredit != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x8C0A0A0A),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          artist.photoCredit!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFF2F2F2),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
