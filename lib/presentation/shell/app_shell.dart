import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../models/player_snapshot.dart';
import '../../providers/demo_providers.dart';
import '../../providers/library_providers.dart';
import '../../providers/player_providers.dart';
import '../../providers/ui_providers.dart';
import '../../shared/design_system/design_system.dart';
import '../common/track_actions.dart';
import '../queue/queue_view.dart';
import 'player_bar.dart';

/// Navigation skeleton with two shapes: on PC the three zones (sidebar,
/// content, optional queue) over the player bar; on Android, content with a
/// floating mini-player above bottom tabs.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compact = OngakuBreakpoints.isCompact(context);
    final online = ref.watch(backendOnlineProvider);
    _listenPlayer(context, ref);
    final current = NavDestination.fromLocation(location);
    void navigate(NavDestination d) => context.go(d.path);

    final content = Column(
      children: [
        if (!online)
          Padding(
            padding: EdgeInsets.fromLTRB(
              OngakuSpacing.pagePadding(MediaQuery.sizeOf(context).width),
              16,
              OngakuSpacing.pagePadding(MediaQuery.sizeOf(context).width),
              0,
            ),
            child: OfflineBanner(onReview: () => context.go(Routes.settings)),
          ),
        Expanded(child: child),
      ],
    );

    final body = compact
        ? Column(
            children: [
              Expanded(child: SafeArea(bottom: false, child: content)),
              const MiniPlayer(),
              OngakuTabBar(current: current, onNavigate: navigate),
            ],
          )
        : Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    OngakuSidebar(
                      current: current,
                      onNavigate: navigate,
                      online: online,
                      onBrand: () => context.go(Routes.home),
                      playlists: [
                        for (final p
                            in ref.watch(libraryProvider).ownedPlaylists)
                          SidebarPlaylist(
                            id: p.id,
                            name: p.name,
                            coverUrl: p.covers.firstOrNull,
                          ),
                      ],
                      onPlaylist: (id) => context.go(Routes.playlist(id)),
                    ),
                    Expanded(child: content),
                    const _QueuePanel(),
                  ],
                ),
              ),
              const PlayerBar(),
            ],
          );

    return _Shortcuts(child: Scaffold(body: body));
  }
}

/// RNF-12 and end of queue: tell the user, offer "Repetir".
void _listenPlayer(BuildContext context, WidgetRef ref) {
  ref.listen(playerProvider.select((s) => s.status), (prev, status) {
    final s = ref.read(playerProvider);
    if (status == PlaybackStatus.error && s.error != null) {
      showOngakuToast(
        context,
        s.error!.message ?? s.error!.code.description,
        error: true,
        duration: const Duration(milliseconds: 2600),
      );
    }
    if (status == PlaybackStatus.completed &&
        prev != PlaybackStatus.completed) {
      showOngakuToast(
        context,
        'Terminó la cola',
        actionLabel: 'Repetir',
        onAction: () => ref.read(playerProvider.notifier).jumpTo(0),
      );
    }
  });
}

class _QueuePanel extends ConsumerWidget {
  const _QueuePanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.watch(queuePanelOpenProvider);
    final c = context.colors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: OngakuMotion.ease,
      width: open ? OngakuSpacing.queuePanel : 0,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: open ? c.border : Colors.transparent),
        ),
      ),
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.centerLeft,
          minWidth: OngakuSpacing.queuePanel,
          maxWidth: OngakuSpacing.queuePanel,
          child: const QueueView(padding: EdgeInsets.fromLTRB(14, 20, 14, 40)),
        ),
      ),
    );
  }
}

/// PC shortcuts: Space play/pause, Ctrl+F search, Ctrl+→/← next/previous,
/// Ctrl+L favorite.
class _Shortcuts extends ConsumerWidget {
  const _Shortcuts({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.read(playerProvider.notifier);
    void fav() {
      final t = ref.read(currentTrackProvider);
      if (t != null) ref.toggleFavorite(context, t);
    }

    void search() {
      context.go(Routes.search);
      ref.read(searchFocusRequestProvider.notifier).request();
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.space): player.toggle,
        const SingleActivator(LogicalKeyboardKey.keyF, control: true): search,
        const SingleActivator(LogicalKeyboardKey.keyF, meta: true): search,
        const SingleActivator(LogicalKeyboardKey.arrowRight, control: true):
            player.next,
        const SingleActivator(LogicalKeyboardKey.arrowLeft, control: true):
            player.previous,
        const SingleActivator(LogicalKeyboardKey.keyL, control: true): fav,
        const SingleActivator(LogicalKeyboardKey.keyL, meta: true): fav,
      },
      child: Focus(autofocus: true, child: child),
    );
  }
}
