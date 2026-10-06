import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

/// `.view-head`: optional eyebrow, the screen title and trailing actions.
class PageHeader extends StatelessWidget {
  const PageHeader(this.title, {super.key, this.eyebrow, this.trailing});

  final String title;
  final String? eyebrow;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final compact = OngakuBreakpoints.isCompact(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.end,
        spacing: 16,
        runSpacing: 12,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (eyebrow != null) ...[
                Text(
                  eyebrow!.toUpperCase(),
                  style: OngakuTypography.eyebrow(context),
                ),
                const SizedBox(height: 10),
              ],
              Semantics(
                header: true,
                child: Text(
                  title,
                  style:
                      (compact
                              ? context.text.headlineMedium
                              : context.text.displayMedium)
                          ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          ?trailing,
        ],
      ),
    );
  }
}
