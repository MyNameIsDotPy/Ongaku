import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../models/album.dart';
import '../../models/artist.dart';
import '../../models/playlist.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/player_providers.dart';
import '../../shared/design_system/design_system.dart';
import 'track_actions.dart';

Future<void> playAlbumById(
  BuildContext context,
  WidgetRef ref,
  String id,
) async {
  try {
    final album = await ref.read(albumProvider(id).future);
    ref.read(playerProvider.notifier).play(album.tracks, from: album.title);
  } catch (_) {
    if (context.mounted) {
      showOngakuToast(context, 'No se pudo cargar el álbum', error: true);
    }
  }
}

class AlbumCard extends ConsumerWidget {
  const AlbumCard({super.key, required this.album, this.hero = true});

  final Album album;
  final bool hero;

  @override
  Widget build(BuildContext context, WidgetRef ref) => MediaCard(
    covers: [album.coverUrl],
    title: album.title,
    subtitle: [
      if (album.year != null) '${album.year}',
      if (album.artist.name.isNotEmpty) album.artist.name,
    ].join(' · '),
    placeholder: OngakuIcons.album,
    heroTag: hero ? 'cover-${album.id}' : null,
    onTap: () => context.go(Routes.album(album.id)),
    onPlay: () =>
        ref.read(playerProvider.notifier).play(album.tracks, from: album.title),
  );
}

class PlaylistCard extends ConsumerWidget {
  const PlaylistCard({super.key, required this.playlist});

  final Playlist playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) => MediaCard(
    covers: playlist.covers,
    title: playlist.name,
    subtitle:
        '${plural(playlist.size, 'canción', 'canciones')}'
        '${playlist.isOwn ? '' : ' · YouTube'}',
    heroTag: 'cover-${playlist.id}',
    onTap: () => context.go(Routes.playlist(playlist.id)),
    onPlay: playlist.tracks.isEmpty
        ? null
        : () => ref
              .read(playerProvider.notifier)
              .play(playlist.tracks, from: playlist.name),
  );
}

class ArtistCard extends StatelessWidget {
  const ArtistCard({super.key, required this.artist});

  final Artist artist;

  @override
  Widget build(BuildContext context) => MediaCard(
    covers: [
      ?(artist.avatarUrl ??
          artist.photoUrl ??
          artist.albums.firstOrNull?.coverUrl),
    ],
    title: artist.name,
    subtitle: 'Artista',
    circle: true,
    placeholder: OngakuIcons.user,
    onTap: () => context.go(Routes.artist(artist.id)),
  );
}
