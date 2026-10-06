import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

/// Shimmering placeholder block (`.skel`).
class OngakuSkeleton extends StatefulWidget {
  const OngakuSkeleton({
    super.key,
    this.width,
    this.height = 12,
    this.radius = OngakuRadii.sm,
    this.circle = false,
  });

  final double? width;
  final double height;
  final double radius;
  final bool circle;

  @override
  State<OngakuSkeleton> createState() => _OngakuSkeletonState();
}

class _OngakuSkeletonState extends State<OngakuSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) => Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.circle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: widget.circle
                ? null
                : BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1 - 2 * _c.value + 2, 0),
              end: Alignment(1 - 2 * _c.value + 2, 0),
              colors: [c.fgSoft, c.fgSoft2, c.fgSoft],
              tileMode: TileMode.mirror,
            ),
          ),
        ),
      ),
    );
  }
}
