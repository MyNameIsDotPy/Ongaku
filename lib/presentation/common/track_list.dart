import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../models/track.dart';
import '../../providers/demo_providers.dart';
import '../../providers/download_providers.dart';
import '../../providers/library_providers.dart';
import '../../providers/player_providers.dart';
import '../../shared/design_system/design_system.dart';
import 'track_actions.dart';

/// One song row bound to the player, library and downloads.
class ConnectedTrackRow extends ConsumerWidget {
  const ConnectedTrackRow({
    super.key,
    required this.track,
    required this.index,
    required this.onPlay,
    this.showAlbum = true,
    this.showArt = true,
    this.number,
    this.onRemove,
    this.dragHandle,
    this.leadingTag,
  });

  final Track track;
  final int index;
  final VoidCallback onPlay;
  final bool showAlbum;
  final bool showArt;
  final String? number;
  final VoidCallback? onRemove;
  final Widget? dragHandle;
  final Widget? leadingTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(currentTrackProvider)?.videoId == track.videoId;
    final playing =
        current && ref.watch(playerProvider.select((s) => s.isPlaying));
    final downloaded = ref.watch(isDownloadedProvider(track.videoId));
    final online = ref.watch(backendOnlineProvider);
    return TrackRow(
      track: track,
      number: number ?? '${index + 1}',
      isCurrent: current,
      isPlaying: playing,
      isFavorite: ref.watch(isFavoriteProvider(track.videoId)),
      isDownloaded: downloaded,
      dimmed: !online && !downloaded,
      showAlbum: showAlbum,
      showArt: showArt,
      onPlay: onPlay,
      onMenu: (anchor) => ref.showTrackMenu(anchor, track),
      onToggleFavorite: () => ref.toggleFavorite(context, track),
      onArtist: () => context.go(Routes.artist(track.primaryArtist.id)),
      onAlbum: track.album == null
          ? null
          : () => context.go(Routes.album(track.album!.id)),
      onRemove: onRemove,
      dragHandle: dragHandle,
      leadingTag: leadingTag,
    );
  }
}

/// A list of songs as a sliver. Tapping one plays the whole list from it,
/// labeled with [source] ("Reproduciendo desde…").
class TrackListSliver extends ConsumerWidget {
  const TrackListSliver({
    super.key,
    required this.tracks,
    required this.source,
    this.showAlbum = true,
    this.showArt = true,
    this.header = true,
  });

  final List<Track> tracks;
  final String source;
  final bool showAlbum;
  final bool showArt;
  final bool header;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverMainAxisGroup(
      slivers: [
        if (header)
          SliverToBoxAdapter(child: TrackListHeader(showAlbum: showAlbum)),
        SliverList.builder(
          itemCount: tracks.length,
          itemBuilder: (context, i) => ConnectedTrackRow(
            track: tracks[i],
            index: i,
            showAlbum: showAlbum,
            showArt: showArt,
            onPlay: () => ref
                .read(playerProvider.notifier)
                .play(tracks, start: i, from: source),
          ),
        ),
      ],
    );
  }
}
