import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/match_model.dart';
import '../services/static_api_service.dart';

enum MatchFilter { all, today, upcoming, finished }

class MatchProvider with ChangeNotifier {
  final StaticApiService _apiService = StaticApiService();
  static const _githubUrl =
      'https://raw.githubusercontent.com/openfootball/worldcup.json/master/2026/worldcup.json';
  static const _cacheBox = 'match_cache';
  static const _cacheKey = 'github_matches';

  late Dio _dio;
  List<MatchModel> _matches = [];
  bool _isLoading = true;
  String _dataSource = 'local'; // 'github', 'cache', 'local'
  String? _errorMessage;
  MatchFilter _currentFilter = MatchFilter.all;
  String _searchQuery = '';

  List<MatchModel> get matches => _matches;
  bool get isLoading => _isLoading;
  String get dataSource => _dataSource;
  String? get errorMessage => _errorMessage;
  MatchFilter get currentFilter => _currentFilter;
  String get searchQuery => _searchQuery;

  MatchProvider() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ));
    loadMatches();
  }

  Future<void> loadMatches() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Try GitHub first
    try {
      final response = await _dio.get<String>(_githubUrl);
      final raw = response.data;
      if (raw == null || raw.isEmpty) throw Exception('Empty response');
      final parsed = jsonDecode(raw);
      final data = parsed is Map<String, dynamic> ? parsed : null;
      if (data != null && data['matches'] is List) {
        final list = data['matches'] as List;
        _matches = list.asMap().entries.map((entry) {
          return MatchModel.fromGitHubJson(
            entry.value as Map<String, dynamic>,
            entry.key,
          );
        }).toList();
        _dataSource = 'github';
        _isLoading = false;
        notifyListeners();
        _cacheMatches(data);
        debugPrint('[MatchProvider] Loaded ${_matches.length} matches from GitHub');
        return;
      }
    } catch (e) {
      debugPrint('[MatchProvider] GitHub fetch failed: $e');
      _errorMessage = e.toString();
    }

    // Try cache
    try {
      final box = await Hive.openBox(_cacheBox);
      final cached = box.get(_cacheKey) as String?;
      if (cached != null) {
        final data = jsonDecode(cached) as Map<String, dynamic>;
        if (data['matches'] is List) {
          final list = data['matches'] as List;
          _matches = list.asMap().entries.map((entry) {
            return MatchModel.fromGitHubJson(
              entry.value as Map<String, dynamic>,
              entry.key,
            );
          }).toList();
          _dataSource = 'cache';
          _errorMessage = null;
          _isLoading = false;
          notifyListeners();
          debugPrint('[MatchProvider] Loaded ${_matches.length} matches from cache');
          return;
        }
      }
    } catch (e) {
      debugPrint('[MatchProvider] Cache load failed: $e');
      _errorMessage = e.toString();
    }

    // Fall back to local JSON
    _matches = await _apiService.loadMatches();
    _dataSource = 'local';
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
    debugPrint('[MatchProvider] Loaded ${_matches.length} matches from local JSON');
  }

  Future<void> _cacheMatches(Map<String, dynamic> data) async {
    try {
      final box = await Hive.openBox(_cacheBox);
      await box.put(_cacheKey, jsonEncode(data));
    } catch (e) {
      debugPrint('[MatchProvider] Cache write failed: $e');
    }
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

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((match) =>
          match.homeTeam.toLowerCase().contains(q) ||
          match.awayTeam.toLowerCase().contains(q) ||
          match.stadium.toLowerCase().contains(q)).toList();
    }

    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    switch (_currentFilter) {
      case MatchFilter.today:
        list = list.where((match) => match.date == todayStr).toList();
        break;
      case MatchFilter.upcoming:
        list = list.where((match) => match.status == 'upcoming').toList();
        break;
      case MatchFilter.finished:
        list = list.where((match) => match.status == 'finished').toList();
        break;
      case MatchFilter.all:
        break;
    }

    return list;
  }

  List<MatchModel> get liveMatches => [];

  List<MatchModel> get upcomingMatches {
    return _matches.where((match) => match.status == 'upcoming').toList();
  }

  List<MatchModel> get todayMatches {
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    return _matches.where((match) => match.date == todayStr).toList();
  }
}
