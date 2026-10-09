import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/album/album_screen.dart';
import '../presentation/artist/artist_screen.dart';
import '../presentation/connection/connection_screen.dart';
import '../presentation/home/home_screen.dart';
import '../presentation/library/library_screen.dart';
import '../presentation/player/now_playing_screen.dart';
import '../presentation/playlist/playlist_screen.dart';
import '../presentation/search/search_screen.dart';
import '../presentation/settings/settings_screen.dart';
import '../presentation/shell/app_shell.dart';
import '../providers/settings_providers.dart';
import '../shared/design_system/design_system.dart';
import 'routes.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

/// Views inside the shell fade through (old out, then new in, so text never
/// overlaps); their sections then rise in staggered, and card artwork flies
/// into the detail header (Hero).
Page<void> _view(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      // The solid background goes under the fade: while the new view fades
      // in, the previous view is still painted underneath, and it must stay
      // hidden instead of showing through.
      transitionsBuilder: (context, animation, _, child) => ColoredBox(
        color: context.colors.bg,
        child: fadeThrough(animation, child),
      ),
    );

final routerProvider = Provider<GoRouter>((ref) {
  final onboarded = ValueNotifier(
    ref.read(settingsProvider).onboardingComplete,
  );
  ref
    ..listen(
      settingsProvider.select((s) => s.onboardingComplete),
      (_, v) => onboarded.value = v,
    )
    ..onDispose(onboarded.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.home,
    refreshListenable: onboarded,
    redirect: (context, state) {
      final atConnection = state.matchedLocation == Routes.connection;
      if (!onboarded.value && !atConnection) return Routes.connection;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.connection,
        builder: (context, state) => const ConnectionScreen(),
      ),
      GoRoute(
        path: Routes.nowPlaying,
        parentNavigatorKey: _rootKey,
        // The player is a sheet that rises from the mini-player (600 ms).
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const NowPlayingScreen(),
          transitionDuration: OngakuMotion.sheet,
          reverseTransitionDuration: const Duration(milliseconds: 450),
          transitionsBuilder: (context, animation, _, child) => SlideTransition(
            position: Tween(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: OngakuMotion.ease,
                    reverseCurve: Curves.easeInCubic,
                  ),
                ),
            child: child,
          ),
        ),
      ),
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (context, state, child) =>
            AppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            pageBuilder: (context, state) => _view(state, const HomeScreen()),
          ),
          GoRoute(
            path: Routes.search,
            pageBuilder: (context, state) => _view(state, const SearchScreen()),
          ),
          GoRoute(
            path: Routes.library,
            pageBuilder: (context, state) =>
                _view(state, const LibraryScreen(tab: LibraryTab.playlists)),
            routes: [
              GoRoute(
                path: ':tab',
                // Same page key across tabs: only the body swaps, the
                // indicator stretches instead of the page cross-fading.
                pageBuilder: (context, state) => NoTransitionPage(
                  key: const ValueKey('library-tabs'),
                  child: LibraryScreen(
                    tab: LibraryTab.fromSlug(state.pathParameters['tab']),
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: Routes.settings,
            pageBuilder: (context, state) =>
                _view(state, const SettingsScreen()),
          ),
          GoRoute(
            path: '/album/:id',
            pageBuilder: (context, state) =>
                _view(state, AlbumScreen(albumId: state.pathParameters['id']!)),
          ),
          GoRoute(
            path: '/artista/:id',
            pageBuilder: (context, state) => _view(
              state,
              ArtistScreen(artistId: state.pathParameters['id']!),
            ),
          ),
          GoRoute(
            path: '/playlist/:id',
            pageBuilder: (context, state) => _view(
              state,
              PlaylistScreen(playlistId: state.pathParameters['id']!),
            ),
          ),
        ],
      ),
    ],
  );
});
