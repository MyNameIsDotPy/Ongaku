import 'package:flutter/material.dart';

import '../atoms/atoms.dart';
import '../molecules/offline_banner.dart';
import '../tokens/tokens.dart';
import 'nav_destination.dart';

class SidebarPlaylist {
  const SidebarPlaylist({required this.id, required this.name, this.coverUrl});
  final String id;
  final String name;
  final String? coverUrl;
}

/// Desktop navigation column: brand, sections with an elastic pill, the
/// user's playlists and the connection indicator.
class OngakuSidebar extends StatefulWidget {
  const OngakuSidebar({
    super.key,
    required this.current,
    required this.onNavigate,
    required this.playlists,
    required this.onPlaylist,
    required this.online,
    this.onBrand,
  });

  final NavDestination? current;
  final ValueChanged<NavDestination> onNavigate;
  final List<SidebarPlaylist> playlists;
  final ValueChanged<String> onPlaylist;
  final bool online;
  final VoidCallback? onBrand;

  @override
  State<OngakuSidebar> createState() => _OngakuSidebarState();
}

class _OngakuSidebarState extends State<OngakuSidebar> with IndicatorMeasure {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    measure(widget.current, axis: Axis.vertical);
    return Container(
      width: OngakuSpacing.sidebar,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: c.border)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 18),
            child: Align(
              alignment: Alignment.centerLeft,
              child: OngakuPressable(
                onTap: widget.onBrand,
                hoverColor: Colors.transparent,
                padding: const EdgeInsets.all(6),
                child: const OngakuBrand(),
              ),
            ),
          ),
          Stack(
            key: stackKey,
            children: [
              ElasticIndicator(
                span: indicatorSpan,
                axis: Axis.vertical,
                crossStart: 0,
                crossEnd: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: c.fgSoft2,
                    borderRadius: OngakuRadii.mdAll,
                  ),
                ),
              ),
              Column(
                children: [
                  for (final d in NavDestination.values)
                    Padding(
                      key: keyFor(d),
                      padding: const EdgeInsets.only(bottom: 4),
                      child: _NavItem(
                        destination: d,
                        selected: d == widget.current,
                        onTap: () => widget.onNavigate(d),
                      ),
                    ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 18, 10, 6),
            child: Text(
              'TUS PLAYLISTS',
              style: OngakuTypography.eyebrow(context),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (final p in widget.playlists)
                  OngakuPressable(
                    onTap: () => widget.onPlaylist(p.id),
                    borderRadius: OngakuRadii.smAll,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        OngakuCover(
                          urls: [?p.coverUrl],
                          size: 32,
                          radius: OngakuRadii.xs,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            p.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14, color: c.muted),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 0),
            child: ConnectionIndicator(online: widget.online),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final NavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final active = widget.selected || _hover;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: OngakuPressable(
        onTap: widget.onTap,
        selected: widget.selected,
        semanticLabel: widget.destination.label,
        borderRadius: OngakuRadii.smAll,
        hoverColor: widget.selected ? Colors.transparent : c.fgSoft,
        child: SizedBox(
          height: 40,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                OngakuIcon(
                  widget.destination.icon,
                  color: widget.selected ? c.accent : (active ? c.fg : c.muted),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.destination.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: active ? c.fg : c.muted,
                    ),
                  ),
                ),
                if (widget.destination == NavDestination.buscar)
                  Text(
                    'Ctrl F',
                    style: OngakuTypography.mono(context, size: 11),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
