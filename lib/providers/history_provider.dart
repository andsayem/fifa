import 'package:flutter/material.dart';
import '../models/tournament_model.dart';
import '../repositories/history_repository.dart';

class HistoryProvider with ChangeNotifier {
  final HistoryRepository _repository = HistoryRepository();

  List<TournamentModel> _allTournaments = [];
  List<TournamentModel> _displayedTournaments = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _championFilter;
  String? _hostFilter;
  int? _decadeFilter;

  List<TournamentModel> get allTournaments => _allTournaments;
  List<TournamentModel> get tournaments => _displayedTournaments;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get championFilter => _championFilter;
  String? get hostFilter => _hostFilter;
  int? get decadeFilter => _decadeFilter;

  Map<String, int> get championCounts =>
      _repository.getChampionCounts(_allTournaments);

  List<String> get allChampions {
    final counts = championCounts;
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.map((e) => e.key).toList();
  }

  List<String> get allHosts {
    final hosts = <String>{};
    for (final t in _allTournaments) {
      hosts.addAll(t.host);
    }
    final sorted = hosts.toList()..sort();
    return sorted;
  }

  List<int> get allDecades {
    final decades = <int>{};
    for (final t in _allTournaments) {
      decades.add((t.year ~/ 10) * 10);
    }
    return decades.toList()..sort();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _allTournaments = await _repository.getTournaments();
      _applyFilters();
    } catch (e) {
      debugPrint('[HistoryProvider] Load failed: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setChampionFilter(String? champion) {
    _championFilter = champion;
    _applyFilters();
  }

  void setHostFilter(String? host) {
    _hostFilter = host;
    _applyFilters();
  }

  void setDecadeFilter(int? decade) {
    _decadeFilter = decade;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _championFilter = null;
    _hostFilter = null;
    _decadeFilter = null;
    _applyFilters();
  }

  void _applyFilters() {
    var list = List<TournamentModel>.from(_allTournaments);

    if (_searchQuery.isNotEmpty) {
      list = _repository.search(list, _searchQuery);
    }

    list = _repository.filter(
      list,
      champion: _championFilter,
      host: _hostFilter,
      decade: _decadeFilter,
    );

    list.sort((a, b) => a.year.compareTo(b.year));
    _displayedTournaments = list;
    notifyListeners();
  }

  TournamentModel? getTournamentByYear(int year) {
    try {
      return _allTournaments.firstWhere((t) => t.year == year);
    } catch (_) {
      return null;
    }
  }

  List<TournamentModel> get finalsList =>
      _allTournaments.where((t) => !t.isTBD).toList()
        ..sort((a, b) => b.year.compareTo(a.year));

  List<TournamentModel> get goldenBootList =>
      _allTournaments.where((t) => !t.isTBD && t.topScorer.goals > 0).toList()
        ..sort((a, b) => b.year.compareTo(a.year));

  List<TournamentModel> get championsOnly =>
      _allTournaments.where((t) => !t.isTBD).toList()
        ..sort((a, b) => b.year.compareTo(a.year));
}
