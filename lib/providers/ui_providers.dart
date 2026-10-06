import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Desktop right-hand queue column.
class QueuePanelNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
}

final queuePanelOpenProvider = NotifierProvider<QueuePanelNotifier, bool>(
  QueuePanelNotifier.new,
);

enum NowPlayingMode { cover, lyrics, queue }

/// Which pane the immersive player shows.
class NowPlayingModeNotifier extends Notifier<NowPlayingMode> {
  @override
  NowPlayingMode build() => NowPlayingMode.cover;
  void set(NowPlayingMode m) => state = m;

  /// Pressing the active mode's button returns to the cover.
  void toggle(NowPlayingMode m) =>
      state = state == m ? NowPlayingMode.cover : m;
}

final nowPlayingModeProvider =
    NotifierProvider<NowPlayingModeNotifier, NowPlayingMode>(
      NowPlayingModeNotifier.new,
    );

/// Ctrl+F asks the search field to take focus.
class SearchFocusRequest extends Notifier<int> {
  @override
  int build() => 0;
  void request() => state++;
}

final searchFocusRequestProvider = NotifierProvider<SearchFocusRequest, int>(
  SearchFocusRequest.new,
);
