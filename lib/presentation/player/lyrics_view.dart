import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/lyrics.dart';
import '../../models/track.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/player_providers.dart';
import '../../shared/design_system/design_system.dart';
import 'beat_builder.dart';

/// Synced lyrics (RF-30, extended per the design notes): the active line
/// grows to full size and fills word by word; past lines stay at 50 %, far
/// ones blur. Scrolling follows the song and pauses 3 s after manual scroll.
/// Instrumental gaps show three dots that pulse with the kick.
class LyricsView extends ConsumerStatefulWidget {
  const LyricsView({super.key, required this.track});

  final Track track;

  @override
  ConsumerState<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends ConsumerState<LyricsView> {
  final _scroll = ScrollController();
  final _keys = <int, GlobalKey>{};
  int _active = -1;
  DateTime _manualUntil = DateTime.fromMillisecondsSinceEpoch(0);
  bool _static = false;

  @override
  void didUpdateWidget(LyricsView old) {
    super.didUpdateWidget(old);
    if (old.track.videoId != widget.track.videoId) {
      _active = -1;
      _keys.clear();
      if (_scroll.hasClients) _scroll.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _follow(int index) {
    if (index == _active) return;
    _active = index;
    if (DateTime.now().isBefore(_manualUntil)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _keys[index]?.currentContext;
      if (ctx == null || !mounted) return;
      final reduced = OngakuMotionSettings.reducedOf(context);
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.34,
        duration: reduced ? Duration.zero : OngakuMotion.sheet,
        curve: OngakuMotion.ease,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final lyrics = ref.watch(lyricsProvider(widget.track.videoId));
    return switch (lyrics) {
      AsyncData(value: final Lyrics l) => Stack(
        children: [
          ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (r) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x00000000),
                Color(0xFF000000),
                Color(0xFF000000),
                Color(0x00000000),
              ],
              stops: [0, 0.18, 0.72, 1],
            ).createShader(r),
            child: NotificationListener<UserScrollNotification>(
              onNotification: (n) {
                if (n.direction != ScrollDirection.idle) {
                  _manualUntil = DateTime.now().add(const Duration(seconds: 3));
                }
                return false;
              },
              child: BeatBuilder(
                track: widget.track,
                alwaysTick: true,
                builder: (context, levels, _) {
                  final pos = levels.position == Duration.zero
                      ? ref.watch(positionProvider).value ?? Duration.zero
                      : levels.position;
                  final idx = _static || !l.synced
                      ? -1
                      : _indexAt(l.lines, pos);
                  if (idx >= 0) _follow(idx);
                  return ListView.builder(
                    controller: _scroll,
                    padding: EdgeInsets.only(
                      top: 48,
                      bottom: MediaQuery.sizeOf(context).height * 0.4,
                      right: 8,
                    ),
                    itemCount: l.lines.length,
                    itemBuilder: (context, i) => KeyedSubtree(
                      key: _keys.putIfAbsent(i, GlobalKey.new),
                      child: _Line(
                        line: l.lines[i],
                        state: idx < 0
                            ? _LineState.plain
                            : i == idx
                            ? _LineState.active
                            : i < idx
                            ? _LineState.past
                            : _LineState.next,
                        far: idx >= 0 && (i - idx).abs() > 2,
                        progress: i == idx ? _progress(l.lines[i], pos) : 0,
                        beat: levels.beat,
                        static: _static || !l.synced,
                        onTap: _static || !l.synced
                            ? null
                            : () {
                                _manualUntil =
                                    DateTime.fromMillisecondsSinceEpoch(0);
                                ref
                                    .read(playerProvider.notifier)
                                    .seek(l.lines[i].start);
                              },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Row(
              children: [
                Tooltip(
                  message: 'Alternar letra sincronizada o estática',
                  child: OngakuPressable(
                    onTap: l.synced
                        ? () => setState(() => _static = !_static)
                        : null,
                    borderRadius: OngakuRadii.pillAll,
                    child: OngakuTag(
                      _static || !l.synced ? 'Estática' : 'Sincronizada',
                      background: const Color(0x590A0A0A),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const OngakuTag(
                  'Letra de muestra',
                  background: Color(0x590A0A0A),
                ),
              ],
            ),
          ),
        ],
      ),
      AsyncData() => Center(
        child: Text(
          'Esta canción no tiene letra.',
          style: TextStyle(color: c.muted, fontSize: 16),
        ),
      ),
      AsyncError() => Center(
        child: Text(
          'No se pudo cargar la letra.',
          style: TextStyle(color: c.muted, fontSize: 16),
        ),
      ),
      _ => Center(child: OngakuSpinner(color: c.muted)),
    };
  }

  static int _indexAt(List<LyricLine> lines, Duration pos) {
    for (var i = lines.length - 1; i >= 0; i--) {
      if (pos >= lines[i].start) return i;
    }
    return 0;
  }

  static double _progress(LyricLine l, Duration pos) {
    final span = (l.end - l.start).inMilliseconds;
    if (span <= 0) return 1;
    return ((pos - l.start).inMilliseconds / span).clamp(0.0, 1.0);
  }
}

enum _LineState { plain, active, past, next }

class _Line extends StatelessWidget {
  const _Line({
    required this.line,
    required this.state,
    required this.far,
    required this.progress,
    required this.beat,
    required this.static,
    required this.onTap,
  });

  final LyricLine line;
  final _LineState state;
  final bool far;
  final double progress;
  final double beat;
  final bool static;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final compact = OngakuBreakpoints.isCompact(context);
    final width = MediaQuery.sizeOf(context).width;
    final size = static
        ? (width * 0.018).clamp(18.0, 24.0)
        : compact
        ? 26.0
        : (width * 0.027).clamp(22.0, 38.0);
    final active = state == _LineState.active;
    final color = switch (state) {
      _LineState.active => c.fg,
      _LineState.past => Colors.white.withValues(alpha: 0.5),
      _LineState.plain => Colors.white.withValues(alpha: static ? 0.85 : 0.42),
      _LineState.next => Colors.white.withValues(alpha: 0.42),
    };
    final style = TextStyle(
      fontSize: size,
      fontWeight: static ? FontWeight.w600 : FontWeight.w800,
      height: 1.24,
      letterSpacing: -0.02 * size,
      color: color,
    );

    Widget content;
    if (line.instrumental) {
      content = static
          ? const SizedBox(height: 8)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var k = 0; k < 3; k++)
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Transform.scale(
                      scale: active ? 1 + beat * (k == 1 ? 0.9 : 0.5) : 1,
                      child: Text('•', style: style.copyWith(fontSize: 28)),
                    ),
                  ),
              ],
            );
    } else if (active) {
      // Fill the active line from the left as it is sung.
      content = ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (r) => LinearGradient(
          colors: [c.fg, c.fg, Colors.white.withValues(alpha: 0.45)],
          stops: [0, progress, (progress + 0.08).clamp(0, 1)],
        ).createShader(r),
        child: Text(line.text, style: style),
      );
    } else {
      content = Text(line.text, style: style);
    }

    if (!static) {
      content = AnimatedScale(
        scale: active ? 1 : 0.94,
        alignment: Alignment.centerLeft,
        duration: OngakuMotion.sheet,
        curve: OngakuMotion.ease,
        child: content,
      );
      if (far && !OngakuMotionSettings.reducedOf(context)) {
        content = ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 1.2, sigmaY: 1.2),
          child: content,
        );
      }
    }

    return Semantics(
      button: onTap != null,
      label: line.instrumental ? 'Instrumental' : line.text,
      excludeSemantics: true,
      child: OngakuPressable(
        onTap: onTap,
        hoverColor: Colors.transparent,
        borderRadius: OngakuRadii.smAll,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: static ? 4 : 10),
          child: Align(alignment: Alignment.centerLeft, child: content),
        ),
      ),
    );
  }
}
