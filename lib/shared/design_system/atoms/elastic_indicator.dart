import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/ongaku_motion_settings.dart';
import '../tokens/tokens.dart';

/// A span along one axis (`start` + `extent`).
@immutable
class IndicatorSpan {
  const IndicatorSpan(this.start, this.extent);
  final double start;
  final double extent;
  double get end => start + extent;

  @override
  bool operator ==(Object other) =>
      other is IndicatorSpan && other.start == start && other.extent == extent;

  @override
  int get hashCode => Object.hash(start, extent);
}

/// Indicator that stretches like a drop towards its destination: the leading
/// edge races ahead, the body thins, then it settles with a small rebound
/// (560 ms). Must be a direct child of a [Stack].
class ElasticIndicator extends StatefulWidget {
  const ElasticIndicator({
    super.key,
    required this.span,
    required this.child,
    this.axis = Axis.horizontal,
    this.crossStart,
    this.crossEnd,
    this.crossExtent,
  });

  final IndicatorSpan? span;
  final Widget child;
  final Axis axis;

  /// Cross-axis placement, as in [Positioned].
  final double? crossStart;
  final double? crossEnd;
  final double? crossExtent;

  @override
  State<ElasticIndicator> createState() => _ElasticIndicatorState();
}

class _ElasticIndicatorState extends State<ElasticIndicator>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: OngakuMotion.indicator,
  );
  IndicatorSpan? _from;

  @override
  void didUpdateWidget(ElasticIndicator old) {
    super.didUpdateWidget(old);
    if (old.span != widget.span && old.span != null && widget.span != null) {
      _from = _current(old.span!);
      if (OngakuMotionSettings.reducedOf(context)) {
        _c.value = 1;
      } else {
        _c.forward(from: 0);
      }
    }
  }

  IndicatorSpan _current(IndicatorSpan fallbackTo) {
    if (_from == null || !_c.isAnimating) return fallbackTo;
    return _lerp(_from!, fallbackTo, _c.value).$1;
  }

  (IndicatorSpan, double) _lerp(IndicatorSpan a, IndicatorSpan b, double t) {
    final forward = b.start >= a.start;
    final lead = Curves.easeOutCubic.transform(t);
    final trail = const Interval(
      0.12,
      1,
      curve: OngakuMotion.stretch,
    ).transform(t);
    double l(double x, double y, double k) => x + (y - x) * k;
    final start = l(a.start, b.start, forward ? trail : lead);
    final end = l(a.end, b.end, forward ? lead : trail);
    // Thin in the middle of the trip, rebound slightly after.
    final cross =
        1 -
        0.28 * math.sin(math.pi * math.min(1, t / 0.78)) +
        (t > 0.6 ? 0.08 * math.sin(math.pi * (t - 0.6) / 0.4) : 0);
    return (IndicatorSpan(start, math.max(0, end - start)), cross);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final span = widget.span;
    if (span == null) return const Positioned(child: SizedBox.shrink());
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final (s, cross) = _from == null || _c.isCompleted || _c.value == 0
            ? (span, 1.0)
            : _lerp(_from!, span, _c.value);
        final scaled = Transform(
          alignment: Alignment.center,
          transform: widget.axis == Axis.horizontal
              ? Matrix4.diagonal3Values(1, cross, 1)
              : Matrix4.diagonal3Values(cross, 1, 1),
          child: child,
        );
        return widget.axis == Axis.horizontal
            ? Positioned(
                left: s.start,
                width: s.extent,
                top: widget.crossStart,
                bottom: widget.crossEnd,
                height: widget.crossExtent,
                child: scaled,
              )
            : Positioned(
                top: s.start,
                height: s.extent,
                left: widget.crossStart,
                right: widget.crossEnd,
                width: widget.crossExtent,
                child: scaled,
              );
      },
    );
  }
}

/// Measures children laid out in a [Stack] so an [ElasticIndicator] can
/// follow the selected one.
mixin IndicatorMeasure<T extends StatefulWidget> on State<T> {
  final stackKey = GlobalKey();
  final Map<Object, GlobalKey> itemKeys = {};
  IndicatorSpan? indicatorSpan;

  GlobalKey keyFor(Object id) => itemKeys.putIfAbsent(id, GlobalKey.new);

  void measure(Object? selected, {Axis axis = Axis.horizontal}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final stackBox =
          stackKey.currentContext?.findRenderObject() as RenderBox?;
      final itemBox = selected == null
          ? null
          : itemKeys[selected]?.currentContext?.findRenderObject()
                as RenderBox?;
      IndicatorSpan? next;
      if (stackBox != null && itemBox != null && itemBox.hasSize) {
        final o = itemBox.localToGlobal(Offset.zero, ancestor: stackBox);
        next = axis == Axis.horizontal
            ? IndicatorSpan(o.dx, itemBox.size.width)
            : IndicatorSpan(o.dy, itemBox.size.height);
      }
      if (next != indicatorSpan) setState(() => indicatorSpan = next);
    });
  }
}
