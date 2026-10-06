import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

/// Header for album, playlist and artist pages (`.hero`): artwork with a glow
/// in the cover's color, eyebrow, big title and facts. Centered on phones.
class DetailHero extends StatelessWidget {
  const DetailHero({
    super.key,
    required this.artwork,
    required this.eyebrow,
    required this.title,
    required this.facts,
    this.glow,
    this.circle = false,
  });

  final Widget artwork;
  final String eyebrow;

  /// Usually a [Text]; the playlist page swaps in an inline editor.
  final Widget title;
  final List<Widget> facts;
  final Color? glow;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final compact = OngakuBreakpoints.isCompact(context);
    final width = MediaQuery.sizeOf(context).width;
    final coverSize = compact
        ? (width * 0.64).clamp(160.0, 260.0)
        : (width * 0.22).clamp(160.0, 232.0);
    final cover = Container(
      width: coverSize,
      height: coverSize,
      decoration: BoxDecoration(
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : OngakuRadii.tileAll,
        boxShadow: [
          BoxShadow(
            color: (glow ?? Colors.black).withValues(
              alpha: glow == null ? 0.4 : 0.6,
            ),
            blurRadius: 48,
            offset: const Offset(0, 24),
            spreadRadius: -24,
          ),
        ],
      ),
      child: artwork,
    );
    final text = Column(
      crossAxisAlignment: compact
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(eyebrow.toUpperCase(), style: OngakuTypography.eyebrow(context)),
        const SizedBox(height: 8),
        DefaultTextStyle.merge(
          textAlign: compact ? TextAlign.center : TextAlign.start,
          style:
              (compact ? context.text.headlineLarge : context.text.displayLarge)
                  ?.copyWith(fontWeight: FontWeight.w800, height: 1.02),
          child: Semantics(header: true, child: title),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: compact ? WrapAlignment.center : WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 14,
          runSpacing: 6,
          children: facts,
        ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: compact
          ? Column(children: [cover, const SizedBox(height: 20), text])
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                cover,
                SizedBox(width: (width * 0.03).clamp(20, 36)),
                Expanded(child: text),
              ],
            ),
    );
  }
}

/// Soft radial wash in the cover's color behind the top of a detail page.
class DetailTint extends StatelessWidget {
  const DetailTint({super.key, required this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (color == null) return const SizedBox.shrink();
    return IgnorePointer(
      child: AnimatedContainer(
        duration: OngakuMotion.sheet,
        height: 380,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-0.6, -1),
            radius: 1.1,
            colors: [
              color!.withValues(alpha: 0.22),
              color!.withValues(alpha: 0),
            ],
            stops: const [0, 0.7],
          ),
        ),
      ),
    );
  }
}

/// Facts row text in the hero (`.facts`).
class HeroFact extends StatelessWidget {
  const HeroFact(this.text, {super.key, this.mono = false});

  final String text;
  final bool mono;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: mono
        ? OngakuTypography.mono(context, size: 14)
        : TextStyle(fontSize: 14, color: context.colors.muted),
  );
}
