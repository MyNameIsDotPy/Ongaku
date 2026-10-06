import 'package:flutter/material.dart';

/// `.spin`: a 2 px ring with a gap, rotating every 700 ms.
class OngakuSpinner extends StatefulWidget {
  const OngakuSpinner({super.key, this.size = 18, this.color});

  final double size;
  final Color? color;

  @override
  State<OngakuSpinner> createState() => _OngakuSpinnerState();
}

class _OngakuSpinnerState extends State<OngakuSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? IconTheme.of(context).color!;
    return RotationTransition(
      turns: _c,
      child: SizedBox.square(
        dimension: widget.size,
        child: CustomPaint(painter: _RingPainter(color)),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Offset.zero & size, -1.57, 4.7, false, p);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.color != color;
}
