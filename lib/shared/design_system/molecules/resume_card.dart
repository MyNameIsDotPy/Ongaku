import 'package:flutter/material.dart';

import '../atoms/atoms.dart';
import '../tokens/tokens.dart';

/// "Seguir escuchando" card (`.resume`); the first one shows the restored
/// position (RF-16).
class ResumeCard extends StatefulWidget {
  const ResumeCard({
    super.key,
    required this.coverUrl,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.progress,
  });

  final String coverUrl;
  final String title;
  final String subtitle;
  final double? progress;
  final VoidCallback onTap;

  @override
  State<ResumeCard> createState() => _ResumeCardState();
}

class _ResumeCardState extends State<ResumeCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedSlide(
        offset: _hover ? const Offset(0, -0.025) : Offset.zero,
        duration: const Duration(milliseconds: 200),
        curve: OngakuMotion.ease,
        child: OngakuPressable(
          onTap: widget.onTap,
          semanticLabel: 'Reanudar ${widget.title}',
          borderRadius: OngakuRadii.tileAll,
          hoverColor: Colors.transparent,
          child: AnimatedContainer(
            duration: OngakuMotion.fast,
            padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: OngakuRadii.tileAll,
              border: Border.all(
                color: _hover ? Color.lerp(c.border, c.fg, 0.3)! : c.border,
              ),
            ),
            child: Row(
              children: [
                OngakuCover.single(
                  widget.coverUrl,
                  size: 56,
                  radius: OngakuRadii.sm,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: c.muted),
                      ),
                      if (widget.progress != null) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: widget.progress,
                            minHeight: 3,
                            backgroundColor: c.fgSoft2,
                            color: c.fg,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shortcut tile (`.tile`): small artwork + label on a soft wash.
class ShortcutTile extends StatelessWidget {
  const ShortcutTile({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return OngakuPressable(
      onTap: onTap,
      color: c.fgSoft,
      hoverColor: c.fgSoft,
      borderRadius: OngakuRadii.cardAll,
      padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: OngakuRadii.smAll,
              border: Border.all(color: c.border),
            ),
            child: Center(child: leading),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: c.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
