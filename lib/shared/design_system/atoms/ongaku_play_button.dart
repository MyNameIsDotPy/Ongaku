import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/ongaku_motion_settings.dart';
import '../tokens/tokens.dart';
import 'ongaku_spinner.dart';

enum OngakuPlayButtonStyle {
  /// Accent fill with a colored glow (album, playlist and artist actions).
  accent,

  /// Ink fill (desktop player bar).
  ink,

  /// Light disc on dark (immersive player).
  light,

  /// Bare glyph (mobile mini-player).
  bare,
}

/// Play ↔ pause that melts between shapes; shows a spinner while loading or
/// buffering. In the immersive player it wobbles like a drop while playing.
class OngakuPlayButton extends StatefulWidget {
  const OngakuPlayButton({
    super.key,
    required this.playing,
    required this.onPressed,
    this.busy = false,
    this.size = 56,
    this.style = OngakuPlayButtonStyle.accent,
    this.blob = false,
    this.pulse = 1,
  });

  final bool playing;
  final bool busy;
  final VoidCallback? onPressed;
  final double size;
  final OngakuPlayButtonStyle style;

  /// Wobbling drop outline while playing.
  final bool blob;

  /// Beat-driven scale (1 = rest).
  final double pulse;

  @override
  State<OngakuPlayButton> createState() => _OngakuPlayButtonState();
}

class _OngakuPlayButtonState extends State<OngakuPlayButton>
    with TickerProviderStateMixin {
  late final AnimationController _morph;
  late final AnimationController _wobble;

  @override
  void initState() {
    super.initState();
    _morph = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      value: widget.playing ? 1 : 0,
    );
    _wobble = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5500),
    );
  }

  bool _pressed = false;
  bool _hover = false;

  @override
  void didUpdateWidget(OngakuPlayButton old) {
    super.didUpdateWidget(old);
    if (old.playing != widget.playing) {
      widget.playing ? _morph.forward() : _morph.reverse();
    }
  }

  @override
  void dispose() {
    _morph.dispose();
    _wobble.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final reduced = OngakuMotionSettings.reducedOf(context);
    if (reduced) _morph.value = widget.playing ? 1 : 0;
    final wobbling = widget.blob && widget.playing && !reduced;
    if (wobbling && !_wobble.isAnimating) {
      _wobble.repeat();
    } else if (!wobbling && _wobble.isAnimating) {
      _wobble.stop();
    }

    final (Color bg, Color fg) = switch (widget.style) {
      OngakuPlayButtonStyle.accent => (
        _hover ? Color.lerp(c.accent, Colors.black, 0.14)! : c.accent,
        c.onAccent,
      ),
      OngakuPlayButtonStyle.ink => (
        _hover ? Color.lerp(c.fg, c.bg, 0.18)! : c.fg,
        c.bg,
      ),
      OngakuPlayButtonStyle.light => (
        _hover ? const Color(0xFFD5D8DB) : c.fg,
        const Color(0xFF06090D),
      ),
      OngakuPlayButtonStyle.bare => (Colors.transparent, c.fg),
    };
    final glyph =
        widget.size * (widget.style == OngakuPlayButtonStyle.bare ? 0.5 : 0.39);

    Widget icon = widget.busy
        ? OngakuSpinner(size: glyph * 0.85, color: fg)
        : AnimatedBuilder(
            animation: _morph,
            builder: (_, _) => CustomPaint(
              size: Size.square(glyph),
              painter: _PlayPausePainter(
                OngakuMotion.ease.transform(_morph.value),
                fg,
              ),
            ),
          );

    final scale =
        (_pressed ? 0.92 : (_hover ? 1.04 : 1.0)) *
        (1 + (widget.pulse - 1) * 0.5);

    return Semantics(
      button: true,
      label: widget.playing ? 'Pausar' : 'Reproducir',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 220),
            curve: OngakuMotion.spring,
            child: AnimatedBuilder(
              animation: _wobble,
              builder: (_, child) => Container(
                width: widget.size,
                height: widget.size,
                decoration: ShapeDecoration(
                  color: bg,
                  shape: wobbling
                      ? _blobShape(_wobble.value)
                      : const CircleBorder(),
                  shadows: widget.style == OngakuPlayButtonStyle.accent
                      ? [
                          BoxShadow(
                            color: c.accent.withValues(alpha: 0.55),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                            spreadRadius: -10,
                          ),
                        ]
                      : null,
                ),
                child: child,
              ),
              child: Center(child: icon),
            ),
          ),
        ),
      ),
    );
  }

  /// Keyframes of the CSS `blob` animation, interpolated.
  ShapeBorder _blobShape(double t) {
    const frames = [
      [50.0, 50, 50, 50, 50, 50, 50, 50],
      [58.0, 42, 53, 47, 46, 56, 44, 54],
      [45.0, 55, 41, 59, 56, 44, 58, 42],
      [53.0, 47, 60, 40, 47, 58, 42, 53],
      [50.0, 50, 50, 50, 50, 50, 50, 50],
    ];
    final x = t * 4;
    final i = x.floor().clamp(0, 3);
    final f = Curves.easeInOut.transform(x - i);
    double v(int k) =>
        (frames[i][k] + (frames[i + 1][k] - frames[i][k]) * f) / 100;
    final s = widget.size;
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.elliptical(s * v(0), s * v(4)),
        topRight: Radius.elliptical(s * v(1), s * v(5)),
        bottomRight: Radius.elliptical(s * v(2), s * v(6)),
        bottomLeft: Radius.elliptical(s * v(3), s * v(7)),
      ),
    );
  }
}

/// Two quads that morph from the play triangle (split in halves) into the
/// two pause bars — the CSS `d: path(...)` morph from the prototype.
class _PlayPausePainter extends CustomPainter {
  _PlayPausePainter(this.t, this.color);

  final double t;
  final Color color;

  static const _playA = [
    Offset(7, 4.8), Offset(13, 8.4), Offset(13, 15.6), Offset(7, 19.2), //
  ];
  static const _playB = [
    Offset(13, 8.4), Offset(20, 12), Offset(20, 12), Offset(13, 15.6), //
  ];
  static const _pauseA = [
    Offset(6, 4.5), Offset(10.5, 4.5), Offset(10.5, 19.5), Offset(6, 19.5), //
  ];
  static const _pauseB = [
    Offset(13.5, 4.5), Offset(18, 4.5), Offset(18, 19.5), Offset(13.5, 19.5), //
  ];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeJoin = StrokeJoin.round;
    for (final (a, b) in [(_playA, _pauseA), (_playB, _pauseB)]) {
      final path = Path();
      for (var i = 0; i < 4; i++) {
        final p = Offset.lerp(a[i], b[i], t)!;
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      path.close();
      canvas
        ..drawPath(path, paint)
        ..drawPath(path, stroke);
    }
  }

  @override
  bool shouldRepaint(_PlayPausePainter old) => old.t != t || old.color != color;
}

/// Utility for the reactive pulse: `exp(-dt * 7)` decay after each beat.
double beatEnvelope(Duration position, Duration beat) {
  if (beat == Duration.zero) return 0;
  final since = position.inMicroseconds % beat.inMicroseconds;
  return math.exp(-since / 1e6 * 7);
}
