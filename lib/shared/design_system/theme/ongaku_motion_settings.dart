import 'package:flutter/widgets.dart';

/// Motion preferences from Settings ("Animaciones" and "Visualizador al
/// ritmo"), combined with the platform's reduce-motion flag.
class OngakuMotionSettings extends InheritedWidget {
  const OngakuMotionSettings({
    super.key,
    required this.reduced,
    required this.reactive,
    required super.child,
  });

  final bool reduced;
  final bool reactive;

  static OngakuMotionSettings? _of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<OngakuMotionSettings>();

  /// True when animations should be flattened.
  static bool reducedOf(BuildContext context) =>
      (_of(context)?.reduced ?? false) ||
      MediaQuery.maybeDisableAnimationsOf(context) == true;

  /// True when the cover and aura should follow the beat.
  static bool reactiveOf(BuildContext context) =>
      (_of(context)?.reactive ?? true) && !reducedOf(context);

  @override
  bool updateShouldNotify(OngakuMotionSettings old) =>
      reduced != old.reduced || reactive != old.reactive;
}
