import 'package:flutter/material.dart';

import '../atoms/atoms.dart';
import '../tokens/tokens.dart';

/// Underlined tabs whose indicator stretches like a drop (Biblioteca).
class OngakuTabs<T> extends StatefulWidget {
  const OngakuTabs({
    super.key,
    required this.tabs,
    required this.value,
    required this.onChanged,
  });

  final List<(T, String)> tabs;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  State<OngakuTabs<T>> createState() => _OngakuTabsState<T>();
}

class _OngakuTabsState<T> extends State<OngakuTabs<T>> with IndicatorMeasure {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    measure(widget.value);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Stack(
          key: stackKey,
          children: [
            Row(
              children: [
                for (final (v, label) in widget.tabs)
                  Padding(
                    key: keyFor(v as Object),
                    padding: const EdgeInsets.only(right: 4),
                    child: OngakuPressable(
                      onTap: () => widget.onChanged(v),
                      selected: v == widget.value,
                      hoverColor: Colors.transparent,
                      borderRadius: OngakuRadii.smAll,
                      child: SizedBox(
                        height: 44,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Center(
                            widthFactor: 1,
                            child: AnimatedDefaultTextStyle(
                              duration: OngakuMotion.fast,
                              style: DefaultTextStyle.of(context).style.merge(
                                TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: v == widget.value ? c.fg : c.muted,
                                ),
                              ),
                              child: Text(label),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            ElasticIndicator(
              span: indicatorSpan == null
                  ? null
                  : IndicatorSpan(
                      indicatorSpan!.start,
                      indicatorSpan!.extent - 4,
                    ),
              crossEnd: 0,
              crossExtent: 2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: c.fg,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
