import 'package:flutter/material.dart';

import '../atoms/ongaku_icon.dart';
import '../tokens/tokens.dart';
import 'section_header.dart';

/// Discreet notice shown when the backend does not answer (RF-29).
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, this.onReview});

  final VoidCallback? onReview;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Color.alphaBlend(c.warn.withValues(alpha: 0.12), c.surface),
          borderRadius: OngakuRadii.mdAll,
          border: Border.all(color: Color.lerp(c.warn, c.border, 0.5)!),
        ),
        child: Row(
          children: [
            OngakuIcon(OngakuIcons.offline, color: c.fg),
            const SizedBox(width: 10),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Sin conexión al backend. ',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const TextSpan(
                      text:
                          'Tienes disponibles la biblioteca en caché y las descargas.',
                    ),
                  ],
                ),
                style: TextStyle(fontSize: 14, color: c.fg),
              ),
            ),
            if (onReview != null) ...[
              const SizedBox(width: 10),
              QuietLink('Revisar', onTap: onReview),
            ],
          ],
        ),
      ),
    );
  }
}

/// Dot + label for the sidebar footer.
class ConnectionIndicator extends StatelessWidget {
  const ConnectionIndicator({super.key, required this.online, this.label});

  final bool online;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dot = online ? c.ok : c.err;
    return Semantics(
      liveRegion: true,
      label: online ? 'Conectado al backend' : 'Sin conexión al backend',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: dot,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: dot.withValues(alpha: 0.2), spreadRadius: 3),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label ?? (online ? 'Conectado · homelab' : 'Sin conexión'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: c.muted),
            ),
          ),
        ],
      ),
    );
  }
}

/// `.status`: check / cross with a message, or a spinner while running.
class StatusLabel extends StatelessWidget {
  const StatusLabel({super.key, required this.ok, required this.label});

  final bool ok;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = ok ? c.ok : c.err;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OngakuIcon(
          ok ? OngakuIcons.check : OngakuIcons.close,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
