import 'package:flutter/animation.dart';

/// Motion spec from the design: "everything flows like liquid; the rhythm
/// only lives in the player".
abstract final class OngakuMotion {
  /// `cubic-bezier(.2,.8,.2,1)` — enters fast, settles slowly.
  static const Curve ease = Cubic(0.2, 0.8, 0.2, 1);

  /// `cubic-bezier(.34,1.36,.5,1)` — only on touchable things: play,
  /// switches and toasts.
  static const Curve spring = Cubic(0.34, 1.36, 0.5, 1);

  /// Elastic indicators (tabs, segmented controls, nav pill).
  static const Curve stretch = Cubic(0.3, 0.7, 0.2, 1);

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration rise = Duration(milliseconds: 500);
  static const Duration indicator = Duration(milliseconds: 560);
  static const Duration sheet = Duration(milliseconds: 600);
  static const Duration coverSwap = Duration(milliseconds: 800);

  /// Views enter staggered every 45 ms.
  static const Duration stagger = Duration(milliseconds: 45);
}
