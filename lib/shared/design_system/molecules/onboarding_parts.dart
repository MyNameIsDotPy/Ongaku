import 'package:flutter/material.dart';

import '../atoms/atoms.dart';
import '../tokens/tokens.dart';

/// Three-segment progress for the first-run flow (`.steps`).
class StepsIndicator extends StatelessWidget {
  const StepsIndicator({super.key, required this.step, this.count = 3});

  final int step;
  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: 'Paso ${step + 1} de $count',
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  children: [
                    Container(height: 4, color: c.fgSoft2),
                    AnimatedFractionallySizedBox(
                      duration: OngakuMotion.rise,
                      curve: OngakuMotion.ease,
                      widthFactor: i <= step ? 1 : 0,
                      child: Container(height: 4, color: c.fg),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Permission request card (`.perm`) with a switch.
class PermissionCard extends StatelessWidget {
  const PermissionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.granted,
    required this.onChanged,
  });

  final OngakuIcons icon;
  final String title;
  final String description;
  final bool granted;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: OngakuRadii.tileAll,
        border: Border.all(color: c.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: c.fgSoft2,
              borderRadius: OngakuRadii.mdAll,
            ),
            child: Center(child: OngakuIcon(icon)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: c.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          OngakuSwitch(
            value: granted,
            onChanged: onChanged,
            semanticLabel: title,
          ),
        ],
      ),
    );
  }
}
