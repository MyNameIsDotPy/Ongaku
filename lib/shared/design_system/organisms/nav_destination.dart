import '../atoms/ongaku_icon.dart';

/// Top-level sections: sidebar on PC, tabs on Android.
enum NavDestination {
  inicio('/inicio', 'Inicio', OngakuIcons.home),
  buscar('/buscar', 'Buscar', OngakuIcons.search),
  biblioteca('/biblioteca', 'Biblioteca', OngakuIcons.library),
  ajustes('/ajustes', 'Ajustes', OngakuIcons.settings);

  const NavDestination(this.path, this.label, this.icon);
  final String path;
  final String label;
  final OngakuIcons icon;

  /// The destination owning [location], or null on detail pages.
  static NavDestination? fromLocation(String location) {
    for (final d in values) {
      if (location == d.path || location.startsWith('${d.path}/')) return d;
    }
    return null;
  }
}
