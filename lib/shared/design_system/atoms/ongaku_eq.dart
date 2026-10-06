import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../theme/ongaku_motion_settings.dart';

/// Four-bar equalizer marking the row that is playing.
class OngakuEq extends StatefulWidget {
  const OngakuEq({super.key, required this.active, this.color, this.size = 14});

  final bool active;
  final Color? color;
  final double size;

  @override
  State<OngakuEq> createState() => _OngakuEqState();
}

class _OngakuEqState extends State<OngakuEq>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker((e) {
    setState(() => _t = e.inMicroseconds / 1e6);
  });
  double _t = 0;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(OngakuEq old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (widget.active && !_ticker.isActive) _ticker.start();
    if (!widget.active && _ticker.isActive) _ticker.stop();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? IconTheme.of(context).color!;
    final moving = widget.active && !OngakuMotionSettings.reducedOf(context);
    const speeds = [7.3, 9.1, 5.7, 11.2];
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: widget.size,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < 4; i++)
              Container(
                width: 2.5,
                height:
                    widget.size *
                    (moving
                        ? 0.22 +
                              0.7 *
                                  (0.5 +
                                      0.5 *
                                          math.sin(_t * speeds[i] + i * 1.3) *
                                          math.cos(_t * speeds[3 - i] * 0.37))
                        : 0.3),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
