import 'package:flutter/material.dart';

import 'ongaku_colors.dart';

/// Display = SF Pro Display/system, body = system sans, mono for numerics.
abstract final class OngakuTypography {
  static const List<String> monoFamilies = [
    'JetBrains Mono',
    'SF Mono',
    'Menlo',
    'Consolas',
    'Roboto Mono',
    'monospace',
  ];

  static TextTheme textTheme(OngakuColors c) {
    TextStyle display(double size, FontWeight w, {double height = 1.1}) =>
        TextStyle(
          fontSize: size,
          fontWeight: w,
          height: height,
          letterSpacing: -0.02 * size,
          color: c.fg,
        );
    return TextTheme(
      displayLarge: display(56, FontWeight.w800, height: 1.02),
      displayMedium: display(40, FontWeight.w700, height: 1.05),
      headlineLarge: display(34, FontWeight.w700),
      headlineMedium: display(28, FontWeight.w700),
      headlineSmall: display(20, FontWeight.w600, height: 1.25),
      titleLarge: display(18, FontWeight.w600, height: 1.3),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: c.fg,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: c.fg,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: c.fg),
      bodyMedium: TextStyle(fontSize: 15, height: 1.5, color: c.fg),
      bodySmall: TextStyle(fontSize: 13, height: 1.4, color: c.muted),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: c.fg,
      ),
      labelMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: c.fg,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: c.muted,
      ),
    );
  }

  /// Tabular numerics (durations, sizes, versions).
  static TextStyle mono(
    BuildContext context, {
    double size = 13,
    Color? color,
    FontWeight? weight,
  }) {
    return TextStyle(
      fontFamilyFallback: monoFamilies,
      fontFamily: monoFamilies.first,
      fontSize: size,
      fontWeight: weight,
      color: color ?? context.colors.muted,
      fontFeatures: const [FontFeature.tabularFigures()],
      height: 1.3,
    );
  }

  /// Uppercase mono label above headings (`.eyebrow`).
  static TextStyle eyebrow(BuildContext context, {Color? color}) => mono(
    context,
    size: 11,
    color: color,
    weight: FontWeight.w500,
  ).copyWith(letterSpacing: 0.9, height: 1);
}

extension OngakuTextContext on BuildContext {
  TextTheme get text => Theme.of(this).textTheme;
}
