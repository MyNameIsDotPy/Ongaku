import 'package:flutter/material.dart';

import '../tokens/tokens.dart';
import 'ongaku_icon.dart';
import 'ongaku_pressable.dart';

/// Filter / recent-search chip. Selected chips invert to ink.
class OngakuChip extends StatelessWidget {
  const OngakuChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.onRemove,
    this.removeLabel,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final String? removeLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = selected ? c.bg : c.fg;
    return AnimatedContainer(
      duration: OngakuMotion.fast,
      height: 34,
      decoration: BoxDecoration(
        color: selected ? c.fg : Colors.transparent,
        borderRadius: OngakuRadii.pillAll,
        border: Border.all(color: selected ? c.fg : c.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OngakuPressable(
            onTap: onTap,
            selected: selected,
            borderRadius: OngakuRadii.pillAll,
            hoverColor: selected ? Colors.transparent : c.fgSoft2,
            padding: EdgeInsets.only(
              left: 14,
              right: onRemove == null ? 14 : 6,
            ),
            child: SizedBox(
              height: 32,
              child: Center(
                widthFactor: 1,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: fg,
                  ),
                ),
              ),
            ),
          ),
          if (onRemove != null)
            Padding(
              padding: const EdgeInsets.only(right: 3),
              child: OngakuPressable(
                onTap: onRemove,
                tooltip: removeLabel,
                semanticLabel: removeLabel,
                borderRadius: OngakuRadii.pillAll,
                hoverColor: c.fgSoft2,
                child: SizedBox.square(
                  dimension: 26,
                  child: Center(
                    child: OngakuIcon(OngakuIcons.close, size: 14, color: fg),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
