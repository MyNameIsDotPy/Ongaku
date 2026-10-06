import 'package:flutter/material.dart';

import '../../shared/design_system/design_system.dart';

/// Scrollable view body (`.view`): responsive padding, 1240 max width, an
/// optional cover-colored tint and sections that rise in staggered.
class OngakuPage extends StatelessWidget {
  const OngakuPage({
    super.key,
    required this.slivers,
    this.tint,
    this.controller,
  });

  final List<Widget> slivers;
  final Color? tint;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final pad = OngakuSpacing.pagePadding(width);
    final compact = OngakuBreakpoints.isCompact(context);
    return Stack(
      children: [
        Positioned(left: 0, right: 0, top: 0, child: DetailTint(color: tint)),
        CustomScrollView(
          controller: controller,
          slivers: [
            SliverLayoutBuilder(
              builder: (context, constraints) {
                // Left-aligned, capped at the content max width.
                final extra =
                    (constraints.crossAxisExtent -
                            2 * pad -
                            OngakuSpacing.contentMax)
                        .clamp(0.0, double.infinity);
                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    pad,
                    compact ? 20 : 28,
                    pad + extra,
                    64,
                  ),
                  sliver: SliverMainAxisGroup(slivers: slivers),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

/// A box section of an [OngakuPage]; [index] staggers its entrance.
class PageSection extends StatelessWidget {
  const PageSection({
    super.key,
    required this.child,
    this.index = 0,
    this.top = 0,
  });

  final Widget child;
  final int index;
  final double top;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: Padding(
      padding: EdgeInsets.only(top: top),
      child: RiseIn(index: index, child: child),
    ),
  );
}

/// Loading skeleton for detail pages: hero block + seven rows.
class DetailSkeleton extends StatelessWidget {
  const DetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final compact = OngakuBreakpoints.isCompact(context);
    return Semantics(
      label: 'Cargando',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (compact)
            const Column(
              children: [
                OngakuSkeleton(width: 200, height: 200, radius: 14),
                SizedBox(height: 20),
                _HeroTextSkeleton(center: true),
              ],
            )
          else
            const Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                OngakuSkeleton(width: 200, height: 200, radius: 14),
                SizedBox(width: 28),
                Expanded(child: _HeroTextSkeleton()),
              ],
            ),
          const SizedBox(height: 32),
          for (var i = 0; i < 7; i++) const RowSkeleton(),
        ],
      ),
    );
  }
}

class _HeroTextSkeleton extends StatelessWidget {
  const _HeroTextSkeleton({this.center = false});

  final bool center;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: center
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start,
    children: const [
      FractionallySizedBox(widthFactor: 0.3, child: OngakuSkeleton(height: 14)),
      SizedBox(height: 14),
      FractionallySizedBox(widthFactor: 0.6, child: OngakuSkeleton(height: 44)),
      SizedBox(height: 14),
      FractionallySizedBox(widthFactor: 0.4, child: OngakuSkeleton(height: 14)),
    ],
  );
}

class RowSkeleton extends StatelessWidget {
  const RowSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(8),
    child: Row(
      children: [
        OngakuSkeleton(width: 40, height: 40),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FractionallySizedBox(
                widthFactor: 0.4,
                child: OngakuSkeleton(height: 12),
              ),
              SizedBox(height: 8),
              FractionallySizedBox(
                widthFactor: 0.24,
                child: OngakuSkeleton(height: 10),
              ),
            ],
          ),
        ),
        OngakuSkeleton(width: 40, height: 12),
      ],
    ),
  );
}
