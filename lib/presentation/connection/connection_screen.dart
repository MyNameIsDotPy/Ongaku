import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../models/connection_test.dart';
import '../../providers/library_providers.dart';
import '../../providers/repository_providers.dart';
import '../../providers/settings_providers.dart';
import '../../shared/design_system/design_system.dart';
import '../common/track_actions.dart';

/// Conexión (RF-28): first run in three steps — backend URL and token with a
/// connection test; notification and battery permissions; sync summary.
class ConnectionScreen extends ConsumerStatefulWidget {
  const ConnectionScreen({super.key});

  @override
  ConsumerState<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends ConsumerState<ConnectionScreen> {
  int _step = 0;
  bool _testing = false;
  ConnectionTestResult? _result;
  bool _notifications = false;
  bool _battery = false;
  late final _url = TextEditingController(
    text: ref.read(settingsProvider).backendUrl,
  );
  late final _token = TextEditingController(
    text: ref.read(settingsProvider).token,
  );

  @override
  void dispose() {
    _url.dispose();
    _token.dispose();
    super.dispose();
  }

  Future<void> _test() async {
    setState(() {
      _testing = true;
      _result = null;
    });
    final settings = ref
        .read(settingsProvider)
        .copyWith(backendUrl: _url.text.trim(), token: _token.text.trim());
    final r = await ref.read(backendClientProvider).testConnection(settings);
    if (!mounted) return;
    setState(() {
      _testing = false;
      _result = r;
    });
  }

  Future<void> _saveAndContinue() async {
    await ref
        .read(settingsProvider.notifier)
        .update(
          (s) => s.copyWith(
            backendUrl: _url.text.trim(),
            token: _token.text.trim(),
          ),
        );
    setState(() => _step = 1);
  }

  Future<void> _finish() async {
    await ref
        .read(settingsProvider.notifier)
        .update((s) => s.copyWith(onboardingComplete: true));
    if (mounted) context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ok = _result is ConnectionTestSuccess;
    Widget heading(String eyebrow, String title, String lead) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(eyebrow.toUpperCase(), style: OngakuTypography.eyebrow(context)),
        const SizedBox(height: 12),
        Semantics(
          header: true,
          child: Text(
            title,
            style: context.text.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(lead, style: TextStyle(fontSize: 16, color: c.muted, height: 1.5)),
        const SizedBox(height: 26),
      ],
    );

    final Widget body = switch (_step) {
      0 => Column(
        key: const ValueKey(0),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          heading(
            'Paso 1 de 3 · Conexión',
            'Conecta tu backend',
            'La app solo habla con tu servidor del homelab por Tailscale. Nunca contacta a YouTube directamente.',
          ),
          OngakuTextField(
            controller: _url,
            label: 'URL del backend',
            mono: true,
          ),
          const SizedBox(height: 16),
          OngakuTextField(
            controller: _token,
            label: 'Token del dispositivo',
            mono: true,
            hint: 'od_…',
            error: _result is ConnectionTestFailure,
            onSubmitted: (_) => _test(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 24,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _testing
                  ? Row(
                      children: [
                        OngakuSpinner(size: 16, color: c.muted),
                        const SizedBox(width: 8),
                        Text(
                          'Probando conexión…',
                          style: TextStyle(fontSize: 13, color: c.muted),
                        ),
                      ],
                    )
                  : switch (_result) {
                      ConnectionTestSuccess() => const StatusLabel(
                        ok: true,
                        label:
                            'Conexión correcta · el backend responde y la extracción funciona',
                      ),
                      ConnectionTestFailure(:final code) => StatusLabel(
                        ok: false,
                        label: '${code.wire} · ${code.description}',
                      ),
                      null => Text(
                        'Prueba: cualquier token que empiece por “od_” funciona.',
                        style: TextStyle(fontSize: 13, color: c.muted),
                      ),
                    },
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 10,
            runSpacing: 10,
            children: [
              OngakuButton(
                label: 'Probar conexión',
                onPressed: _testing ? null : _test,
              ),
              OngakuButton.primary(
                label: 'Guardar y continuar',
                onPressed: ok ? _saveAndContinue : null,
              ),
            ],
          ),
        ],
      ),
      1 => Column(
        key: const ValueKey(1),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          heading(
            'Paso 2 de 3 · Segundo plano',
            'Que no se corte con la pantalla apagada',
            'Android necesita dos permisos para mantener la música sonando en el bolsillo.',
          ),
          PermissionCard(
            icon: OngakuIcons.bell,
            title: 'Notificaciones',
            description:
                'Muestra los controles en la notificación y en la pantalla de bloqueo.',
            granted: _notifications,
            onChanged: (v) => setState(() => _notifications = v),
          ),
          PermissionCard(
            icon: OngakuIcons.battery,
            title: 'Excluir de la optimización de batería',
            description:
                'Evita que MIUI o One UI cierren el servicio de reproducción.',
            granted: _battery,
            onChanged: (v) => setState(() => _battery = v),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OngakuButton.ghost(
                label: 'Atrás',
                onPressed: () => setState(() => _step = 0),
              ),
              OngakuButton.primary(
                label: 'Continuar',
                onPressed: () => setState(() => _step = 2),
              ),
            ],
          ),
        ],
      ),
      _ => Consumer(
        key: const ValueKey(2),
        builder: (context, ref, _) {
          final lib = ref.watch(libraryProvider);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              heading(
                'Paso 3 de 3 · Listo',
                'Todo listo',
                'Tu biblioteca se sincronizó desde el backend: '
                    '${plural(lib.ownedPlaylists.length, 'playlist', 'playlists')}, '
                    '${plural(lib.favorites.length, 'favorito', 'favoritos')} y tu historial.',
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OngakuButton.ghost(
                    label: 'Atrás',
                    onPressed: () => setState(() => _step = 1),
                  ),
                  OngakuButton.primary(
                    label: 'Empezar a escuchar',
                    onPressed: _finish,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    };

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 28),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: OngakuBrand(),
                    ),
                  ),
                  StepsIndicator(step: _step),
                  const SizedBox(height: 28),
                  AnimatedSwitcher(
                    duration: OngakuMotion.medium,
                    switchInCurve: OngakuMotion.ease,
                    transitionBuilder: (child, a) => FadeTransition(
                      opacity: a,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0, 0.03),
                          end: Offset.zero,
                        ).animate(a),
                        child: child,
                      ),
                    ),
                    child: body,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
