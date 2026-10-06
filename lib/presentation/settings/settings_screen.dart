import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../models/app_settings.dart';
import '../../models/connection_test.dart';
import '../../models/demo_scenario.dart';
import '../../providers/demo_providers.dart';
import '../../providers/download_providers.dart';
import '../../providers/library_providers.dart';
import '../../providers/repository_providers.dart';
import '../../providers/settings_providers.dart';
import '../../shared/design_system/design_system.dart';
import '../common/ongaku_page.dart';
import '../common/track_actions.dart';

/// Ajustes (RF-24, RF-26–27, RNF-07): backend, quality for Wi-Fi and mobile
/// data, downloads and space, theme and motion, backup and cache.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  ConnectionTestResult? _test;
  bool _testing = false;

  Future<void> _testConnection() async {
    setState(() => _testing = true);
    final r = await ref
        .read(backendClientProvider)
        .testConnection(ref.read(settingsProvider));
    if (mounted) {
      setState(() {
        _testing = false;
        _test = r;
      });
    }
  }

  void _update(AppSettings Function(AppSettings) f) =>
      ref.read(settingsProvider.notifier).update(f);

  Future<void> _export() async {
    final lib = ref.read(libraryProvider);
    final json = const JsonEncoder.withIndent('  ').convert({
      'playlists': [
        for (final p in lib.ownedPlaylists)
          {
            'id': p.id,
            'name': p.name,
            'source': p.source.name,
            'tracks': [for (final t in p.tracks) t.videoId],
          },
      ],
      'favorites': [for (final t in lib.favorites) t.videoId],
      'history': [
        for (final e in lib.history)
          {
            'videoId': e.track.videoId,
            'playedAt': e.playedAt.toIso8601String(),
            'device': e.device.name,
          },
      ],
    });
    await Clipboard.setData(ClipboardData(text: json));
    if (mounted) showOngakuToast(context, 'Respaldo copiado al portapapeles');
  }

  Future<void> _import() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    try {
      final d = jsonDecode(data?.text ?? '') as Map<String, dynamic>;
      final ps = d['playlists'] as List;
      showOngakuToast(
        context,
        'Respaldo válido · ${plural(ps.length, 'playlist', 'playlists')}',
      );
    } catch (_) {
      showOngakuToast(
        context,
        'El portapapeles no tiene un respaldo de Ongaku',
        error: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider);
    final online = ref.watch(backendOnlineProvider);
    final scenario = ref.watch(demoScenarioProvider);
    final downloads = ref.watch(downloadsProvider);
    final token = s.token.isEmpty
        ? 'Sin configurar'
        : '${s.token.substring(0, s.token.length.clamp(0, 6))}••••••••••';

    final status = _testing
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OngakuSpinner(size: 16, color: context.colors.muted),
              const SizedBox(width: 8),
              Text(
                'Probando…',
                style: TextStyle(fontSize: 13, color: context.colors.muted),
              ),
            ],
          )
        : switch (_test) {
            ConnectionTestSuccess(:final latencyMs) => StatusLabel(
              ok: true,
              label: 'Conectado · respuesta en $latencyMs ms',
            ),
            ConnectionTestFailure(:final code) => StatusLabel(
              ok: false,
              label: '${code.wire} · ${code.description}',
            ),
            null => StatusLabel(
              ok: online,
              label: online ? 'Conectado · yt-dlp al día' : 'Sin respuesta',
            ),
          };

    Widget quality(AudioQuality v, ValueChanged<AudioQuality> on) =>
        OngakuSegmented<AudioQuality>(
          options: const [
            (AudioQuality.high, 'Alta'),
            (AudioQuality.low, 'Ahorro'),
          ],
          value: v,
          onChanged: on,
        );

    final groups = [
      SettingsGroup(
        title: 'Backend',
        children: [
          SettingsRow(
            title: 'Servidor',
            description: s.backendUrl,
            monoDescription: true,
            trailing: status,
          ),
          SettingsRow(
            title: 'Token del dispositivo',
            description: token,
            monoDescription: true,
            trailing: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OngakuButton(
                  label: 'Probar conexión',
                  onPressed: _testing ? null : _testConnection,
                ),
                OngakuButton.ghost(
                  label: 'Configurar',
                  onPressed: () => context.go(Routes.connection),
                ),
              ],
            ),
          ),
        ],
      ),
      SettingsGroup(
        title: 'Calidad de audio',
        children: [
          SettingsRow(
            title: 'Con Wi-Fi',
            description: 'Alta ≈ 160 kbps · ≈ 70 MB por hora',
            trailing: quality(
              s.wifiQuality,
              (v) => _update((x) => x.copyWith(wifiQuality: v)),
            ),
          ),
          SettingsRow(
            title: 'Con datos móviles',
            description: 'Ahorro ≈ 50 kbps · ≈ 22 MB por hora',
            trailing: quality(
              s.mobileQuality,
              (v) => _update((x) => x.copyWith(mobileQuality: v)),
            ),
          ),
        ],
      ),
      SettingsGroup(
        title: 'Descargas',
        children: [
          SettingsRow(
            title: 'Descargar solo con Wi-Fi',
            trailing: OngakuSwitch(
              value: s.downloadOnWifiOnly,
              semanticLabel: 'Descargar solo con Wi-Fi',
              onChanged: (v) =>
                  _update((x) => x.copyWith(downloadOnWifiOnly: v)),
            ),
          ),
          SettingsRow(
            title: 'Límite de espacio',
            description: '${s.downloadLimitGb} GB',
            monoDescription: true,
            trailing: SizedBox(
              width: 220,
              child: Slider(
                min: 1,
                max: 32,
                divisions: 31,
                value: s.downloadLimitGb.toDouble(),
                semanticFormatterCallback: (v) => '${v.round()} GB',
                onChanged: (v) =>
                    _update((x) => x.copyWith(downloadLimitGb: v.round())),
              ),
            ),
          ),
          SettingsRow(
            title: 'Borrar todas las descargas',
            description:
                '${plural(downloads.length, 'lista', 'listas')} descargadas',
            trailing: OngakuButton(
              label: 'Borrar',
              onPressed: downloads.isEmpty
                  ? null
                  : () {
                      ref.read(downloadsProvider.notifier).clear();
                      showOngakuToast(
                        context,
                        'Se borraron todas las descargas',
                      );
                    },
            ),
          ),
        ],
      ),
      SettingsGroup(
        title: 'Apariencia y movimiento',
        children: [
          SettingsRow(
            title: 'Tema',
            trailing: OngakuSegmented<ThemePreference>(
              options: const [
                (ThemePreference.light, 'Claro'),
                (ThemePreference.dark, 'Oscuro'),
                (ThemePreference.system, 'Sistema'),
              ],
              value: s.theme,
              onChanged: (v) => _update((x) => x.copyWith(theme: v)),
            ),
          ),
          SettingsRow(
            title: 'Animaciones',
            description:
                'Reducidas desactiva el aura y el desplazamiento de la letra',
            trailing: OngakuSegmented<MotionLevel>(
              options: const [
                (MotionLevel.full, 'Completas'),
                (MotionLevel.reduced, 'Reducidas'),
              ],
              value: s.motion,
              onChanged: (v) => _update((x) => x.copyWith(motion: v)),
            ),
          ),
          SettingsRow(
            title: 'Visualizador al ritmo',
            description: 'La portada y el aura reaccionan al audio',
            trailing: OngakuSwitch(
              value: s.reactiveVisuals,
              semanticLabel: 'Visualizador al ritmo',
              onChanged: (v) => _update((x) => x.copyWith(reactiveVisuals: v)),
            ),
          ),
        ],
      ),
      SettingsGroup(
        title: 'Respaldo y caché',
        children: [
          SettingsRow(
            title: 'Biblioteca en JSON',
            description: 'Playlists, favoritos e historial (vía portapapeles)',
            trailing: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OngakuButton(label: 'Exportar', onPressed: _export),
                OngakuButton.ghost(label: 'Importar', onPressed: _import),
              ],
            ),
          ),
          SettingsRow(
            title: 'Caché de metadatos y portadas',
            trailing: OngakuButton(
              label: 'Borrar caché',
              onPressed: () {
                PaintingBinding.instance.imageCache.clear();
                showOngakuToast(
                  context,
                  'Caché borrada · las descargas se conservan',
                );
              },
            ),
          ),
          const SettingsRow(
            title: 'Versión',
            description: 'App 1.0.0 · Backend: datos de ejemplo (Fake*)',
            monoDescription: true,
          ),
        ],
      ),
      SettingsGroup(
        title: 'Simulación del backend',
        children: [
          SettingsRow(
            title: 'Estado simulado',
            description:
                'Los repositorios de ejemplo responden como el backend en este estado: cargando, vacío, error o sin conexión.',
            trailing: OngakuSegmented<DemoScenario>(
              options: [for (final d in DemoScenario.values) (d, d.label)],
              value: scenario,
              onChanged: ref.read(demoScenarioProvider.notifier).set,
            ),
          ),
        ],
      ),
    ];

    return OngakuPage(
      slivers: [
        const PageSection(child: PageHeader('Ajustes')),
        for (var i = 0; i < groups.length; i++)
          PageSection(
            index: i + 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: groups[i],
            ),
          ),
      ],
    );
  }
}
