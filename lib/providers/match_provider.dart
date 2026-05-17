import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../services/static_api_service.dart';

enum MatchFilter { all, upcoming, finished }

class MatchProvider with ChangeNotifier {
  final StaticApiService _apiService = StaticApiService();
  List<MatchModel> _matches = [];
  bool _isLoading = true;
  MatchFilter _currentFilter = MatchFilter.all;
  String _searchQuery = '';

  List<MatchModel> get matches => _matches;
  bool get isLoading => _isLoading;
  MatchFilter get currentFilter => _currentFilter;
  String get searchQuery => _searchQuery;

  MatchProvider() {
    loadMatches();
  }

  Future<void> loadMatches() async {
    _isLoading = true;
    notifyListeners();

    _matches = await _apiService.loadMatches();

    _isLoading = false;
    notifyListeners();
  }

  void setFilter(MatchFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<MatchModel> get filteredMatches {
    List<MatchModel> list = _matches;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((match) =>
          match.homeTeam.toLowerCase().contains(q) ||
          match.awayTeam.toLowerCase().contains(q) ||
          match.stadium.toLowerCase().contains(q)).toList();
    }

    final now = DateTime.now();

    // Filter by match status dynamically
    switch (_currentFilter) {
      case MatchFilter.upcoming:
        list = list.where((match) {
          try {
            final matchDateTime = DateTime.parse("${match.date}T${match.time}:00");
            return matchDateTime.isAfter(now);
          } catch (_) {
            return match.status == 'upcoming';
          }
        }).toList();
        break;
      case MatchFilter.finished:
        list = list.where((match) {
          try {
            final matchDateTime = DateTime.parse("${match.date}T${match.time}:00");
            return matchDateTime.isBefore(now);
          } catch (_) {
            return match.status == 'finished';
          }
        }).toList();
        break;
      case MatchFilter.all:
        break;
    }

    return list;
  }

  // Helper getters for specific screens
  List<MatchModel> get liveMatches => []; // Live option removed as requested

  List<MatchModel> get upcomingMatches {
    final now = DateTime.now();
    return _matches.where((match) {
      try {
        final matchDateTime = DateTime.parse("${match.date}T${match.time}:00");
        return matchDateTime.isAfter(now);
      } catch (_) {
        return match.status == 'upcoming';
      }
    }).toList();
  }

  List<MatchModel> get todayMatches {
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    
    // Return only matches scheduled for the actual calendar date
    return _matches.where((match) => match.date == todayStr).toList();
  }
}
