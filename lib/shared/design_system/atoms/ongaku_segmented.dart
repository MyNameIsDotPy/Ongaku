import 'package:flutter/material.dart';

import '../tokens/tokens.dart';
import 'elastic_indicator.dart';

/// Pill segmented control whose thumb stretches to the new option.
class OngakuSegmented<T> extends StatefulWidget {
  const OngakuSegmented({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.onDark = false,
    this.semanticLabel,
  });

  final List<(T, String)> options;
  final T value;
  final ValueChanged<T> onChanged;

  /// Translucent track and light thumb, for the immersive player.
  final bool onDark;
  final String? semanticLabel;

  @override
  State<OngakuSegmented<T>> createState() => _OngakuSegmentedState<T>();
}

class _OngakuSegmentedState<T> extends State<OngakuSegmented<T>>
    with IndicatorMeasure {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    measure(widget.value);
    final track = widget.onDark ? const Color(0x1FFFFFFF) : c.fgSoft2;
    final thumb = widget.onDark ? c.fg : c.surface;
    return Semantics(
      label: widget.semanticLabel,
      container: true,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: track,
          borderRadius: OngakuRadii.pillAll,
        ),
        child: Stack(
          key: stackKey,
          children: [
            ElasticIndicator(
              span: indicatorSpan,
              crossStart: 0,
              crossEnd: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: thumb,
                  borderRadius: OngakuRadii.pillAll,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (v, label) in widget.options)
                  _Segment(
                    key: keyFor(v as Object),
                    label: label,
                    selected: v == widget.value,
                    selectedColor: widget.onDark
                        ? const Color(0xFF06090D)
                        : c.fg,
                    color: widget.onDark ? c.muted : c.muted,
                    onTap: () => widget.onChanged(v),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatefulWidget {
  const _Segment({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
    required this.selectedColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;
  final Color selectedColor;

  @override
  State<_Segment> createState() => _SegmentState();
}

class _SegmentState extends State<_Segment> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: widget.selected,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: DefaultTextStyle.of(context).style.merge(
                TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: widget.selected || _hover
                      ? widget.selectedColor
                      : widget.color,
                ),
              ),
              child: Text(widget.label),
            ),
          ),
        ),
      ),
    );
  }
}
