import 'package:flutter/material.dart';

import '../tokens/tokens.dart';
import 'ongaku_icon.dart';

/// Loads an artwork from an asset path or a URL.
ImageProvider coverImage(String url) => url.startsWith('assets/')
    ? AssetImage(url) as ImageProvider
    : NetworkImage(url);

/// Square artwork. With several [urls] it renders the 2×2 playlist mosaic;
/// with none, a tinted placeholder with [placeholder].
class OngakuCover extends StatelessWidget {
  const OngakuCover({
    super.key,
    required this.urls,
    this.size,
    this.radius = OngakuRadii.card,
    this.placeholder = OngakuIcons.queue,
    this.circle = false,
    this.semanticLabel,
  });

  OngakuCover.single(
    String url, {
    super.key,
    this.size,
    this.radius = OngakuRadii.card,
    this.placeholder = OngakuIcons.album,
    this.circle = false,
    this.semanticLabel,
  }) : urls = [url];

  final List<String> urls;
  final double? size;
  final double radius;
  final OngakuIcons placeholder;
  final bool circle;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget img(String u) => Image(
      image: coverImage(u),
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => _placeholder(c),
    );
    final Widget content;
    if (urls.isEmpty) {
      content = _placeholder(c);
    } else if (urls.length >= 4) {
      content = Column(
        children: [
          for (final row in [urls.sublist(0, 2), urls.sublist(2, 4)])
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [for (final u in row) Expanded(child: img(u))],
              ),
            ),
        ],
      );
    } else {
      content = img(urls.first);
    }
    return Semantics(
      image: semanticLabel != null,
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox(
        width: size,
        height: size,
        child: AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: circle
                ? BorderRadius.circular(9999)
                : BorderRadius.circular(radius),
            child: ColoredBox(color: c.fgSoft2, child: content),
          ),
        ),
      ),
    );
  }

  Widget _placeholder(OngakuColors c) => ColoredBox(
    color: c.fgSoft2,
    child: Center(child: OngakuIcon(placeholder, color: c.muted)),
  );
}
