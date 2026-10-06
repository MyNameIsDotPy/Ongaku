import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../models/download_entry.dart';
import '../../models/playlist.dart';
import '../../models/track.dart';
import '../../providers/demo_providers.dart';
import '../../providers/download_providers.dart';
import '../../providers/library_providers.dart';
import '../../providers/player_providers.dart';
import '../../shared/design_system/design_system.dart';

/// Shared behaviors behind the song row and the player menus.
extension TrackActions on WidgetRef {
  Future<void> toggleFavorite(BuildContext context, Track track) async {
    final on = await read(libraryProvider.notifier).toggleFavorite(track);
    if (!context.mounted) return;
    showOngakuToast(
      context,
      on ? 'Agregada a favoritos' : 'Quitada de favoritos',
      actionLabel: 'Deshacer',
      onAction: () => read(libraryProvider.notifier).toggleFavorite(track),
    );
  }

  Future<void> startRadio(BuildContext context, Track seed) async {
    final n = await read(playerProvider.notifier).startRadio(seed);
    if (!context.mounted) return;
    showOngakuToast(
      context,
      'Radio de “${seed.title}” · $n canciones relacionadas',
    );
  }

  /// The eight-action context menu of a song row.
  Future<void> showTrackMenu(BuildContext anchor, Track track) async {
    final fav = read(isFavoriteProvider(track.videoId));
    final action = await showOngakuMenu<String>(anchor, [
      const OngakuMenuItem(
        'next',
        OngakuIcons.queue,
        'Reproducir a continuación',
      ),
      const OngakuMenuItem('queue', OngakuIcons.plus, 'Agregar a la cola'),
      const OngakuMenuItem('pl', OngakuIcons.library, 'Agregar a playlist…'),
      OngakuMenuItem(
        'fav',
        OngakuIcons.heart,
        fav ? 'Quitar de favoritos' : 'Agregar a favoritos',
        solid: fav,
      ),
      null,
      if (track.album != null)
        const OngakuMenuItem('album', OngakuIcons.album, 'Ir al álbum'),
      const OngakuMenuItem('artist', OngakuIcons.user, 'Ir al artista'),
      const OngakuMenuItem('radio', OngakuIcons.radio, 'Iniciar radio'),
      const OngakuMenuItem('dl', OngakuIcons.download, 'Descargar'),
    ], title: '${track.title} · ${track.artistNames}');
    if (!anchor.mounted || action == null) return;
    final player = read(playerProvider.notifier);
    switch (action) {
      case 'next':
        player.playNext(track);
        showOngakuToast(anchor, 'Sonará a continuación');
      case 'queue':
        player.addToQueue(track);
        showOngakuToast(anchor, 'Agregada a la cola');
      case 'pl':
        await addToPlaylist(anchor, track);
      case 'fav':
        await toggleFavorite(anchor, track);
      case 'album':
        anchor.go(Routes.album(track.album!.id));
      case 'artist':
        anchor.go(Routes.artist(track.primaryArtist.id));
      case 'radio':
        await startRadio(anchor, track);
      case 'dl':
        if (!read(backendOnlineProvider)) {
          showOngakuToast(
            anchor,
            'Sin conexión: no se puede descargar ahora',
            error: true,
          );
          return;
        }
        showOngakuToast(anchor, 'Descargando “${track.title}”…');
        await read(downloadsProvider.notifier).download(
          id: 'track-${track.videoId}',
          kind: DownloadKind.playlist,
          title: track.title,
          tracks: [track],
        );
    }
  }

  /// Flow 3: add to an existing or new playlist without leaving the screen.
  Future<void> addToPlaylist(BuildContext context, Track track) async {
    final own = read(
      libraryProvider,
    ).ownedPlaylists.where((p) => p.isOwn).toList();
    final picked = await showOngakuDialog<Object>(
      context,
      title: 'Agregar a playlist',
      subtitle: '${track.title} · ${track.artistNames}',
      builder: (ctx) {
        final c = ctx.colors;
        Widget option(Widget art, String title, String sub, Object value) =>
            OngakuPressable(
              onTap: () => Navigator.pop(ctx, value),
              hoverColor: c.fgSoft2,
              borderRadius: OngakuRadii.mdAll,
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  SizedBox.square(dimension: 44, child: art),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (sub.isNotEmpty)
                          Text(
                            sub,
                            style: TextStyle(fontSize: 13, color: c.muted),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    option(
                      Container(
                        decoration: BoxDecoration(
                          color: c.fgSoft2,
                          borderRadius: OngakuRadii.smAll,
                        ),
                        child: const Center(
                          child: OngakuIcon(OngakuIcons.plus),
                        ),
                      ),
                      'Nueva playlist',
                      '',
                      const _NewPlaylist(),
                    ),
                    for (final p in own)
                      option(
                        OngakuCover(urls: p.covers, radius: OngakuRadii.xs),
                        p.name,
                        p.tracks.any((t) => t.videoId == track.videoId)
                            ? 'Ya está en esta playlist'
                            : plural(p.tracks.length, 'canción', 'canciones'),
                        p,
                      ),
                  ],
                ),
              ),
            ),
            DialogActions(
              children: [
                OngakuButton.ghost(
                  label: 'Cancelar',
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ],
        );
      },
    );
    if (!context.mounted || picked == null) return;
    Playlist? target;
    if (picked is _NewPlaylist) {
      target = await createPlaylist(context, seed: [track], silent: true);
    } else {
      target = picked as Playlist;
      await read(libraryProvider.notifier).addToPlaylist(target.id, track);
    }
    if (target == null || !context.mounted) return;
    final id = target.id;
    showOngakuToast(
      context,
      'Agregada a “${target.name}”',
      actionLabel: 'Ver',
      onAction: () => context.go(Routes.playlist(id)),
    );
  }

  /// "Nueva playlist" dialog; returns the created playlist.
  Future<Playlist?> createPlaylist(
    BuildContext context, {
    List<Track> seed = const [],
    String initialName = '',
    bool silent = false,
  }) async {
    final name = await showOngakuDialog<String>(
      context,
      title: 'Nueva playlist',
      subtitle: 'Se sincroniza con tus otros dispositivos.',
      builder: (ctx) => _NameForm(initial: initialName, submitLabel: 'Crear'),
    );
    if (name == null || name.trim().isEmpty || !context.mounted) return null;
    final p = await read(
      libraryProvider.notifier,
    ).create(name.trim(), tracks: seed);
    if (!silent && context.mounted) {
      showOngakuToast(
        context,
        'Playlist “${p.name}” creada',
        actionLabel: 'Abrir',
        onAction: () => context.go(Routes.playlist(p.id)),
      );
    }
    return p;
  }

  Future<void> downloadCollection(
    BuildContext context, {
    required String id,
    required DownloadKind kind,
    required String title,
    required List<Track> tracks,
  }) async {
    if (read(downloadsProvider)[id]?.isDone ?? false) {
      showOngakuToast(context, 'Ya está disponible sin conexión');
      return;
    }
    if (!read(backendOnlineProvider)) {
      showOngakuToast(
        context,
        'Sin conexión: no se puede descargar ahora',
        error: true,
      );
      return;
    }
    await read(
      downloadsProvider.notifier,
    ).download(id: id, kind: kind, title: title, tracks: tracks);
    if (!context.mounted) return;
    showOngakuToast(
      context,
      '${plural(tracks.length, 'canción descargada', 'canciones descargadas')} · disponible sin conexión',
    );
  }
}

class _NewPlaylist {
  const _NewPlaylist();
}

class _NameForm extends StatefulWidget {
  const _NameForm({required this.initial, required this.submitLabel});

  final String initial;
  final String submitLabel;

  @override
  State<_NameForm> createState() => _NameFormState();
}

class _NameFormState extends State<_NameForm> {
  late final _c = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _submit() {
    if (_c.text.trim().isNotEmpty) Navigator.pop(context, _c.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OngakuTextField(
          controller: _c,
          label: 'Nombre',
          hint: 'Por ejemplo: Para correr',
          autofocus: true,
          maxLength: 60,
          onSubmitted: (_) => _submit(),
        ),
        DialogActions(
          children: [
            OngakuButton.ghost(
              label: 'Cancelar',
              onPressed: () => Navigator.pop(context),
            ),
            OngakuButton.primary(label: widget.submitLabel, onPressed: _submit),
          ],
        ),
      ],
    );
  }
}

String plural(int n, String one, String many) => '$n ${n == 1 ? one : many}';

/// "1 h 12 min" / "42 min".
String formatLong(Duration d) {
  final m = (d.inSeconds / 60).round();
  return m >= 60 ? '${m ~/ 60} h ${m % 60} min' : '$m min';
}
