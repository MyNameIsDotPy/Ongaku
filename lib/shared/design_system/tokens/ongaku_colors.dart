import 'package:flutter/material.dart';

/// Color tokens converted from the oklch values in
/// `assets/design/app.css` to sRGB.
///
/// Six base tokens (bg, surface, fg, muted, border, accent); everything else is
/// derived. The accent is used at most twice per screen.
@immutable
class OngakuColors extends ThemeExtension<OngakuColors> {
  const OngakuColors({
    required this.bg,
    required this.surface,
    required this.fg,
    required this.muted,
    required this.border,
    required this.accent,
    this.onAccent = const Color(0xFFFCFCFC),
    this.ok = const Color(0xFF0FA05C),
    this.warn = const Color(0xFFDA950B),
    this.err = const Color(0xFFD73337),
  });

  final Color bg;
  final Color surface;
  final Color fg;
  final Color muted;
  final Color border;
  final Color accent;
  final Color onAccent;
  final Color ok;
  final Color warn;
  final Color err;

  /// `--fg-soft`: hover wash.
  Color get fgSoft => fg.withValues(alpha: 0.05);

  /// `--fg-soft-2`: pressed wash, rails, skeletons.
  Color get fgSoft2 => fg.withValues(alpha: 0.09);

  /// `--accent-soft`.
  Color get accentSoft => accent.withValues(alpha: 0.14);

  Color get shadow => const Color(0xFF000000);

  static const light = OngakuColors(
    bg: Color(0xFFFBFCFD),
    surface: Color(0xFFFFFFFF),
    fg: Color(0xFF0E1217),
    muted: Color(0xFF5E646A),
    border: Color(0xFFE2E5E8),
    accent: Color(0xFF1779E1),
  );

  static const dark = OngakuColors(
    bg: Color(0xFF080C0F),
    surface: Color(0xFF101419),
    fg: Color(0xFFF0F2F4),
    muted: Color(0xFF9FA5AC),
    border: Color(0xFF22272C),
    accent: Color(0xFF4C99F8),
  );

  /// The immersive player is always dark, whatever the app theme.
  static const nowPlaying = OngakuColors(
    bg: Color(0xFF05080B),
    surface: Color(0xFF171B1F),
    fg: Color(0xFFF8F8F8),
    muted: Color(0xFFC6CBD1),
    border: Color(0x24FFFFFF),
    accent: Color(0xFF4C99F8),
    err: Color(0xFFFFB7B0),
  );

  static OngakuColors of(BuildContext context) =>
      Theme.of(context).extension<OngakuColors>() ?? light;

  @override
  OngakuColors copyWith({
    Color? bg,
    Color? surface,
    Color? fg,
    Color? muted,
    Color? border,
    Color? accent,
    Color? onAccent,
    Color? ok,
    Color? warn,
    Color? err,
  }) => OngakuColors(
    bg: bg ?? this.bg,
    surface: surface ?? this.surface,
    fg: fg ?? this.fg,
    muted: muted ?? this.muted,
    border: border ?? this.border,
    accent: accent ?? this.accent,
    onAccent: onAccent ?? this.onAccent,
    ok: ok ?? this.ok,
    warn: warn ?? this.warn,
    err: err ?? this.err,
  );

  @override
  OngakuColors lerp(OngakuColors? other, double t) {
    if (other == null) return this;
    return OngakuColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      fg: Color.lerp(fg, other.fg, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      border: Color.lerp(border, other.border, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      ok: Color.lerp(ok, other.ok, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      err: Color.lerp(err, other.err, t)!,
    );
  }
}

extension OngakuColorsContext on BuildContext {
  OngakuColors get colors => OngakuColors.of(this);
}
