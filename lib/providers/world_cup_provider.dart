import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/match_model.dart';
import '../models/world_cup_data.dart';
import '../repositories/world_cup_repository.dart';
import '../services/cache_service.dart';
import '../services/world_cup_service.dart';
import 'match_filter_provider.dart';

final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService();
});

final worldCupServiceProvider = Provider<WorldCupService>((ref) {
  return WorldCupService();
});

final worldCupRepositoryProvider = Provider<WorldCupRepository>((ref) {
  return WorldCupRepository(
    service: ref.watch(worldCupServiceProvider),
    cache: ref.watch(cacheServiceProvider),
  );
});

enum DataLoadState { initial, loading, loaded, error }

class WorldCupState {
  final DataLoadState state;
  final WorldCupData? data;
  final String? errorMessage;
  final bool isFromCache;
  final DateTime? lastUpdated;

  const WorldCupState({
    this.state = DataLoadState.initial,
    this.data,
    this.errorMessage,
    this.isFromCache = false,
    this.lastUpdated,
  });

  WorldCupState copyWith({
    DataLoadState? state,
    WorldCupData? data,
    String? errorMessage,
    bool? isFromCache,
    DateTime? lastUpdated,
  }) {
    return WorldCupState(
      state: state ?? this.state,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
      isFromCache: isFromCache ?? this.isFromCache,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class WorldCupNotifier extends StateNotifier<WorldCupState> {
  final WorldCupRepository _repository;
  Timer? _refreshTimer;

  WorldCupNotifier(this._repository) : super(const WorldCupState());

  Future<void> loadData() async {
    state = state.copyWith(state: DataLoadState.loading, errorMessage: null);
    try {
      final result = await _repository.fetchData();
      state = state.copyWith(
        state: DataLoadState.loaded,
        data: result.data,
        isFromCache: result.source == DataSource.cache,
        lastUpdated: DateTime.now(),
        errorMessage: result.source == DataSource.cache
            ? 'Showing cached data. Connect to internet for live updates.'
            : null,
      );
    } catch (e) {
      final cached = await _repository.loadFromCache();
      if (cached != null) {
        state = state.copyWith(
          state: DataLoadState.loaded,
          data: cached,
          isFromCache: true,
          lastUpdated: await _repository.lastCacheTime(),
          errorMessage: 'Could not refresh. Showing cached data.',
        );
      } else {
        state = state.copyWith(
          state: DataLoadState.error,
          errorMessage: 'Failed to load data. Check your internet connection.',
        );
      }
    }
  }

  void startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      loadData();
    });
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}

final worldCupProvider =
    StateNotifierProvider<WorldCupNotifier, WorldCupState>((ref) {
  final repository = ref.watch(worldCupRepositoryProvider);
  return WorldCupNotifier(repository);
});

final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map(
        (results) => !results.contains(ConnectivityResult.none),
      );
});

final liveMatchesProvider = Provider<List<MatchModel>>((ref) {
  final data = ref.watch(worldCupProvider).data;
  if (data == null) return [];
  return data.liveMatches;
});

final todayMatchesProvider = Provider<List<MatchModel>>((ref) {
  final data = ref.watch(worldCupProvider).data;
  if (data == null) return [];
  return data.todayMatches;
});

final upcomingMatchesProvider = Provider<List<MatchModel>>((ref) {
  final data = ref.watch(worldCupProvider).data;
  if (data == null) return [];
  return data.upcomingMatches;
});

final finishedMatchesProvider = Provider<List<MatchModel>>((ref) {
  final data = ref.watch(worldCupProvider).data;
  if (data == null) return [];
  return data.finishedMatches;
});

final filteredMatchesProvider = Provider<List<MatchModel>>((ref) {
  final data = ref.watch(worldCupProvider).data;
  final filter = ref.watch(matchFilterProvider);
  if (data == null) return [];
  return filter.apply(data.matches);
});

final teamsProvider = Provider<List<String>>((ref) {
  final data = ref.watch(worldCupProvider).data;
  if (data == null) return [];
  return data.teams;
});

final venuesProvider = Provider<List<String>>((ref) {
  final data = ref.watch(worldCupProvider).data;
  if (data == null) return [];
  return data.venues;
});

final groupsProvider = Provider<List<String>>((ref) {
  final data = ref.watch(worldCupProvider).data;
  if (data == null) return [];
  return data.groups;
});

final roundsProvider = Provider<List<String>>((ref) {
  final data = ref.watch(worldCupProvider).data;
  if (data == null) return [];
  return data.rounds;
});
