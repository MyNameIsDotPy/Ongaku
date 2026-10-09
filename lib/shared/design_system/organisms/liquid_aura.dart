import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// The immersive player's backdrop: a slow fluid tinted by the cover's
/// colors. [energy] stirs it; [beat] lights it up on each kick.
class LiquidAura extends StatelessWidget {
  const LiquidAura({
    super.key,
    required this.palette,
    required this.time,
    this.energy = 0,
    this.beat = 0,
    this.ripple,
  });

  final List<Color> palette;

  /// Seconds; advances faster while playing.
  final double time;
  final double energy;
  final double beat;

  /// 0–1 progress of a shockwave after a track change / resume.
  final double? ripple;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: _AuraPainter(palette, time, energy, beat, ripple)),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.2),
              radius: 1.2,
              colors: [Color(0x40020306), Color(0xB8010203)],
            ),
          ),
        ),
      ],
    );
  }
}

/// The fluid is drawn by `shaders/liquid_aura.frag` in a single pass; until
/// it loads (first frame) only the base colour shows.
class _AuraPainter extends CustomPainter {
  _AuraPainter(this.palette, this.t, this.energy, this.beat, this.ripple)
    : super(repaint: _shader);

  final List<Color> palette;
  final double t;
  final double energy;
  final double beat;
  final double? ripple;

  static final _shader = ValueNotifier<ui.FragmentShader?>(null);
  static bool _requested = false;

  /// The shockwave lasts this long, as in the design (3 s).
  static const rippleSeconds = 3.0;

  static void _load() {
    if (_requested) return;
    _requested = true;
    ui.FragmentProgram.fromAsset('shaders/liquid_aura.frag').then(
      (p) => _shader.value = p.fragmentShader(),
      onError: (Object _) => _requested = false,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    _load();
    final colors = palette.isEmpty
        ? const [Color(0xFF5A6EA0), Color(0xFF3C466E), Color(0xFF1E1E28)]
        : palette;
    Color pick(int i) => colors[i.clamp(0, colors.length - 1)];
    final last = pick(2);
    final shader = _shader.value;
    if (shader == null) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..color = Color.from(
            alpha: 1,
            red: last.r * 0.35,
            green: last.g * 0.35,
            blue: last.b * 0.35,
          ),
      );
    } else {
      var i = 0;
      void put(double v) => shader.setFloat(i++, v);
      put(size.width);
      put(size.height);
      put(t);
      put(energy);
      put(beat);
      // Shockwave: centred on the screen, -1 when none is running.
      put(ripple == null ? -1 : ripple! * rippleSeconds);
      put(0);
      put(0);
      for (final c in [pick(0), pick(1), pick(2)]) {
        put(c.r);
        put(c.g);
        put(c.b);
      }
      canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
    }
  }

  @override
  bool shouldRepaint(_AuraPainter o) =>
      o.t != t ||
      o.energy != energy ||
      o.beat != beat ||
      o.ripple != ripple ||
      o.palette != palette;
}
