import 'package:flutter/material.dart';

import '../tokens/tokens.dart';
import 'ongaku_icon.dart';

/// Ink tile with the wave glyph, plus the "Ongaku" wordmark.
class OngakuBrand extends StatelessWidget {
  const OngakuBrand({super.key, this.showName = true, this.size = 26});

  final bool showName;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: 'Ongaku',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: c.fg,
              borderRadius: BorderRadius.circular(size * 0.31),
            ),
            child: Center(
              child: OngakuIcon(
                OngakuIcons.wave,
                size: size * 0.62,
                color: c.bg,
              ),
            ),
          ),
          if (showName) ...[
            const SizedBox(width: 10),
            Text(
              'Ongaku',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.34,
                color: c.fg,
                height: 1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
