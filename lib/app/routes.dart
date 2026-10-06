/// Route locations, so screens never build paths by hand.
abstract final class Routes {
  static const connection = '/conexion';
  static const home = '/inicio';
  static const search = '/buscar';
  static const library = '/biblioteca';
  static const settings = '/ajustes';
  static const nowPlaying = '/reproductor';

  static String libraryTab(String tab) => '$library/$tab';
  static String album(String id) => '/album/$id';
  static String artist(String id) => '/artista/$id';
  static String playlist(String id) => '/playlist/$id';
}
