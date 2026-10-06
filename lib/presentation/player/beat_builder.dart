import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/track.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/player_providers.dart';
import '../../providers/repository_providers.dart';
import '../../shared/design_system/design_system.dart';

/// Rhythm levels for one frame (0–1).
class BeatLevels {
  const BeatLevels({
    this.beat = 0,
    this.energy = 0,
    this.time = 0,
    this.position = Duration.zero,
  });

  /// Kick envelope: 1 on the beat, decaying `exp(-t·7)`.
  final double beat;

  /// Smoothed loudness used to stir the aura and the progress wave.
  final double energy;

  /// Animation clock in seconds; runs faster while playing.
  final double time;
  final Duration position;

  static const rest = BeatLevels();
}

/// Rebuilds every frame with rhythm levels derived from the track's
/// [BeatGrid] (backend-computed, per the design notes: no FFT, no mic).
/// Stays at rest when paused or when reactive visuals are off.
class BeatBuilder extends ConsumerStatefulWidget {
  const BeatBuilder({
    super.key,
    required this.track,
    required this.builder,
    this.child,
    this.alwaysTick = false,
  });

  final Track track;
  final Widget Function(BuildContext, BeatLevels, Widget?) builder;
  final Widget? child;

  /// Keep the clock running while paused (the aura keeps drifting slowly).
  final bool alwaysTick;

  @override
  ConsumerState<BeatBuilder> createState() => _BeatBuilderState();
}

class _BeatBuilderState extends ConsumerState<BeatBuilder>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);
  BeatLevels _levels = BeatLevels.rest;
  Duration _last = Duration.zero;
  double _energy = 0, _beat = 0, _time = 0;

  void _tick(Duration elapsed) {
    final dt = math.min(0.064, (elapsed - _last).inMicroseconds / 1e6);
    _last = elapsed;
    final playing = ref.read(playerProvider).isPlaying;
    final reactive = OngakuMotionSettings.reactiveOf(context);
    final pos = ref.read(playerControllerProvider).position;
    final grid = ref.read(beatGridProvider(widget.track));
    final k = playing && reactive ? 1.0 : 0.0;
    final rawBeat = beatEnvelope(pos, grid.beat) * k;
    // A slow swell per bar stands in for the bass envelope.
    final bar = grid.beat.inMicroseconds * 4 / 1e6;
    final swell =
        0.45 + 0.3 * math.sin(pos.inMicroseconds / 1e6 / bar * math.pi);
    _energy += ((swell + rawBeat * 0.4) * k - _energy) * 0.12;
    _beat += (rawBeat - _beat) * 0.35;
    _time += dt * (playing ? 1 + _energy * 2.2 : 0.35);
    setState(
      () => _levels = BeatLevels(
        beat: _beat,
        energy: _energy,
        time: _time,
        position: pos,
      ),
    );
  }

  void _sync(bool playing) {
    final run =
        (playing || widget.alwaysTick) &&
        !OngakuMotionSettings.reducedOf(context);
    if (run && !_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    } else if (!run && _ticker.isActive) {
      _ticker.stop();
      _levels = BeatLevels(time: _time);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _sync(ref.watch(playerProvider.select((s) => s.isPlaying)));
    return widget.builder(context, _levels, widget.child);
  }
}
