import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

/// Base interaction surface: hover wash, press scale and focus ring, with the
/// design's timing. Every tappable in the design system builds on it.
class OngakuPressable extends StatefulWidget {
  const OngakuPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.borderRadius = OngakuRadii.mdAll,
    this.hoverColor,
    this.pressedScale = 1,
    this.padding,
    this.semanticLabel,
    this.selected,
    this.tooltip,
    this.cursor,
    this.color,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final BorderRadius borderRadius;

  /// Defaults to `fgSoft`; pass [Colors.transparent] to disable the wash.
  final Color? hoverColor;
  final Color? color;
  final double pressedScale;
  final EdgeInsetsGeometry? padding;
  final String? semanticLabel;
  final bool? selected;
  final String? tooltip;
  final MouseCursor? cursor;

  @override
  State<OngakuPressable> createState() => _OngakuPressableState();
}

class _OngakuPressableState extends State<OngakuPressable> {
  bool _hover = false;
  bool _pressed = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = widget.onTap != null || widget.onLongPress != null;
    final wash = widget.hoverColor ?? c.fgSoft;
    Widget content = AnimatedContainer(
      duration: OngakuMotion.fast,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: _hover && enabled
            ? Color.alphaBlend(wash, widget.color ?? const Color(0x00000000))
            : widget.color,
        borderRadius: widget.borderRadius,
        border: _focused ? Border.all(color: c.accent, width: 2) : null,
      ),
      child: widget.child,
    );
    if (widget.pressedScale != 1) {
      content = AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: const Duration(milliseconds: 120),
        curve: OngakuMotion.ease,
        child: content,
      );
    }
    content = FocusableActionDetector(
      enabled: enabled,
      mouseCursor:
          widget.cursor ??
          (enabled ? SystemMouseCursors.click : MouseCursor.defer),
      onShowHoverHighlight: (v) => setState(() => _hover = v),
      onShowFocusHighlight: (v) => setState(() => _focused = v),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) => widget.onTap?.call(),
        ),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        child: content,
      ),
    );
    content = Semantics(
      button: enabled,
      enabled: enabled,
      selected: widget.selected,
      label: widget.semanticLabel,
      child: content,
    );
    if (widget.tooltip != null) {
      content = Tooltip(message: widget.tooltip!, child: content);
    }
    return content;
  }
}
