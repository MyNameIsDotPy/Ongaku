import 'package:flutter/material.dart';

import '../theme/ongaku_motion_settings.dart';
import '../tokens/tokens.dart';

/// Views enter staggered: each section rises 14 px and fades in, 45 ms after
/// the previous one (`@keyframes rise`).
class RiseIn extends StatefulWidget {
  const RiseIn({super.key, required this.child, this.index = 0});

  final Widget child;
  final int index;

  @override
  State<RiseIn> createState() => _RiseInState();
}

class _RiseInState extends State<RiseIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    final delay = OngakuMotion.stagger * widget.index.clamp(0, 8);
    final total = delay + OngakuMotion.rise;
    _c = AnimationController(vsync: this, duration: total)..forward();
    final curve = CurvedAnimation(
      parent: _c,
      curve: Interval(
        delay.inMicroseconds / total.inMicroseconds,
        1,
        curve: OngakuMotion.ease,
      ),
    );
    _fade = curve;
    _slide = Tween(begin: const Offset(0, 14), end: Offset.zero).animate(curve);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (OngakuMotionSettings.reducedOf(context)) return widget.child;
    return FadeTransition(
      opacity: _fade,
      child: AnimatedBuilder(
        animation: _slide,
        child: widget.child,
        builder: (_, child) =>
            Transform.translate(offset: _slide.value, child: child),
      ),
    );
  }
}

/// Wraps each child in a [RiseIn] with increasing delay.
List<Widget> staggered(List<Widget> children) => [
  for (var i = 0; i < children.length; i++)
    RiseIn(index: i, child: children[i]),
];
