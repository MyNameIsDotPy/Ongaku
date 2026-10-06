import 'package:flutter/material.dart';

import '../atoms/atoms.dart';
import '../tokens/tokens.dart';

/// Album / playlist / artist card (`.card`): artwork zooms slightly on hover
/// and a round play button rises from the corner.
class MediaCard extends StatefulWidget {
  const MediaCard({
    super.key,
    required this.covers,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.onPlay,
    this.heroTag,
    this.circle = false,
    this.placeholder = OngakuIcons.queue,
  });

  final List<String> covers;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback? onPlay;

  /// Shared-element tag so the artwork flies into the detail header.
  final Object? heroTag;
  final bool circle;
  final OngakuIcons placeholder;

  @override
  State<MediaCard> createState() => _MediaCardState();
}

class _MediaCardState extends State<MediaCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final compact = OngakuBreakpoints.isCompact(context);
    Widget art = AnimatedScale(
      scale: _hover ? 1.04 : 1,
      duration: OngakuMotion.rise,
      curve: OngakuMotion.ease,
      child: OngakuCover(
        urls: widget.covers,
        radius: 0,
        placeholder: widget.placeholder,
      ),
    );
    art = ClipRRect(
      borderRadius: widget.circle
          ? BorderRadius.circular(999)
          : OngakuRadii.cardAll,
      child: AspectRatio(aspectRatio: 1, child: art),
    );
    if (widget.heroTag != null) {
      art = Hero(tag: widget.heroTag!, child: art);
    }
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Semantics(
        button: true,
        label: '${widget.title}, ${widget.subtitle}',
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: OngakuRadii.cardAll,
                        boxShadow: [
                          BoxShadow(
                            color: c.border,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: art,
                    ),
                    if (widget.onPlay != null && !compact)
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: AnimatedSlide(
                          offset: _hover ? Offset.zero : const Offset(0, 0.18),
                          duration: OngakuMotion.medium,
                          curve: OngakuMotion.spring,
                          child: AnimatedOpacity(
                            opacity: _hover ? 1 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: HoverPlayButton(
                              onPressed: widget.onPlay!,
                              label: 'Reproducir ${widget.title}',
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: c.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The ink disc with a play glyph used on cards and the top search result.
class HoverPlayButton extends StatelessWidget {
  const HoverPlayButton({
    super.key,
    required this.onPressed,
    required this.label,
  });

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return OngakuPressable(
      onTap: onPressed,
      semanticLabel: label,
      tooltip: label,
      pressedScale: 0.92,
      borderRadius: OngakuRadii.pillAll,
      color: c.fg,
      hoverColor: c.bg.withValues(alpha: 0.12),
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x80000000),
              blurRadius: 18,
              offset: Offset(0, 6),
              spreadRadius: -6,
            ),
          ],
        ),
        child: Center(
          child: OngakuIcon(OngakuIcons.play, size: 18, color: c.bg),
        ),
      ),
    );
  }
}

/// Responsive grid of cards: `repeat(auto-fill, minmax(168px, 1fr))`,
/// two columns on phones.
class CardGrid extends StatelessWidget {
  const CardGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final compact = OngakuBreakpoints.isCompact(context);
        final gapX = compact ? 12.0 : 18.0;
        final gapY = compact ? 18.0 : 22.0;
        final cols = compact
            ? 2
            : ((box.maxWidth + gapX) / (168 + gapX)).floor().clamp(1, 12);
        final w = (box.maxWidth - gapX * (cols - 1)) / cols;
        return Wrap(
          spacing: gapX,
          runSpacing: gapY,
          children: [for (final c in children) SizedBox(width: w, child: c)],
        );
      },
    );
  }
}
