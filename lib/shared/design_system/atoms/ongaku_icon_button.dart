import 'package:flutter/material.dart';

import '../tokens/tokens.dart';
import 'ongaku_icon.dart';
import 'ongaku_pressable.dart';

enum OngakuIconButtonSize { small, regular, large }

/// Round icon button: 44 px (36 small, 52 large). [active] tints it with the
/// accent (shuffle, repeat, favorite…). The touch target is never under 36.
class OngakuIconButton extends StatelessWidget {
  const OngakuIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = OngakuIconButtonSize.regular,
    this.active = false,
    this.solid = false,
    this.color,
    this.activeStyle = OngakuActiveStyle.accent,
  });

  final OngakuIcons icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final OngakuIconButtonSize size;
  final bool active;
  final bool solid;
  final Color? color;
  final OngakuActiveStyle activeStyle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (double box, double glyph) = switch (size) {
      OngakuIconButtonSize.small => (36, 18),
      OngakuIconButtonSize.regular => (44, 20),
      OngakuIconButtonSize.large => (52, 26),
    };
    final fg = active && activeStyle == OngakuActiveStyle.accent
        ? c.accent
        : color ?? c.fg;
    return OngakuPressable(
      onTap: onPressed,
      tooltip: tooltip,
      semanticLabel: tooltip,
      selected: active ? true : null,
      borderRadius: OngakuRadii.pillAll,
      hoverColor: c.fgSoft2,
      color: active && activeStyle == OngakuActiveStyle.wash ? c.fgSoft2 : null,
      pressedScale: 0.9,
      child: SizedBox.square(
        dimension: box,
        child: Center(
          child: Opacity(
            opacity: onPressed == null ? 0.4 : 1,
            child: OngakuIcon(icon, size: glyph, color: fg, solid: solid),
          ),
        ),
      ),
    );
  }
}

/// Accent tint (default) or a soft wash, as used inside the dark player.
enum OngakuActiveStyle { accent, wash }
