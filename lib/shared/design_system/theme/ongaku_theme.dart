import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

abstract final class OngakuTheme {
  static ThemeData light() => _build(OngakuColors.light, Brightness.light);
  static ThemeData dark() => _build(OngakuColors.dark, Brightness.dark);
  static ThemeData nowPlaying() =>
      _build(OngakuColors.nowPlaying, Brightness.dark);

  static ThemeData _build(OngakuColors c, Brightness brightness) {
    final text = OngakuTypography.textTheme(c);
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.accent,
      onPrimary: c.onAccent,
      secondary: c.fg,
      onSecondary: c.bg,
      error: c.err,
      onError: c.onAccent,
      surface: c.surface,
      onSurface: c.fg,
      onSurfaceVariant: c.muted,
      outline: c.border,
      outlineVariant: c.border,
      inverseSurface: c.fg,
      onInverseSurface: c.bg,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bg,
      canvasColor: c.bg,
      textTheme: text,
      dividerColor: c.border,
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      splashFactory: NoSplash.splashFactory,
      highlightColor: c.fgSoft2,
      hoverColor: c.fgSoft,
      focusColor: c.accentSoft,
      iconTheme: IconThemeData(color: c.fg, size: 20),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.fg,
        selectionColor: c.accentSoft,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.fg,
        contentTextStyle: TextStyle(color: c.bg, fontSize: 14),
        actionTextColor: c.bg,
        shape: const RoundedRectangleBorder(borderRadius: OngakuRadii.cardAll),
        elevation: 8,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.surface,
        elevation: 12,
        shadowColor: Colors.black54,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: OngakuRadii.cardAll,
          side: BorderSide(color: c.border),
        ),
        textStyle: text.bodyMedium?.copyWith(fontSize: 14),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        barrierColor: const Color(0x66080C0F),
        shape: RoundedRectangleBorder(
          borderRadius: OngakuRadii.xlAll,
          side: BorderSide(color: c.border),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: c.border,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: c.fg, borderRadius: OngakuRadii.smAll),
        textStyle: TextStyle(color: c.bg, fontSize: 12),
        waitDuration: const Duration(milliseconds: 500),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: c.fg,
        inactiveTrackColor: c.fgSoft2,
        thumbColor: c.fg,
        overlayColor: c.fgSoft2,
        trackHeight: 4,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(c.fg.withValues(alpha: 0.18)),
        radius: const Radius.circular(8),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      extensions: [c],
    );
  }
}
