import 'package:flutter/material.dart';

import '../atoms/atoms.dart';
import '../tokens/tokens.dart';

/// Ink toast (`.toast`) with an optional action ("Deshacer", "Ver", "Abrir").
/// Uses the root messenger so it survives navigation.
void showOngakuToast(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
  bool error = false,
  Duration duration = const Duration(milliseconds: 3200),
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  final c = context.colors;
  final size = MediaQuery.sizeOf(context);
  final compact = size.width <= OngakuBreakpoints.compact;
  final width = compact ? size.width - 24 : 440.0;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: error ? c.onAccent : c.bg,
            fontSize: 14,
            height: 1.3,
          ),
        ),
        backgroundColor: error ? c.err : c.fg,
        duration: duration,
        margin: EdgeInsets.fromLTRB(
          (size.width - width) / 2,
          0,
          (size.width - width) / 2,
          compact ? 150 : OngakuSpacing.playerBar + 16,
        ),
        action: actionLabel == null
            ? null
            : SnackBarAction(
                label: actionLabel,
                textColor: error ? c.onAccent : c.bg,
                onPressed: onAction ?? () {},
              ),
      ),
    );
}

/// Dialog shell (`.dialog`): 420 wide, 22 padding, title + optional subtitle.
Future<T?> showOngakuDialog<T>(
  BuildContext context, {
  required String title,
  String? subtitle,
  required Widget Function(BuildContext) builder,
}) {
  return showDialog<T>(
    context: context,
    builder: (ctx) {
      final c = ctx.colors;
      return Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: ctx.text.headlineSmall),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: c.muted),
                  ),
                ],
                const SizedBox(height: 14),
                Flexible(child: builder(ctx)),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Right-aligned dialog buttons.
class DialogActions extends StatelessWidget {
  const DialogActions({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 18),
    child: Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: children,
    ),
  );
}

/// One option in an [showOngakuMenu]. `null` entries render as dividers.
class OngakuMenuItem<T> {
  const OngakuMenuItem(this.value, this.icon, this.label, {this.solid = false});

  final T value;
  final OngakuIcons icon;
  final String label;
  final bool solid;
}

/// Contextual menu: anchored popup on desktop, bottom sheet on phones.
Future<T?> showOngakuMenu<T>(
  BuildContext anchor,
  List<OngakuMenuItem<T>?> items, {
  String? title,
}) {
  final c = anchor.colors;
  if (OngakuBreakpoints.isCompact(anchor)) {
    return showModalBottomSheet<T>(
      context: anchor,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ctx.text.titleMedium,
                  ),
                ),
              for (final it in items)
                if (it == null)
                  Divider(color: c.border, height: 13, indent: 4, endIndent: 4)
                else
                  _MenuTile(
                    item: it,
                    onTap: () => Navigator.pop(ctx, it.value),
                    height: 48,
                  ),
            ],
          ),
        ),
      ),
    );
  }
  final box = anchor.findRenderObject()! as RenderBox;
  final overlay =
      Navigator.of(
            anchor,
            rootNavigator: true,
          ).overlay!.context.findRenderObject()!
          as RenderBox;
  final rect = RelativeRect.fromRect(
    Rect.fromPoints(
      box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
    ),
    Offset.zero & overlay.size,
  );
  return showMenu<T>(
    context: anchor,
    position: rect,
    useRootNavigator: true,
    menuPadding: const EdgeInsets.all(6),
    constraints: const BoxConstraints(minWidth: 236),
    items: [
      for (final it in items)
        if (it == null)
          const PopupMenuDivider(height: 13)
        else
          PopupMenuItem<T>(
            value: it.value,
            height: 40,
            padding: EdgeInsets.zero,
            child: _MenuTile(item: it, height: 40),
          ),
    ],
  );
}

class _MenuTile<T> extends StatelessWidget {
  const _MenuTile({required this.item, this.onTap, required this.height});

  final OngakuMenuItem<T> item;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final row = SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            OngakuIcon(item.icon, solid: item.solid, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(item.label, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
    if (onTap == null) return row;
    return OngakuPressable(
      onTap: onTap,
      hoverColor: context.colors.fgSoft2,
      borderRadius: OngakuRadii.smAll,
      child: row,
    );
  }
}
