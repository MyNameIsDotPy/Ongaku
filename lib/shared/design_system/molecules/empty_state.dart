import 'package:flutter/material.dart';

import '../atoms/ongaku_button.dart';
import '../atoms/ongaku_icon.dart';
import '../tokens/tokens.dart';

/// Empty state with a suggested action (`.empty`): dashed frame, round icon.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.iconColor,
    this.mono = false,
  });

  final OngakuIcons icon;
  final String title;
  final String message;
  final Widget? action;
  final Color? iconColor;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return CustomPaint(
      painter: _DashedBorder(c.border),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: c.fgSoft2,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: OngakuIcon(icon, color: iconColor ?? c.fg),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: context.text.titleLarge,
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: mono
                      ? OngakuTypography.mono(context)
                      : context.text.bodyMedium?.copyWith(color: c.muted),
                ),
              ),
              if (action != null) ...[const SizedBox(height: 18), action!],
            ],
          ),
        ),
      ),
    );
  }
}

/// Error with retry; shows the API error code in mono.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.code,
    required this.message,
    required this.onRetry,
    this.title = 'No pudimos cargar esto',
  });

  final String code;
  final String message;
  final String title;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => EmptyState(
    icon: OngakuIcons.offline,
    iconColor: context.colors.err,
    title: title,
    message: '$code · $message',
    mono: true,
    action: OngakuButton(
      label: 'Reintentar',
      icon: OngakuIcons.retry,
      onPressed: onRetry,
    ),
  );
}

class _DashedBorder extends CustomPainter {
  _DashedBorder(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(0.5),
          const Radius.circular(18),
        ),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke;
    for (final metric in path.computeMetrics()) {
      for (double d = 0; d < metric.length; d += 9) {
        canvas.drawPath(metric.extractPath(d, d + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorder o) => o.color != color;
}
