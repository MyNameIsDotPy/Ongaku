import 'package:flutter/material.dart';

import '../atoms/atoms.dart';
import '../tokens/tokens.dart';
import 'nav_destination.dart';

/// Android bottom tabs with a liquid "blob" behind the active icon.
class OngakuTabBar extends StatefulWidget {
  const OngakuTabBar({
    super.key,
    required this.current,
    required this.onNavigate,
  });

  final NavDestination? current;
  final ValueChanged<NavDestination> onNavigate;

  @override
  State<OngakuTabBar> createState() => _OngakuTabBarState();
}

class _OngakuTabBarState extends State<OngakuTabBar> with IndicatorMeasure {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    measure(widget.current);
    final span = indicatorSpan;
    return Container(
      decoration: BoxDecoration(
        color: c.bg,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: SafeArea(
        top: false,
        child: Stack(
          key: stackKey,
          children: [
            ElasticIndicator(
              span: span == null
                  ? null
                  : IndicatorSpan(span.start + span.extent / 2 - 30, 60),
              crossStart: 6,
              crossExtent: 30,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: c.fgSoft2,
                  borderRadius: OngakuRadii.pillAll,
                ),
              ),
            ),
            Row(
              children: [
                for (final d in NavDestination.values)
                  Expanded(
                    key: keyFor(d),
                    child: OngakuPressable(
                      onTap: () => widget.onNavigate(d),
                      selected: d == widget.current,
                      semanticLabel: d.label,
                      hoverColor: Colors.transparent,
                      borderRadius: BorderRadius.zero,
                      child: SizedBox(
                        height: 58,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OngakuIcon(
                              d.icon,
                              color: d == widget.current ? c.accent : c.muted,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              d.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: d == widget.current ? c.fg : c.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
