import 'package:flutter/material.dart';

import '../atoms/ongaku_pressable.dart';
import '../tokens/tokens.dart';

/// `.block-head`: section title with an optional quiet link on the right.
class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.title, {
    super.key,
    this.actionLabel,
    this.onAction,
    this.small = false,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: OngakuSpacing.blockHead),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: small
                    ? context.text.titleMedium?.copyWith(fontSize: 16)
                    : context.text.headlineSmall,
              ),
            ),
          ),
          if (actionLabel != null) QuietLink(actionLabel!, onTap: onAction),
        ],
      ),
    );
  }
}

/// `.link`: muted, underlines on hover.
class QuietLink extends StatefulWidget {
  const QuietLink(this.label, {super.key, this.onTap, this.color});

  final String label;
  final VoidCallback? onTap;
  final Color? color;

  @override
  State<QuietLink> createState() => _QuietLinkState();
}

class _QuietLinkState extends State<QuietLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: OngakuPressable(
        onTap: widget.onTap,
        hoverColor: Colors.transparent,
        borderRadius: OngakuRadii.smAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _hover ? c.fg : (widget.color ?? c.muted),
              decoration: _hover ? TextDecoration.underline : null,
            ),
          ),
        ),
      ),
    );
  }
}
