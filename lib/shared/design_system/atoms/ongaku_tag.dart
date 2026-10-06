import 'package:flutter/material.dart';

import '../tokens/tokens.dart';
import 'ongaku_icon.dart';

/// Small mono outlined label (`.tag`): requirement ids, sources, states.
class OngakuTag extends StatelessWidget {
  const OngakuTag(
    this.label, {
    super.key,
    this.icon,
    this.color,
    this.background,
  });

  final String label;
  final OngakuIcons? icon;
  final Color? color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = color ?? c.muted;
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: OngakuRadii.pillAll,
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            OngakuIcon(icon!, size: 12, color: fg),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: OngakuTypography.mono(
                context,
                size: 11,
                color: fg,
                weight: FontWeight.w500,
              ).copyWith(letterSpacing: 0.3, height: 1),
            ),
          ),
        ],
      ),
    );
  }
}
