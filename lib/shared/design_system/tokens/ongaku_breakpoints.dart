import 'package:flutter/widgets.dart';

/// Android ≤ 820 px gets tabs + floating mini-player; PC gets the three-zone
/// layout (sidebar, content, optional queue) with a bottom player bar.
abstract final class OngakuBreakpoints {
  static const double compact = 820;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width <= compact;
}
