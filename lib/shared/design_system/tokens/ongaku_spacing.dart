/// 8-point spacing grid from the design (`--gap-*`).
abstract final class OngakuSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 20;
  static const double lg = 32;
  static const double xl = 56;

  /// Gap between a block heading and its content.
  static const double blockHead = 14;

  /// Vertical rhythm between page sections (`.block`).
  static const double block = 40;

  /// Desktop sidebar width (`--side`).
  static const double sidebar = 232;

  /// Desktop player bar height (`--bar`).
  static const double playerBar = 84;

  /// Desktop queue panel width.
  static const double queuePanel = 340;

  /// Max content width for views.
  static const double contentMax = 1240;

  /// Horizontal page padding: `clamp(20px, 3.4vw, 44px)` on desktop, 16 on phones.
  static double pagePadding(double width) =>
      width <= 820 ? 16 : (width * 0.034).clamp(20, 44);
}
