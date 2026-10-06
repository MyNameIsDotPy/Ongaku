import 'package:flutter/material.dart';

import '../tokens/tokens.dart';
import 'ongaku_icon.dart';
import 'ongaku_spinner.dart';

enum OngakuButtonVariant { primary, secondary, ghost, danger }

/// Pill button, 44 px tall. Secondary buttons fill like a liquid from the
/// point where the cursor enters.
class OngakuButton extends StatefulWidget {
  const OngakuButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = OngakuButtonVariant.secondary,
    this.icon,
    this.loading = false,
    this.dense = false,
  });

  const OngakuButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.dense = false,
  }) : variant = OngakuButtonVariant.primary;

  const OngakuButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.dense = false,
  }) : variant = OngakuButtonVariant.ghost;

  final String label;
  final VoidCallback? onPressed;
  final OngakuButtonVariant variant;
  final OngakuIcons? icon;
  final bool loading;
  final bool dense;

  @override
  State<OngakuButton> createState() => _OngakuButtonState();
}

class _OngakuButtonState extends State<OngakuButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fill;

  @override
  void initState() {
    super.initState();
    _fill = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
  }

  Offset _origin = Offset.zero;
  bool _hover = false;
  bool _pressed = false;
  bool _focused = false;

  @override
  void dispose() {
    _fill.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = widget.onPressed != null && !widget.loading;
    final (Color bg, Color fg, Color? border) = switch (widget.variant) {
      OngakuButtonVariant.primary => (
        _hover ? Color.lerp(c.accent, Colors.black, 0.14)! : c.accent,
        c.onAccent,
        null,
      ),
      OngakuButtonVariant.secondary => (
        c.surface,
        c.fg,
        _hover ? c.fg : c.border,
      ),
      OngakuButtonVariant.danger => (
        c.surface,
        c.err,
        _hover ? c.err : c.border,
      ),
      OngakuButtonVariant.ghost => (
        _hover ? c.fgSoft2 : Colors.transparent,
        c.fg,
        null,
      ),
    };
    final liquid =
        widget.variant == OngakuButtonVariant.secondary ||
        widget.variant == OngakuButtonVariant.danger;

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.loading) ...[
          OngakuSpinner(size: 16, color: fg),
          const SizedBox(width: 8),
        ] else if (widget.icon != null) ...[
          OngakuIcon(widget.icon!, size: 18, color: fg),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: fg,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: enabled,
      child: FocusableActionDetector(
        enabled: enabled,
        mouseCursor: enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) => widget.onPressed?.call(),
          ),
        },
        child: MouseRegion(
          onEnter: (e) {
            setState(() {
              _hover = true;
              _origin = e.localPosition;
            });
            if (liquid) _fill.forward();
          },
          onExit: (_) {
            setState(() => _hover = false);
            if (liquid) _fill.reverse();
          },
          child: GestureDetector(
            onTap: enabled ? widget.onPressed : null,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            child: AnimatedScale(
              scale: _pressed ? 0.97 : 1,
              duration: const Duration(milliseconds: 120),
              curve: OngakuMotion.ease,
              child: AnimatedOpacity(
                opacity: enabled || widget.loading ? 1 : 0.45,
                duration: OngakuMotion.fast,
                child: AnimatedContainer(
                  duration: OngakuMotion.fast,
                  height: widget.dense ? 36 : 44,
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.dense ? 12 : 18,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: OngakuRadii.pillAll,
                    border: Border.all(
                      color: _focused ? c.accent : border ?? Colors.transparent,
                      width: _focused ? 2 : 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: OngakuRadii.pillAll,
                    child: CustomPaint(
                      painter: liquid
                          ? _LiquidFillPainter(_fill, _origin, c.fgSoft2)
                          : null,
                      child: Center(widthFactor: 1, child: child),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LiquidFillPainter extends CustomPainter {
  _LiquidFillPainter(this.anim, this.origin, this.color) : super(repaint: anim);

  final Animation<double> anim;
  final Offset origin;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final t = OngakuMotion.ease.transform(anim.value);
    if (t == 0) return;
    final r = size.longestSide * 1.2 * t;
    canvas.drawCircle(origin, r, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_LiquidFillPainter old) =>
      old.origin != origin || old.color != color;
}
