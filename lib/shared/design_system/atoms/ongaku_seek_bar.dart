import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../theme/ongaku_motion_settings.dart';
import '../tokens/tokens.dart';

String formatDuration(Duration d) {
  final s = math.max(0, d.inSeconds);
  return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}

/// Progress bar with seek (RF-10). The played part is a wave that grows with
/// [energy] while playing and flattens smoothly when paused or dragging.
class OngakuSeekBar extends StatefulWidget {
  const OngakuSeekBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
    this.playing = false,
    this.energy = 0,
    this.large = false,
    this.showTimes = true,
  });

  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;
  final bool playing;

  /// 0–1 loudness used for the wave amplitude.
  final double energy;

  /// Immersive player variant: taller track, bar-shaped knob.
  final bool large;
  final bool showTimes;

  @override
  State<OngakuSeekBar> createState() => _OngakuSeekBarState();
}

class _OngakuSeekBarState extends State<OngakuSeekBar>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _phase = 0;
  double _amp = 0;
  Duration _last = Duration.zero;
  double? _drag;
  bool _hover = false;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    final reduced = OngakuMotionSettings.reducedOf(context);
    final target = widget.playing && _drag == null && !reduced
        ? (widget.large ? 2.2 + widget.energy * 4 : 1.4 + widget.energy * 2.4)
        : 0.0;
    final nextAmp = _amp + (target - _amp) * math.min(1, dt * 6);
    final moving = nextAmp > 0.01 || (_amp - nextAmp).abs() > 0.001;
    if (moving) {
      setState(() {
        _amp = nextAmp;
        _phase += dt * 5;
      });
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  double get _fraction {
    final d = widget.duration.inMilliseconds;
    if (d <= 0) return 0;
    return _drag ??
        (widget.position.inMilliseconds / d).clamp(0.0, 1.0).toDouble();
  }

  Duration _at(double f) =>
      Duration(milliseconds: (widget.duration.inMilliseconds * f).round());

  void _update(Offset local, double width) =>
      setState(() => _drag = (local.dx / width).clamp(0.0, 1.0));

  void _commit() {
    if (_drag != null) widget.onSeek(_at(_drag!));
    setState(() => _drag = null);
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent e) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (e.logicalKey == LogicalKeyboardKey.arrowRight) {
      widget.onSeek(widget.position + const Duration(seconds: 5));
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.arrowLeft) {
      widget.onSeek(widget.position - const Duration(seconds: 5));
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final shown = _drag != null ? _at(_drag!) : widget.position;
    final timeStyle = OngakuTypography.mono(context, size: 12, color: c.muted);
    final bar = LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        return Focus(
          onKeyEvent: _onKey,
          onFocusChange: (f) => setState(() => _focused = f),
          child: Semantics(
            slider: true,
            label: 'Progreso',
            value:
                '${formatDuration(shown)} de ${formatDuration(widget.duration)}',
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => _hover = true),
              onExit: (_) => setState(() => _hover = false),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: (d) => _update(d.localPosition, w),
                onHorizontalDragUpdate: (d) => _update(d.localPosition, w),
                onHorizontalDragEnd: (_) => _commit(),
                onTapDown: (d) => _update(d.localPosition, w),
                onTapUp: (_) => _commit(),
                child: SizedBox(
                  height: widget.large ? 22 : 16,
                  width: w,
                  child: CustomPaint(
                    painter: _WavePainter(
                      fraction: _fraction,
                      amplitude: _amp,
                      phase: _phase,
                      color: c.fg,
                      rail: widget.large ? const Color(0x2EFFFFFF) : c.fgSoft2,
                      thick: widget.large ? 4 : 3.2,
                      railHeight: (_hover || _drag != null) && !widget.large
                          ? 6
                          : 4,
                      knob: widget.large
                          ? _Knob.bar
                          : (_hover || _drag != null || _focused)
                          ? _Knob.dot
                          : _Knob.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    if (!widget.showTimes) return bar;
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            formatDuration(shown),
            textAlign: TextAlign.right,
            style: timeStyle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: bar),
        const SizedBox(width: 10),
        SizedBox(
          width: 40,
          child: Text(formatDuration(widget.duration), style: timeStyle),
        ),
      ],
    );
  }
}

enum _Knob { none, dot, bar }

class _WavePainter extends CustomPainter {
  _WavePainter({
    required this.fraction,
    required this.amplitude,
    required this.phase,
    required this.color,
    required this.rail,
    required this.thick,
    required this.railHeight,
    required this.knob,
  });

  final double fraction;
  final double amplitude;
  final double phase;
  final Color color;
  final Color rail;
  final double thick;
  final double railHeight;
  final _Knob knob;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final x = size.width * fraction;
    // Unplayed rail, starting just after the played wave.
    final railStart = math.min(size.width, x + (amplitude > 0.05 ? 7 : 0));
    if (railStart < size.width) {
      canvas.drawRRect(
        RRect.fromLTRBR(
          railStart,
          cy - railHeight / 2,
          size.width,
          cy + railHeight / 2,
          Radius.circular(railHeight),
        ),
        Paint()..color = rail,
      );
    }
    if (amplitude <= 0.05 && railStart > 0) {
      // Flat: draw the played portion as a filled rail.
      canvas.drawRRect(
        RRect.fromLTRBR(
          0,
          cy - railHeight / 2,
          x,
          cy + railHeight / 2,
          Radius.circular(railHeight),
        ),
        Paint()..color = color,
      );
    } else if (x > 0) {
      final path = Path()..moveTo(0, cy);
      for (double px = 0; px <= x; px += 1.5) {
        // Taper the ends so the wave meets the rail and knob cleanly.
        final taper = math.min(1.0, math.min(px, x - px) / 10);
        path.lineTo(
          px,
          cy + math.sin(px / 18 * 2 * math.pi - phase) * amplitude * taper,
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = thick
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
    switch (knob) {
      case _Knob.dot:
        canvas.drawCircle(Offset(x, cy), 6, Paint()..color = color);
      case _Knob.bar:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(x, cy), width: 6, height: 20),
            const Radius.circular(3),
          ),
          Paint()..color = color,
        );
      case _Knob.none:
        break;
    }
  }

  @override
  bool shouldRepaint(_WavePainter o) =>
      o.fraction != fraction ||
      o.amplitude != amplitude ||
      o.phase != phase ||
      o.color != color ||
      o.railHeight != railHeight ||
      o.knob != knob;
}
