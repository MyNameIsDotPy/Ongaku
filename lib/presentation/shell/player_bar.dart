import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../models/player_snapshot.dart';
import '../../models/track.dart';
import '../../providers/library_providers.dart';
import '../../providers/player_providers.dart';
import '../../providers/ui_providers.dart';
import '../../shared/design_system/design_system.dart';
import '../common/track_actions.dart';
import '../player/beat_builder.dart';

const nowPlayingCoverHero = 'now-playing-cover';

void openNowPlaying(
  BuildContext context,
  WidgetRef ref, [
  NowPlayingMode mode = NowPlayingMode.cover,
]) {
  if (ref.read(currentTrackProvider) == null) return;
  ref.read(nowPlayingModeProvider.notifier).set(mode);
  context.push(Routes.nowPlaying);
}

/// Desktop bottom bar: now playing, transport + seek, and secondary actions.
class PlayerBar extends ConsumerWidget {
  const PlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(playerProvider);
    final t = s.current;
    final player = ref.read(playerProvider.notifier);
    final c = context.colors;
    final queueOpen = ref.watch(queuePanelOpenProvider);
    return Container(
      height: OngakuSpacing.playerBar,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: c.bg.withValues(alpha: 0.96),
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 10,
            child: Align(
              alignment: Alignment.centerLeft,
              child: t == null ? const SizedBox.shrink() : _NowPlayingButton(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 13,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OngakuIconButton(
                      icon: OngakuIcons.shuffle,
                      size: OngakuIconButtonSize.small,
                      tooltip: 'Aleatorio',
                      active: s.shuffle,
                      onPressed: player.toggleShuffle,
                    ),
                    const SizedBox(width: 6),
                    OngakuIconButton(
                      icon: OngakuIcons.prev,
                      tooltip: 'Anterior (Ctrl ←)',
                      onPressed: t == null ? null : player.previous,
                    ),
                    const SizedBox(width: 6),
                    OngakuPlayButton(
                      playing: s.isPlaying,
                      busy: s.isBusy,
                      size: 44,
                      style: OngakuPlayButtonStyle.ink,
                      onPressed: t == null ? null : player.toggle,
                    ),
                    const SizedBox(width: 6),
                    OngakuIconButton(
                      icon: OngakuIcons.next,
                      tooltip: 'Siguiente (Ctrl →)',
                      onPressed: t == null ? null : player.next,
                    ),
                    const SizedBox(width: 6),
                    OngakuIconButton(
                      icon: s.repeat == QueueRepeat.one
                          ? OngakuIcons.repeatOne
                          : OngakuIcons.repeat,
                      size: OngakuIconButtonSize.small,
                      tooltip: s.repeat.label,
                      active: s.repeat != QueueRepeat.off,
                      onPressed: player.cycleRepeat,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: const PlayerSeekBar(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (t != null) ...[
                  OngakuEq(active: s.isPlaying, color: c.fg),
                  const SizedBox(width: 8),
                  OngakuIconButton(
                    icon: OngakuIcons.heart,
                    size: OngakuIconButtonSize.small,
                    solid: ref.watch(isFavoriteProvider(t.videoId)),
                    active: ref.watch(isFavoriteProvider(t.videoId)),
                    tooltip: 'Favorito (Ctrl L)',
                    onPressed: () => ref.toggleFavorite(context, t),
                  ),
                ],
                const _VolumeControl(),
                const SizedBox(width: 8),
                OngakuIconButton(
                  icon: OngakuIcons.lyrics,
                  size: OngakuIconButtonSize.small,
                  tooltip: 'Letra',
                  onPressed: t == null
                      ? null
                      : () =>
                            openNowPlaying(context, ref, NowPlayingMode.lyrics),
                ),
                OngakuIconButton(
                  icon: OngakuIcons.queue,
                  size: OngakuIconButtonSize.small,
                  tooltip: 'Cola',
                  active: queueOpen,
                  onPressed: ref.read(queuePanelOpenProvider.notifier).toggle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NowPlayingButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(currentTrackProvider)!;
    return OngakuPressable(
      onTap: () => openNowPlaying(context, ref),
      semanticLabel: 'Abrir reproductor',
      borderRadius: OngakuRadii.mdAll,
      padding: const EdgeInsets.all(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          BeatPulse(
            track: t,
            amount: 0.05,
            child: Hero(
              tag: nowPlayingCoverHero,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: OngakuRadii.smAll,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x80000000),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                      spreadRadius: -8,
                    ),
                  ],
                ),
                child: OngakuCover.single(
                  t.coverUrl,
                  size: 52,
                  radius: OngakuRadii.sm,
                  semanticLabel: 'Portada de ${t.album?.name ?? t.title}',
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  t.artistNames,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: context.colors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Seek bar bound to the player position.
class PlayerSeekBar extends ConsumerWidget {
  const PlayerSeekBar({super.key, this.large = false, this.energy = 0});

  final bool large;
  final double energy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(currentTrackProvider);
    final pos = ref.watch(positionProvider).value ?? Duration.zero;
    return OngakuSeekBar(
      position: pos,
      duration: t?.duration ?? Duration.zero,
      playing: ref.watch(playerProvider.select((s) => s.isPlaying)),
      energy: energy,
      large: large,
      onSeek: ref.read(playerProvider.notifier).seek,
    );
  }
}

/// Phone mini-player: floating card above the tabs with a 2 px progress line.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(playerProvider);
    final t = s.current;
    if (t == null) return const SizedBox.shrink();
    final c = context.colors;
    final pos = ref.watch(positionProvider).value ?? Duration.zero;
    final frac = t.duration.inMilliseconds == 0
        ? 0.0
        : (pos.inMilliseconds / t.duration.inMilliseconds).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: c.surface.withValues(alpha: 0.94),
          borderRadius: OngakuRadii.tileAll,
          border: Border.all(color: c.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 28,
              offset: Offset(0, 12),
              spreadRadius: -16,
            ),
          ],
        ),
        child: Stack(
          children: [
            OngakuPressable(
              onTap: () => openNowPlaying(context, ref),
              semanticLabel: 'Abrir reproductor: ${t.title}',
              hoverColor: Colors.transparent,
              borderRadius: OngakuRadii.tileAll,
              padding: const EdgeInsets.fromLTRB(4, 4, 6, 4),
              child: Row(
                children: [
                  BeatPulse(
                    track: t,
                    amount: 0.05,
                    child: Hero(
                      tag: nowPlayingCoverHero,
                      child: OngakuCover.single(
                        t.coverUrl,
                        size: 44,
                        radius: OngakuRadii.sm,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          t.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          t.artistNames,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, color: c.muted),
                        ),
                      ],
                    ),
                  ),
                  OngakuPlayButton(
                    playing: s.isPlaying,
                    busy: s.isBusy,
                    size: 44,
                    style: OngakuPlayButtonStyle.bare,
                    onPressed: ref.read(playerProvider.notifier).toggle,
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: frac,
                  child: Container(height: 2, color: c.fg),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Scales its child on each beat while playing (up to +[amount]).
class BeatPulse extends StatelessWidget {
  const BeatPulse({
    super.key,
    required this.track,
    required this.child,
    this.amount = 0.03,
  });

  final Track track;
  final Widget child;
  final double amount;

  @override
  Widget build(BuildContext context) => BeatBuilder(
    track: track,
    child: child,
    builder: (context, levels, child) =>
        Transform.scale(scale: 1 + levels.beat * amount, child: child),
  );
}

/// Mute button and a level slider for the desktop bar.
class _VolumeControl extends ConsumerWidget {
  const _VolumeControl();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final volume = ref.watch(volumeProvider);
    final volumes = ref.read(volumeProvider.notifier);
    final icon = volume == 0
        ? Icons.volume_off_rounded
        : volume < 0.5
        ? Icons.volume_down_rounded
        : Icons.volume_up_rounded;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: volume == 0 ? 'Activar sonido' : 'Silenciar',
          visualDensity: VisualDensity.compact,
          icon: Icon(icon, size: 18, color: c.muted),
          onPressed: volumes.toggleMute,
        ),
        SizedBox(
          width: 110,
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              activeTrackColor: c.fg,
              inactiveTrackColor: c.fgSoft2,
              thumbColor: c.fg,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
            ),
            child: Slider(
              value: volume,
              semanticFormatterCallback: (v) => '${(v * 100).round()} %',
              onChanged: volumes.set,
            ),
          ),
        ),
      ],
    );
  }
}
