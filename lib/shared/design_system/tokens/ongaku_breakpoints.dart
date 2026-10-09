import 'package:flutter/widgets.dart';

/// Android ≤ 820 px gets tabs + floating mini-player; PC gets the three-zone
/// layout (sidebar, content, optional queue) with a bottom player bar.
abstract final class OngakuBreakpoints {
  static const double compact = 820;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width <= compact;

  /// A phone turned sideways: wide enough to be compact, but too short for
  /// the portrait stack (about 360 dp of height).
  static bool isLandscapePhone(BuildContext context) {
    final s = MediaQuery.sizeOf(context);
    return s.width > s.height && s.height < 600;
  }
}
