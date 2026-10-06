import 'package:flutter/material.dart';

import '../../../models/track.dart';
import '../atoms/atoms.dart';
import '../tokens/tokens.dart';
import 'section_header.dart';

/// Shared song row (`.row`): cover, title, artist, album, duration, favorite
/// and the ⋯ menu. Shows an equalizer when it is the one playing, a download
/// dot when available offline and dims when unavailable or not cached.
class TrackRow extends StatefulWidget {
  const TrackRow({
    super.key,
    required this.track,
    required this.number,
    required this.onPlay,
    required this.onMenu,
    required this.onToggleFavorite,
    this.isCurrent = false,
    this.isPlaying = false,
    this.isFavorite = false,
    this.isDownloaded = false,
    this.dimmed = false,
    this.showAlbum = true,
    this.showArt = true,
    this.onArtist,
    this.onAlbum,
    this.onRemove,
    this.dragHandle,
    this.leadingTag,
  });

  final Track track;

  /// Displayed index; empty string hides it.
  final String number;
  final VoidCallback onPlay;

  /// Receives the ⋯ button's context so menus can anchor to it.
  final void Function(BuildContext anchor) onMenu;
  final VoidCallback onToggleFavorite;
  final bool isCurrent;
  final bool isPlaying;
  final bool isFavorite;
  final bool isDownloaded;
  final bool dimmed;
  final bool showAlbum;
  final bool showArt;
  final VoidCallback? onArtist;
  final VoidCallback? onAlbum;
  final VoidCallback? onRemove;

  /// Replaces the index cell (reorderable playlists).
  final Widget? dragHandle;

  /// Extra tag before the duration (history device + time).
  final Widget? leadingTag;

  @override
  State<TrackRow> createState() => _TrackRowState();
}

class _TrackRowState extends State<TrackRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = widget.track;
    final compact = OngakuBreakpoints.isCompact(context);
    final showFav = compact || _hover || widget.isFavorite;

    final index = SizedBox(
      width: 32,
      height: 32,
      child:
          widget.dragHandle ??
          (_hover
              ? OngakuPressable(
                  onTap: widget.onPlay,
                  tooltip: 'Reproducir ${t.title}',
                  semanticLabel: 'Reproducir ${t.title}',
                  borderRadius: OngakuRadii.smAll,
                  hoverColor: Colors.transparent,
                  child: Center(
                    child: OngakuIcon(OngakuIcons.play, size: 16, color: c.fg),
                  ),
                )
              : Center(
                  child: widget.isCurrent && widget.isPlaying
                      ? OngakuEq(active: true, color: c.fg)
                      : Text(
                          widget.number,
                          style: OngakuTypography.mono(context),
                        ),
                )),
    );

    final who = Row(
      children: [
        if (widget.showArt) ...[
          OngakuCover.single(t.coverUrl, size: 40, radius: OngakuRadii.xs),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: widget.isCurrent
                      ? FontWeight.w700
                      : FontWeight.w600,
                  color: widget.isCurrent && compact ? c.accent : c.fg,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  if (t.unavailable) ...[
                    const OngakuTag('No disponible'),
                    const SizedBox(width: 6),
                  ],
                  if (widget.isDownloaded) ...[
                    OngakuIcon(
                      OngakuIcons.download,
                      size: 14,
                      color: c.ok,
                      semanticLabel: 'Descargada',
                    ),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: QuietLink(t.artistNames, onTap: widget.onArtist),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    final fav = AnimatedOpacity(
      duration: OngakuMotion.fast,
      opacity: showFav ? 1 : 0,
      child: OngakuIconButton(
        icon: OngakuIcons.heart,
        solid: widget.isFavorite,
        active: widget.isFavorite,
        size: OngakuIconButtonSize.small,
        tooltip: widget.isFavorite
            ? 'Quitar de favoritos'
            : 'Agregar a favoritos',
        onPressed: widget.onToggleFavorite,
      ),
    );

    final more = Builder(
      builder: (ctx) => OngakuIconButton(
        icon: OngakuIcons.more,
        size: OngakuIconButtonSize.small,
        tooltip: 'Más opciones para ${t.title}',
        onPressed: () => widget.onMenu(ctx),
      ),
    );

    final children = compact
        ? <Widget>[
            if (widget.dragHandle != null) ...[index, const SizedBox(width: 8)],
            Expanded(child: who),
            ?widget.leadingTag,
            fav,
            more,
            if (widget.onRemove != null) _remove(),
          ]
        : <Widget>[
            index,
            const SizedBox(width: 14),
            Expanded(flex: 10, child: who),
            if (widget.showAlbum) ...[
              const SizedBox(width: 14),
              Expanded(
                flex: 8,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: t.album == null
                      ? const SizedBox.shrink()
                      : QuietLink(t.album!.name, onTap: widget.onAlbum),
                ),
              ),
            ],
            const SizedBox(width: 14),
            ?widget.leadingTag,
            fav,
            SizedBox(
              width: 40,
              child: Text(
                formatDuration(t.duration),
                textAlign: TextAlign.right,
                style: OngakuTypography.mono(context),
              ),
            ),
            const SizedBox(width: 8),
            more,
            if (widget.onRemove != null) _remove(),
          ];

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Opacity(
        opacity: t.unavailable || widget.dimmed ? 0.55 : 1,
        child: OngakuPressable(
          // Phones play on tap; desktops use the index play button / double tap.
          onTap: compact ? widget.onPlay : null,
          borderRadius: OngakuRadii.mdAll,
          color: _hover ? c.fgSoft : null,
          hoverColor: Colors.transparent,
          cursor: compact ? null : MouseCursor.defer,
          child: GestureDetector(
            onDoubleTap: compact ? null : widget.onPlay,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(children: children),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _remove() => OngakuIconButton(
    icon: OngakuIcons.close,
    size: OngakuIconButtonSize.small,
    tooltip: 'Quitar de la playlist',
    onPressed: widget.onRemove,
  );
}

/// Column labels above a desktop track list (`.list-head`).
class TrackListHeader extends StatelessWidget {
  const TrackListHeader({
    super.key,
    this.showAlbum = true,
    this.editable = false,
  });

  final bool showAlbum;
  final bool editable;

  @override
  Widget build(BuildContext context) {
    if (OngakuBreakpoints.isCompact(context)) return const SizedBox.shrink();
    final c = context.colors;
    final style = OngakuTypography.eyebrow(
      context,
    ).copyWith(letterSpacing: 0.66);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text('#', textAlign: TextAlign.center, style: style),
          ),
          const SizedBox(width: 14),
          Expanded(flex: 10, child: Text('TÍTULO', style: style)),
          if (showAlbum) ...[
            const SizedBox(width: 14),
            Expanded(flex: 8, child: Text('ÁLBUM', style: style)),
          ],
          const SizedBox(width: 14),
          SizedBox(
            width: 120 + (editable ? 36 : 0),
            child: Padding(
              padding: EdgeInsets.only(right: 44 + (editable ? 36 : 0)),
              child: Text('DURACIÓN', textAlign: TextAlign.right, style: style),
            ),
          ),
        ],
      ),
    );
  }
}
