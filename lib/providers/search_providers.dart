import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/catalog_repository.dart';
import '../core/fakes/sample_data.dart';
import '../models/search_results.dart';
import 'demo_providers.dart';
import 'repository_providers.dart';

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String q) => state = q;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

class SearchFilterNotifier extends Notifier<SearchFilter> {
  @override
  SearchFilter build() {
    ref.watch(searchQueryProvider);
    return SearchFilter.all;
  }

  void set(SearchFilter f) => state = f;
}

final searchFilterProvider =
    NotifierProvider<SearchFilterNotifier, SearchFilter>(
      SearchFilterNotifier.new,
    );

/// Detected YouTube playlist id in the query (RF-06), if any.
final pastedPlaylistIdProvider = Provider<String?>(
  (ref) => youtubePlaylistId(ref.watch(searchQueryProvider)),
);

final searchResultsProvider = FutureProvider<SearchResults>((ref) async {
  ref.watch(demoScenarioProvider);
  final q = ref.watch(searchQueryProvider).trim();
  if (q.isEmpty || ref.watch(pastedPlaylistIdProvider) != null) {
    return const SearchResults();
  }
  // Debounce typing.
  var cancelled = false;
  ref.onDispose(() => cancelled = true);
  await Future<void>.delayed(const Duration(milliseconds: 180));
  if (cancelled) return const SearchResults();
  return ref.read(catalogRepositoryProvider).search(q);
});

final suggestionsProvider = FutureProvider<List<String>>((ref) {
  final q = ref.watch(searchQueryProvider);
  if (ref.watch(pastedPlaylistIdProvider) != null) return const [];
  return ref.watch(catalogRepositoryProvider).suggestions(q);
});

/// Recent searches, removable one by one or all at once (RF-03).
class RecentSearchesNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => List.of(SampleData.initialRecentSearches);

  void add(String q) {
    final v = q.trim().toLowerCase();
    if (v.isEmpty || youtubePlaylistId(v) != null) return;
    state = [v, ...state.where((r) => r != v)].take(8).toList();
  }

  void removeAt(int i) => state = [...state]..removeAt(i);
  void clear() => state = const [];
}

final recentSearchesProvider =
    NotifierProvider<RecentSearchesNotifier, List<String>>(
      RecentSearchesNotifier.new,
    );
