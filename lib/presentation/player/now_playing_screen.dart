import 'dart:math' as math;
import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../models/player_snapshot.dart';
import '../../models/track.dart';
import '../../providers/library_providers.dart';
import '../../providers/player_providers.dart';
import '../../providers/ui_providers.dart';
import '../../shared/design_system/design_system.dart';
import '../common/cover_palette.dart';
import '../common/track_actions.dart';
import '../queue/queue_view.dart';
import '../shell/player_bar.dart';
import 'beat_builder.dart';
import 'lyrics_view.dart';

/// Reproductor (RF-07–18, RF-30): an immersive sheet with a liquid aura
/// tinted by the cover that breathes with the audio. On PC lyrics or queue
/// open beside the cover; on phones a segmented control switches between
/// Portada, Letra and Cola. Swipe down (or Esc) to close.
class NowPlayingScreen extends ConsumerStatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen> {
  double _drag = 0;

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.home);
    }
  }

  /// Header that closes the sheet when dragged down.
  Widget _header(Track track) => GestureDetector(
    behavior: HitTestBehavior.translucent,
    onVerticalDragUpdate: (d) =>
        setState(() => _drag = math.max(0, _drag + d.delta.dy)),
    onVerticalDragEnd: (_) {
      if (_drag > 110) {
        _close();
      } else {
        setState(() => _drag = 0);
      }
    },
    child: _Header(onClose: _close, track: track),
  );

  @override
  Widget build(BuildContext context) {
    final track = ref.watch(currentTrackProvider);
    if (track == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _close();
      });
      return const SizedBox.shrink();
    }
    final player = ref.read(playerProvider.notifier);
    return Theme(
      data: OngakuTheme.nowPlaying(),
      child: Builder(
        builder: (context) {
          return CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.escape): _close,
              const SingleActivator(LogicalKeyboardKey.space): player.toggle,
              const SingleActivator(
                LogicalKeyboardKey.arrowRight,
                control: true,
              ): player.next,
              const SingleActivator(
                LogicalKeyboardKey.arrowLeft,
                control: true,
              ): player.previous,
              const SingleActivator(
                LogicalKeyboardKey.keyL,
                control: true,
              ): () =>
                  ref.toggleFavorite(context, track),
            },
            child: Focus(
              autofocus: true,
              child: Transform.translate(
                offset: Offset(0, _drag),
                child: Scaffold(
                  backgroundColor: context.colors.bg,
                  body: Stack(
                    fit: StackFit.expand,
                    children: [
                      _Aura(track: track),
                      SafeArea(
                        child: Padding(
                          padding: _contentPadding(context),
                          child: OngakuBreakpoints.isLandscapePhone(context)
                              ? _LandscapeBody(
                                  track: track,
                                  header: _header(track),
                                )
                              : Column(
                                  children: [
                                    _header(track),
                                    if (OngakuBreakpoints.isCompact(context))
                                      const _ModeTabs(),
                                    Expanded(child: _Stage(track: track)),
                                    _Controls(track: track),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  EdgeInsets _contentPadding(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    if (OngakuBreakpoints.isCompact(context)) {
      return const EdgeInsets.fromLTRB(16, 8, 16, 20);
    }
    final h = (size.width * 0.03).clamp(16.0, 40.0);
    final b = (size.height * 0.03).clamp(16.0, 32.0);
    return EdgeInsets.fromLTRB(h, 12, h, b);
  }
}

class _Aura extends StatefulWidget {
  const _Aura({required this.track});
  final Track track;

  @override
  State<_Aura> createState() => _AuraState();
}

class _AuraState extends State<_Aura> with SingleTickerProviderStateMixin {
  // Shockwave from the cover when the track changes (3 s, as in the design).
  late final _ripple = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  );

  @override
  void didUpdateWidget(_Aura old) {
    super.didUpdateWidget(old);
    if (old.track.videoId != widget.track.videoId &&
        !OngakuMotionSettings.reducedOf(context)) {
      _ripple.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ripple.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: BeatBuilder(
        track: widget.track,
        alwaysTick: true,
        builder: (context, l, _) => Consumer(
          builder: (context, ref, _) {
            final palette = ref.watch(trackPaletteProvider(widget.track));
            return AnimatedBuilder(
              animation: _ripple,
              builder: (_, _) => LiquidAura(
                palette: palette,
                time: l.time,
                energy: l.energy,
                beat: l.beat,
                ripple: _ripple.isAnimating ? _ripple.value : null,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.onClose, required this.track});

  final VoidCallback onClose;
  final Track track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final from = ref.watch(playerProvider.select((s) => s.sourceLabel));
    return Row(
      children: [
        OngakuIconButton(
          icon: OngakuIcons.down,
          tooltip: 'Cerrar reproductor',
          onPressed: onClose,
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                'REPRODUCIENDO DESDE',
                style: OngakuTypography.eyebrow(context),
              ),
              const SizedBox(height: 4),
              Text(
                from,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Builder(
          builder: (anchor) => OngakuIconButton(
            icon: OngakuIcons.more,
            tooltip: 'Más opciones',
            onPressed: () => _menu(anchor, ref),
          ),
        ),
      ],
    );
  }

  Future<void> _menu(BuildContext anchor, WidgetRef ref) async {
    final k = await showOngakuMenu<String>(anchor, [
      const OngakuMenuItem('radio', OngakuIcons.radio, 'Iniciar radio'),
      const OngakuMenuItem('pl', OngakuIcons.library, 'Agregar a playlist…'),
      if (track.album != null)
        const OngakuMenuItem('album', OngakuIcons.album, 'Ir al álbum'),
      const OngakuMenuItem('artist', OngakuIcons.user, 'Ir al artista'),
      null,
      const OngakuMenuItem(
        'timer',
        OngakuIcons.timer,
        'Temporizador de apagado',
      ),
    ]);
    if (!anchor.mounted) return;
    switch (k) {
      case 'radio':
        await ref.startRadio(anchor, track);
      case 'pl':
        await ref.addToPlaylist(anchor, track);
      case 'album':
        onClose();
        anchor.go(Routes.album(track.album!.id));
      case 'artist':
        onClose();
        anchor.go(Routes.artist(track.primaryArtist.id));
      case 'timer':
        await showSleepTimerMenu(anchor, ref);
    }
  }
}

/// RF-17: minutes or at the end of the song.
Future<void> showSleepTimerMenu(BuildContext anchor, WidgetRef ref) async {
  final k = await showOngakuMenu<String>(anchor, [
    const OngakuMenuItem('15', OngakuIcons.timer, '15 minutos'),
    const OngakuMenuItem('30', OngakuIcons.timer, '30 minutos'),
    const OngakuMenuItem('45', OngakuIcons.timer, '45 minutos'),
    const OngakuMenuItem('60', OngakuIcons.timer, '1 hora'),
    const OngakuMenuItem('end', OngakuIcons.check, 'Al terminar la canción'),
    null,
    const OngakuMenuItem('off', OngakuIcons.close, 'Desactivar'),
  ], title: 'Temporizador de apagado');
  if (k == null || !anchor.mounted) return;
  final player = ref.read(playerProvider.notifier);
  switch (k) {
    case 'off':
      player.setSleepTimer(null);
      showOngakuToast(anchor, 'Temporizador desactivado');
    case 'end':
      player.setSleepTimer(const SleepTimer.endOfTrack());
      showOngakuToast(anchor, 'Se pausará al terminar esta canción');
    default:
      player.setSleepTimer(SleepTimer.minutes(int.parse(k)));
      showOngakuToast(anchor, 'Se pausará en $k minutos');
  }
}

/// Phone turned sideways: the cover and its title on the left; header,
/// mode tabs, the lyrics or queue panel and the controls on the right.
class _LandscapeBody extends ConsumerWidget {
  const _LandscapeBody({required this.track, required this.header});

  final Track track;
  final Widget header;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(nowPlayingModeProvider);
    final side = switch (mode) {
      NowPlayingMode.lyrics => LyricsView(
        key: const ValueKey('lyrics'),
        track: track,
      ),
      NowPlayingMode.queue => const QueueView(
        key: ValueKey('queue'),
        onDark: true,
      ),
      NowPlayingMode.cover => const SizedBox.shrink(key: ValueKey('none')),
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 3,
          child: LayoutBuilder(
            builder: (context, box) {
              // The cover plus its title and artist below it.
              final cover = math
                  .min(box.maxHeight - 90, box.maxWidth - 16)
                  .clamp(120.0, 520.0);
              return Center(
                child: _ArtColumn(track: track, size: cover),
              );
            },
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 6,
          child: Column(
            children: [
              header,
              const _ModeTabs(),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: side,
                ),
              ),
              _Controls(track: track),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModeTabs extends ConsumerWidget {
  const _ModeTabs();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
    padding: const EdgeInsets.only(top: 4, bottom: 8),
    child: OngakuSegmented<NowPlayingMode>(
      onDark: true,
      semanticLabel: 'Vista',
      options: const [
        (NowPlayingMode.cover, 'Portada'),
        (NowPlayingMode.lyrics, 'Letra'),
        (NowPlayingMode.queue, 'Cola'),
      ],
      value: ref.watch(nowPlayingModeProvider),
      onChanged: ref.read(nowPlayingModeProvider.notifier).set,
    ),
  );
}

class _Stage extends ConsumerWidget {
  const _Stage({required this.track});

  final Track track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(nowPlayingModeProvider);
    final open = mode != NowPlayingMode.cover;
    final compact = OngakuBreakpoints.isCompact(context);
    final side = switch (mode) {
      NowPlayingMode.lyrics => LyricsView(
        key: const ValueKey('lyrics'),
        track: track,
      ),
      NowPlayingMode.queue => const QueueView(
        key: ValueKey('queue'),
        onDark: true,
      ),
      NowPlayingMode.cover => const SizedBox.shrink(key: ValueKey('none')),
    };
    final switcher = AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: side,
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(end: open ? 1 : 0),
      duration: OngakuMotion.sheet,
      curve: OngakuMotion.ease,
      builder: (context, t, _) => LayoutBuilder(
        builder: (context, box) {
          final size = MediaQuery.sizeOf(context);
          if (compact) {
            final cover = math.min(size.width * 0.82, size.height * 0.46);
            return Stack(
              children: [
                IgnorePointer(
                  ignoring: open,
                  child: Opacity(
                    opacity: 1 - t,
                    child: Transform.scale(
                      scale: 1 - 0.08 * t,
                      child: Center(
                        child: _ArtColumn(track: track, size: cover),
                      ),
                    ),
                  ),
                ),
                if (t > 0)
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: !open,
                      child: Opacity(opacity: t, child: switcher),
                    ),
                  ),
              ],
            );
          }
          final full = (math.min(
            size.height * 0.52,
            size.width * 0.38,
          )).clamp(220.0, 520.0);
          final small = (math.min(
            size.height * 0.44,
            size.width * 0.28,
          )).clamp(200.0, 420.0);
          final cover = math.min(
            lerpDouble(full, small, t)!,
            box.maxHeight - 110,
          );
          final gap = lerpDouble(0, (size.width * 0.05).clamp(24, 80), t)!;
          final artWidth = lerpDouble(
            box.maxWidth,
            (box.maxWidth - gap) * 0.45,
            t,
          )!;
          return Row(
            children: [
              SizedBox(
                width: artWidth,
                child: Align(
                  alignment: Alignment.lerp(
                    Alignment.center,
                    Alignment.centerRight,
                    t,
                  )!,
                  child: _ArtColumn(track: track, size: cover),
                ),
              ),
              SizedBox(width: gap),
              if (t > 0.01)
                Expanded(
                  child: Opacity(
                    opacity: Curves.easeIn.transform(t),
                    child: Transform.translate(
                      offset: Offset(24 * (1 - t), 0),
                      child: switcher,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ArtColumn extends ConsumerWidget {
  const _ArtColumn({required this.track, required this.size});

  final Track track;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final fav = ref.watch(isFavoriteProvider(track.videoId));
    final glow =
        ref.watch(trackPaletteProvider(track)).firstOrNull ??
        const Color(0xFF5A6EA0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BeatBuilder(
          track: track,
          builder: (context, l, child) => Transform.scale(
            scale: 1 + l.beat * 0.03 + l.energy * 0.02,
            child: child,
          ),
          child: Hero(
            tag: nowPlayingCoverHero,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: OngakuRadii.xlAll,
                boxShadow: [
                  BoxShadow(
                    color: glow.withValues(alpha: 0.9),
                    blurRadius: 120,
                    offset: const Offset(0, 40),
                    spreadRadius: -30,
                  ),
                ],
              ),
              child: _LiquidCover(track: track),
            ),
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: size,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: (MediaQuery.sizeOf(context).width * 0.024)
                            .clamp(22, 30),
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -0.5,
                        color: c.fg,
                      ),
                    ),
                    QuietLink(
                      track.artistNames,
                      onTap: () {
                        context.pop();
                        context.go(Routes.artist(track.primaryArtist.id));
                      },
                    ),
                  ],
                ),
              ),
              OngakuIconButton(
                icon: OngakuIcons.heart,
                solid: fav,
                active: fav,
                activeStyle: OngakuActiveStyle.wash,
                tooltip: fav ? 'Quitar de favoritos' : 'Agregar a favoritos',
                onPressed: () => ref.toggleFavorite(context, track),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The outgoing cover liquefies (blur + wobble), swaps at the peak and
/// settles back in 800 ms.
class _LiquidCover extends StatelessWidget {
  const _LiquidCover({required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
    final reduced = OngakuMotionSettings.reducedOf(context);
    final cover = OngakuCover.single(
      track.coverUrl,
      key: ValueKey(track.coverUrl),
      radius: OngakuRadii.xl,
      semanticLabel: 'Portada de ${track.album?.name ?? track.title}',
    );
    if (reduced) return cover;
    return AnimatedSwitcher(
      duration: OngakuMotion.coverSwap,
      switchInCurve: const Interval(0.35, 1, curve: OngakuMotion.ease),
      switchOutCurve: const Interval(0, 0.35, curve: Curves.easeIn),
      transitionBuilder: (child, a) => AnimatedBuilder(
        animation: a,
        child: child,
        builder: (_, child) {
          final k = 1 - a.value;
          return Opacity(
            opacity: a.value.clamp(0, 1),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: k * 14, sigmaY: k * 14),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..scaleByDouble(1 + k * 0.06, 1 - k * 0.04, 1, 1)
                  ..rotateZ(k * 0.03),
                child: child,
              ),
            ),
          );
        },
      ),
      child: cover,
    );
  }
}

class _Controls extends ConsumerWidget {
  const _Controls({required this.track});

  final Track track;

  static const _notes = {
    PlaybackStatus.buffering: 'Almacenando en búfer…',
    PlaybackStatus.completed: 'Terminó la cola',
    PlaybackStatus.idle: 'Toca reproducir para continuar donde ibas',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(playerProvider);
    final player = ref.read(playerProvider.notifier);
    final mode = ref.watch(nowPlayingModeProvider);
    final modes = ref.read(nowPlayingModeProvider.notifier);
    // Landscape phones are wider than the compact breakpoint: keep the
    // compact row, which fits. Letra, Cola and the timer stay in the tabs and
    // the "..." menu.
    final compact =
        OngakuBreakpoints.isCompact(context) ||
        OngakuBreakpoints.isLandscapePhone(context);
    final c = context.colors;
    final note = s.status == PlaybackStatus.error
        ? s.error?.message ?? s.error?.code.description ?? ''
        : _notes[s.status] ?? '';
    final sleepLabel = switch (s.sleep) {
      SleepAfterMinutes(:final minutes) => 'Temporizador: $minutes min',
      SleepAtEndOfTrack() => 'Temporizador: al terminar la canción',
      null => 'Temporizador de apagado',
    };
    final mainSize = compact
        ? OngakuIconButtonSize.regular
        : OngakuIconButtonSize.large;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            liveRegion: true,
            child: SizedBox(
              height: 20,
              child: Text(
                note,
                style: TextStyle(
                  fontSize: 13,
                  color: s.status == PlaybackStatus.error ? c.err : c.muted,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          BeatBuilder(
            track: track,
            builder: (_, l, _) => PlayerSeekBar(large: true, energy: l.energy),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: compact
                    ? const SizedBox.shrink()
                    : Row(
                        children: [
                          OngakuIconButton(
                            icon: OngakuIcons.lyrics,
                            tooltip: 'Letra',
                            active: mode == NowPlayingMode.lyrics,
                            activeStyle: OngakuActiveStyle.wash,
                            onPressed: () =>
                                modes.toggle(NowPlayingMode.lyrics),
                          ),
                          OngakuIconButton(
                            icon: OngakuIcons.queue,
                            tooltip: 'Cola',
                            active: mode == NowPlayingMode.queue,
                            activeStyle: OngakuActiveStyle.wash,
                            onPressed: () => modes.toggle(NowPlayingMode.queue),
                          ),
                        ],
                      ),
              ),
              OngakuIconButton(
                icon: OngakuIcons.shuffle,
                size: mainSize,
                tooltip: 'Aleatorio',
                active: s.shuffle,
                activeStyle: OngakuActiveStyle.wash,
                onPressed: player.toggleShuffle,
              ),
              SizedBox(width: compact ? 4 : 18),
              OngakuIconButton(
                icon: OngakuIcons.prev,
                size: mainSize,
                tooltip: 'Anterior',
                onPressed: player.previous,
              ),
              SizedBox(width: compact ? 4 : 18),
              BeatBuilder(
                track: track,
                builder: (_, l, _) => OngakuPlayButton(
                  playing: s.isPlaying,
                  busy: s.isBusy,
                  size: compact ? 68 : 72,
                  style: OngakuPlayButtonStyle.light,
                  blob: true,
                  pulse: 1 + l.beat * 0.03 + l.energy * 0.02,
                  onPressed: player.toggle,
                ),
              ),
              SizedBox(width: compact ? 4 : 18),
              OngakuIconButton(
                icon: OngakuIcons.next,
                size: mainSize,
                tooltip: 'Siguiente',
                onPressed: player.next,
              ),
              SizedBox(width: compact ? 4 : 18),
              OngakuIconButton(
                icon: s.repeat == QueueRepeat.one
                    ? OngakuIcons.repeatOne
                    : OngakuIcons.repeat,
                size: mainSize,
                tooltip: s.repeat.label,
                active: s.repeat != QueueRepeat.off,
                activeStyle: OngakuActiveStyle.wash,
                onPressed: player.cycleRepeat,
              ),
              Expanded(
                child: compact
                    ? const SizedBox.shrink()
                    : Align(
                        alignment: Alignment.centerRight,
                        child: Builder(
                          builder: (anchor) => OngakuIconButton(
                            icon: OngakuIcons.timer,
                            tooltip: sleepLabel,
                            active: s.sleep != null,
                            activeStyle: OngakuActiveStyle.wash,
                            onPressed: () => showSleepTimerMenu(anchor, ref),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
