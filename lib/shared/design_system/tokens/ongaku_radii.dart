import 'package:flutter/widgets.dart';

abstract final class OngakuRadii {
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 10;
  static const double card = 12;
  static const double tile = 14;
  static const double lg = 16;
  static const double xl = 18;
  static const double pill = 999;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius cardAll = BorderRadius.all(Radius.circular(card));
  static const BorderRadius tileAll = BorderRadius.all(Radius.circular(tile));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}
