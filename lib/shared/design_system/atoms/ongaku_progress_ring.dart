import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

/// Download progress ring shown in place of the download button.
class OngakuProgressRing extends StatelessWidget {
  const OngakuProgressRing({super.key, required this.progress, this.size = 28});

  final double progress;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: 'Descargando',
      value: '${(progress * 100).round()} %',
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: progress),
        duration: const Duration(milliseconds: 300),
        builder: (_, v, _) => CustomPaint(
          size: Size.square(size),
          painter: _RingPainter(v, c.fg, c.fgSoft2),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.v, this.color, this.track);
  final double v;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(3, 3, size.width - 6, size.height - 6);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(r, 0, math.pi * 2, false, p..color = track);
    canvas.drawArc(r, -math.pi / 2, math.pi * 2 * v, false, p..color = color);
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.v != v || o.color != color;
}
