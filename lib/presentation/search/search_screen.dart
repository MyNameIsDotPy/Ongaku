import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../models/playlist.dart';
import '../../models/search_results.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/demo_providers.dart';
import '../../providers/player_providers.dart';
import '../../providers/search_providers.dart';
import '../../providers/ui_providers.dart';
import '../../shared/design_system/design_system.dart';
import '../common/async_states.dart';
import '../common/media_cards.dart';
import '../common/ongaku_page.dart';
import '../common/retry.dart';
import '../common/track_actions.dart';
import '../common/track_list.dart';

/// Búsqueda (RF-01–03, RF-06): suggestions while typing (keyboard
/// navigable), removable recents, results filterable by type, and YouTube
/// playlist links detected with a preview card.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final _controller = TextEditingController(
    text: ref.read(searchQueryProvider),
  );
  final _focus = FocusNode();
  int _highlight = -1;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !OngakuBreakpoints.isCompact(context)) {
        _focus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    ref.read(searchQueryProvider.notifier).set(v);
    setState(() {
      _highlight = -1;
      _showSuggestions = true;
    });
  }

  void _commit(String v) {
    _controller.value = TextEditingValue(
      text: v,
      selection: TextSelection.collapsed(offset: v.length),
    );
    ref.read(searchQueryProvider.notifier).set(v);
    ref.read(recentSearchesProvider.notifier).add(v);
    setState(() {
      _showSuggestions = false;
      _highlight = -1;
    });
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent e, List<String> suggestions) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (!_showSuggestions || suggestions.isEmpty) return KeyEventResult.ignored;
    final k = e.logicalKey;
    if (k == LogicalKeyboardKey.arrowDown || k == LogicalKeyboardKey.arrowUp) {
      setState(
        () => _highlight =
            (_highlight +
                (k == LogicalKeyboardKey.arrowDown ? 1 : -1) +
                suggestions.length) %
            suggestions.length,
      );
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.enter && _highlight >= 0) {
      _commit(suggestions[_highlight]);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.escape) {
      setState(() => _showSuggestions = false);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(searchFocusRequestProvider, (_, _) => _focus.requestFocus());
    // Keep the field in sync when the query changes from elsewhere.
    ref.listen(searchQueryProvider, (_, q) {
      if (_controller.text != q) {
        _controller.value = TextEditingValue(
          text: q,
          selection: TextSelection.collapsed(offset: q.length),
        );
      }
    });
    final c = context.colors;
    final online = ref.watch(backendOnlineProvider);
    final query = ref.watch(searchQueryProvider);
    final suggestions = ref.watch(suggestionsProvider).value ?? const [];

    final field = Focus(
      onKeyEvent: (n, e) => _onKey(n, e, suggestions),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: TextField(
          controller: _controller,
          focusNode: _focus,
          enabled: online,
          onChanged: _onChanged,
          onSubmitted: _commit,
          textInputAction: TextInputAction.search,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Canciones, artistas, álbumes o enlace de YouTube',
            hintStyle: TextStyle(color: c.muted, fontSize: 16),
            filled: true,
            fillColor: c.surface,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 18, right: 12),
              child: OngakuIcon(OngakuIcons.search, color: c.muted),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 50),
            suffixIcon: query.isEmpty
                ? null
                : Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: OngakuIconButton(
                      icon: OngakuIcons.close,
                      tooltip: 'Borrar búsqueda',
                      onPressed: () {
                        _controller.clear();
                        _onChanged('');
                        _focus.requestFocus();
                      },
                    ),
                  ),
            border: OutlineInputBorder(
              borderRadius: OngakuRadii.pillAll,
              borderSide: BorderSide(color: c.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: OngakuRadii.pillAll,
              borderSide: BorderSide(color: c.border),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: OngakuRadii.pillAll,
              borderSide: BorderSide(color: c.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: OngakuRadii.pillAll,
              borderSide: BorderSide(color: c.fg),
            ),
          ),
        ),
      ),
    );

    final showSuggest =
        _showSuggestions &&
        _focus.hasFocus &&
        suggestions.isNotEmpty &&
        query.trim().isNotEmpty;

    return OngakuPage(
      slivers: [
        const PageSection(child: PageHeader('Buscar')),
        PageSection(
          index: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              field,
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: OngakuMotion.ease,
                child: showSuggest
                    ? _Suggestions(
                        items: suggestions,
                        query: query,
                        highlight: _highlight,
                        onPick: _commit,
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
        if (!online)
          PageSection(
            index: 2,
            top: OngakuSpacing.block,
            child: EmptyState(
              icon: OngakuIcons.offline,
              title: 'La búsqueda necesita el backend',
              message:
                  'Mientras tanto puedes escuchar tus descargas y la biblioteca guardada en caché.',
              action: OngakuButton(
                label: 'Ver descargas',
                onPressed: () => context.go(Routes.libraryTab('descargas')),
              ),
            ),
          )
        else if (query.trim().isEmpty)
          ..._landing(context)
        else if (ref.watch(pastedPlaylistIdProvider) != null)
          const PageSection(index: 2, top: 18, child: _YoutubeLinkCard())
        else
          const _Results(),
      ],
    );
  }

  List<Widget> _landing(BuildContext context) {
    final recents = ref.watch(recentSearchesProvider);
    final explore = ref.watch(exploreProvider);
    final c = context.colors;
    return [
      PageSection(
        index: 2,
        top: OngakuSpacing.block,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              'Búsquedas recientes',
              actionLabel: recents.isEmpty ? null : 'Borrar todas',
              onAction: ref.read(recentSearchesProvider.notifier).clear,
            ),
            if (recents.isEmpty)
              Text(
                'Sin búsquedas recientes.',
                style: TextStyle(fontSize: 13, color: c.muted),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < recents.length; i++)
                    OngakuChip(
                      label: recents[i],
                      onTap: () => _commit(recents[i]),
                      onRemove: () =>
                          ref.read(recentSearchesProvider.notifier).removeAt(i),
                      removeLabel: 'Quitar ${recents[i]}',
                    ),
                ],
              ),
            const SizedBox(height: 28),
            Row(
              children: [
                OngakuIcon(OngakuIcons.link, size: 18, color: c.muted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'También puedes pegar el enlace de una playlist pública de YouTube para importarla.',
                    style: TextStyle(fontSize: 13, color: c.muted),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      // Nothing to browse without a catalog (YouTube mode): hide it.
      if (explore.value?.isNotEmpty ?? true)
        PageSection(
          index: 3,
          top: OngakuSpacing.block,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader('Explorar tu catálogo'),
              switch (explore) {
                AsyncData(:final value) => CardGrid(
                  children: [for (final a in value) AlbumCard(album: a)],
                ),
                AsyncError(:final error) => ApiErrorView(
                  error: error,
                  onRetry: () => retry(ref, [exploreProvider]),
                ),
                _ => const RowSkeleton(),
              },
            ],
          ),
        ),
    ];
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({
    required this.items,
    required this.query,
    required this.highlight,
    required this.onPick,
  });

  final List<String> items;
  final String query;
  final int highlight;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final q = query.trim().toLowerCase();
    return Container(
      constraints: const BoxConstraints(maxWidth: 640),
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: OngakuRadii.tileAll,
        border: Border.all(color: c.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 40,
            offset: Offset(0, 20),
            spreadRadius: -20,
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++)
            OngakuPressable(
              onTap: () => onPick(items[i]),
              color: i == highlight ? c.fgSoft2 : null,
              hoverColor: c.fgSoft2,
              borderRadius: OngakuRadii.smAll,
              child: SizedBox(
                height: 44,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      OngakuIcon(OngakuIcons.search, size: 18, color: c.muted),
                      const SizedBox(width: 12),
                      Expanded(child: _highlighted(items[i], q, c)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _highlighted(String s, String q, OngakuColors c) {
    final i = s.toLowerCase().indexOf(q);
    if (q.isEmpty || i < 0) {
      return Text(s, maxLines: 1, overflow: TextOverflow.ellipsis);
    }
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: s.substring(0, i)),
          TextSpan(
            text: s.substring(i, i + q.length),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: s.substring(i + q.length)),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: c.fg, fontSize: 15),
    );
  }
}

/// RF-06: a pasted YouTube playlist link offers a preview.
class _YoutubeLinkCard extends ConsumerWidget {
  const _YoutubeLinkCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final id = ref.watch(pastedPlaylistIdProvider)!;
    final Playlist p;
    switch (ref.watch(remotePlaylistProvider(id))) {
      case AsyncData(:final value):
        p = value;
      case AsyncError(:final error):
        return ApiErrorView(
          error: error,
          onRetry: () => retry(ref, [remotePlaylistProvider(id)]),
        );
      default:
        return const RowSkeleton();
    }
    return CustomPaint(
      painter: _DashPainter(Color.lerp(c.border, c.fg, 0.35)!),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OngakuCover(urls: p.covers, size: 64, radius: OngakuRadii.md),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 200, maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const OngakuTag(
                    'Playlist de YouTube detectada',
                    icon: OngakuIcons.link,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '${plural(p.tracks.length, 'canción', 'canciones')} · '
                    '${formatLong(p.totalDuration)} · ${p.owner ?? 'YouTube'}',
                    style: TextStyle(fontSize: 13, color: c.muted),
                  ),
                ],
              ),
            ),
            OngakuButton(
              label: 'Ver vista previa',
              onPressed: () => context.go(Routes.playlist(p.id)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(0.5),
          const Radius.circular(14),
        ),
      );
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke;
    for (final m in path.computeMetrics()) {
      for (double d = 0; d < m.length; d += 8) {
        canvas.drawPath(m.extractPath(d, d + 4), p);
      }
    }
  }

  @override
  bool shouldRepaint(_DashPainter o) => o.color != color;
}

class _Results extends ConsumerWidget {
  const _Results();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider);
    return switch (results) {
      AsyncError(:final error) => PageSection(
        top: OngakuSpacing.block,
        child: ApiErrorView(
          error: error,
          onRetry: () => retry(ref, [searchResultsProvider]),
        ),
      ),
      AsyncData(:final value) when !results.isLoading =>
        value.isEmpty
            ? PageSection(
                top: OngakuSpacing.block,
                child: EmptyState(
                  icon: OngakuIcons.search,
                  title: 'Sin resultados para “${query.trim()}”',
                  message:
                      'Revisa la ortografía o prueba con el nombre del artista.',
                ),
              )
            : _ResultsBody(results: value),
      _ => const PageSection(
        top: 24,
        child: Column(children: [RowSkeleton(), RowSkeleton(), RowSkeleton()]),
      ),
    };
  }
}

class _ResultsBody extends ConsumerWidget {
  const _ResultsBody({required this.results});

  final SearchResults results;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(searchFilterProvider);
    final r = results;
    final chips = PageSection(
      top: 20,
      child: Semantics(
        label: 'Filtrar por tipo',
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final f in SearchFilter.values)
              OngakuChip(
                label: f.label,
                selected: f == filter,
                onTap: () => ref.read(searchFilterProvider.notifier).set(f),
              ),
          ],
        ),
      ),
    );
    Widget grid(List<Widget> cards, String none) => PageSection(
      top: 20,
      child: cards.isEmpty
          ? Text(
              none,
              style: TextStyle(color: context.colors.muted, fontSize: 13),
            )
          : CardGrid(children: cards),
    );

    return SliverMainAxisGroup(
      slivers: [
        chips,
        ...switch (filter) {
          SearchFilter.all => [
            // Only playlists matched: skip the top-result block.
            if (r.artists.isNotEmpty ||
                r.albums.isNotEmpty ||
                r.tracks.isNotEmpty)
              PageSection(top: 20, child: _TopAndSongs(results: r)),
            if (r.albums.isNotEmpty)
              PageSection(
                top: OngakuSpacing.block,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SectionHeader('Álbumes'),
                    CardGrid(
                      children: [for (final a in r.albums) AlbumCard(album: a)],
                    ),
                  ],
                ),
              ),
            if (r.playlists.isNotEmpty)
              PageSection(
                top: OngakuSpacing.block,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SectionHeader('Playlists'),
                    CardGrid(
                      children: [
                        for (final p in r.playlists) PlaylistCard(playlist: p),
                      ],
                    ),
                  ],
                ),
              ),
          ],
          SearchFilter.songs => [
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            TrackListSliver(tracks: r.tracks, source: 'Búsqueda'),
          ],
          SearchFilter.albums => [
            grid([
              for (final a in r.albums) AlbumCard(album: a),
            ], 'Sin álbumes.'),
          ],
          SearchFilter.artists => [
            grid([
              for (final a in r.artists) ArtistCard(artist: a),
            ], 'Sin artistas.'),
          ],
          SearchFilter.playlists => [
            grid([
              for (final p in r.playlists) PlaylistCard(playlist: p),
            ], 'Sin playlists propias con ese nombre.'),
          ],
        },
      ],
    );
  }
}

/// "Mejor resultado" card beside the first four songs.
class _TopAndSongs extends ConsumerWidget {
  const _TopAndSongs({required this.results});

  final SearchResults results;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = results;
    final c = context.colors;
    final player = ref.read(playerProvider.notifier);
    late final String kind, title, cover, route;
    late final VoidCallback play;
    if (r.artists.isNotEmpty) {
      final a = r.artists.first;
      (kind, title, cover, route) = (
        'Artista',
        a.name,
        a.avatarUrl ?? a.albums.firstOrNull?.coverUrl ?? '',
        Routes.artist(a.id),
      );
      // Search results carry no songs: load the artist, then start radio.
      play = () async {
        final full = a.popular.isNotEmpty
            ? a
            : await ref.read(artistProvider(a.id).future);
        if (full.popular.isNotEmpty && context.mounted) {
          await ref.startRadio(context, full.popular.first);
        }
      };
    } else if (r.albums.isNotEmpty) {
      final a = r.albums.first;
      (kind, title, cover, route) = (
        'Álbum',
        a.title,
        a.coverUrl,
        Routes.album(a.id),
      );
      play = () => a.tracks.isNotEmpty
          ? player.play(a.tracks, from: a.title)
          : playAlbumById(context, ref, a.id);
    } else {
      final t = r.tracks.first;
      (kind, title, cover, route) = (
        'Canción',
        t.title,
        t.coverUrl,
        t.album != null
            ? Routes.album(t.album!.id)
            : Routes.artist(t.primaryArtist.id),
      );
      play = () => player.play([t], from: 'Búsqueda');
    }

    final top = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader('Mejor resultado'),
        OngakuPressable(
          onTap: () => context.go(route),
          color: c.fgSoft,
          hoverColor: c.fgSoft,
          borderRadius: OngakuRadii.lgAll,
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x66000000),
                          blurRadius: 24,
                          offset: Offset(0, 12),
                          spreadRadius: -12,
                        ),
                      ],
                    ),
                    child: OngakuCover.single(
                      cover,
                      size: 96,
                      radius: OngakuRadii.md,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: context.text.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  OngakuTag(kind),
                ],
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: HoverPlayButton(
                  onPressed: play,
                  label: 'Reproducir $title',
                ),
              ),
            ],
          ),
        ),
      ],
    );
    final songs = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader('Canciones'),
        if (r.tracks.isEmpty)
          Text('Sin canciones.', style: TextStyle(color: c.muted, fontSize: 13))
        else
          for (var i = 0; i < r.tracks.length && i < 4; i++)
            ConnectedTrackRow(
              track: r.tracks[i],
              index: i,
              showAlbum: false,
              onPlay: () => player.play(r.tracks, start: i, from: 'Búsqueda'),
            ),
      ],
    );
    if (OngakuBreakpoints.isCompact(context)) {
      return Column(children: [top, const SizedBox(height: 24), songs]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 10, child: top),
        const SizedBox(width: 24),
        Expanded(flex: 14, child: songs),
      ],
    );
  }
}
