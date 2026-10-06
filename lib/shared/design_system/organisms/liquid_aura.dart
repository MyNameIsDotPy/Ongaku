import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The immersive player's backdrop: blobs in the cover's colors drifting on a
/// dark base. [energy] stirs them; [beat] lights them up on each kick.
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

class _AuraPainter extends CustomPainter {
  _AuraPainter(this.palette, this.t, this.energy, this.beat, this.ripple);

  final List<Color> palette;
  final double t;
  final double energy;
  final double beat;
  final double? ripple;

  static const _blobs = [
    (0.0, 0.11, 0.42, 0),
    (1.7, 0.145, 0.52, 1),
    (3.4, 0.18, 0.62, 2),
    (5.1, 0.215, 0.42, 0),
    (6.8, 0.25, 0.52, 1),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final colors = palette.isEmpty
        ? const [Color(0xFF5A6EA0), Color(0xFF3C466E), Color(0xFF1E1E28)]
        : palette;
    final base = colors[colors.length - 1];
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = Color.fromARGB(
          255,
          (base.r * 255 * 0.35).round(),
          (base.g * 255 * 0.35).round(),
          (base.b * 255 * 0.35).round(),
        ),
    );
    final w = size.width, h = size.height;
    for (var i = 0; i < _blobs.length; i++) {
      final (ph, sp, r, ci) = _blobs[i];
      final tt = t * sp;
      final x =
          w * (0.5 + 0.36 * math.sin(tt * 0.9 + ph) * math.cos(tt * 0.37 + i));
      final y = h * (0.5 + 0.34 * math.cos(tt * 0.7 + ph * 1.3));
      final radius = math.max(w, h) * r * (1 + energy * 0.5 + beat * 0.18);
      final c = colors[ci % colors.length];
      final center = Offset(x, y);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..blendMode = BlendMode.screen
          ..shader = RadialGradient(
            colors: [
              c.withValues(alpha: (0.7 + beat * 0.2).clamp(0, 1)),
              c.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }
    if (ripple != null && ripple! < 1) {
      final r = ripple!;
      canvas.drawCircle(
        Offset(w / 2, h * 0.42),
        math.max(w, h) * r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 80 * (1 - r)
          ..color = Colors.white.withValues(alpha: 0.12 * (1 - r))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
      );
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
