import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/match_model.dart';

enum MatchStatusFilter { all, live, upcoming, finished }

class MatchFilter {
  final String searchQuery;
  final String? groupFilter;
  final String? roundFilter;
  final MatchStatusFilter statusFilter;
  final String? venueFilter;
  final String? teamFilter;

  const MatchFilter({
    this.searchQuery = '',
    this.groupFilter,
    this.roundFilter,
    this.statusFilter = MatchStatusFilter.all,
    this.venueFilter,
    this.teamFilter,
  });

  MatchFilter copyWith({
    String? searchQuery,
    String? groupFilter,
    String? roundFilter,
    MatchStatusFilter? statusFilter,
    String? venueFilter,
    String? teamFilter,
    bool clearGroup = false,
    bool clearRound = false,
    bool clearVenue = false,
    bool clearTeam = false,
  }) {
    return MatchFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      groupFilter: clearGroup ? null : (groupFilter ?? this.groupFilter),
      roundFilter: clearRound ? null : (roundFilter ?? this.roundFilter),
      statusFilter: statusFilter ?? this.statusFilter,
      venueFilter: clearVenue ? null : (venueFilter ?? this.venueFilter),
      teamFilter: clearTeam ? null : (teamFilter ?? this.teamFilter),
    );
  }

  List<MatchModel> apply(List<MatchModel> matches) {
    var result = matches;

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result.where((m) {
        return m.homeTeam.toLowerCase().contains(q) ||
            m.awayTeam.toLowerCase().contains(q) ||
            m.stadium.toLowerCase().contains(q) ||
            (m.group?.toLowerCase().contains(q) ?? false) ||
            (m.round?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    if (groupFilter != null) {
      result = result.where((m) => m.group == groupFilter).toList();
    }

    if (roundFilter != null) {
      result = result.where((m) => m.round == roundFilter).toList();
    }

    if (teamFilter != null) {
      result = result.where((m) {
        return m.homeTeam == teamFilter || m.awayTeam == teamFilter;
      }).toList();
    }

    if (venueFilter != null) {
      result = result.where((m) => m.stadium == venueFilter).toList();
    }

    switch (statusFilter) {
      case MatchStatusFilter.live:
        result = result.where((m) => m.status == 'live').toList();
      case MatchStatusFilter.upcoming:
        result = result.where((m) => m.status == 'upcoming').toList();
      case MatchStatusFilter.finished:
        result = result.where((m) => m.status == 'finished').toList();
      case MatchStatusFilter.all:
        break;
    }

    return result;
  }

  bool get hasActiveFilters =>
      groupFilter != null ||
      roundFilter != null ||
      statusFilter != MatchStatusFilter.all ||
      venueFilter != null ||
      teamFilter != null ||
      searchQuery.isNotEmpty;
}

class MatchFilterNotifier extends StateNotifier<MatchFilter> {
  MatchFilterNotifier() : super(const MatchFilter());

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setGroup(String? group) {
    state = state.copyWith(
      groupFilter: group,
      clearGroup: group == null,
    );
  }

  void setRound(String? round) {
    state = state.copyWith(
      roundFilter: round,
      clearRound: round == null,
    );
  }

  void setStatus(MatchStatusFilter status) {
    state = state.copyWith(statusFilter: status);
  }

  void setVenue(String? venue) {
    state = state.copyWith(
      venueFilter: venue,
      clearVenue: venue == null,
    );
  }

  void setTeam(String? team) {
    state = state.copyWith(
      teamFilter: team,
      clearTeam: team == null,
    );
  }

  void clearAll() {
    state = const MatchFilter();
  }
}

final matchFilterProvider =
    StateNotifierProvider<MatchFilterNotifier, MatchFilter>((ref) {
  return MatchFilterNotifier();
});
