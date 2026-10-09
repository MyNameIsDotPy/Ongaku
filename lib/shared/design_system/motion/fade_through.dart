import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

/// Fade-through: the outgoing view fades out in the first half of its
/// reverse animation, and the incoming view fades in only in the second
/// half. Two views never show at once, so their text cannot overlap.
///
/// Works for route transitions and `AnimatedSwitcher`, which both pass an
/// animation that runs 0 → 1 for the incoming child and 1 → 0 for the
/// outgoing one.
Widget fadeThrough(Animation<double> animation, Widget child) => FadeTransition(
  opacity: CurvedAnimation(
    parent: animation,
    curve: const Interval(0.5, 1, curve: OngakuMotion.ease),
  ),
  child: child,
);
