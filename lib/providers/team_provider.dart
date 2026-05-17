import 'package:flutter/material.dart';
import '../models/team_model.dart';
import '../models/venue_model.dart';
import '../models/group_standing_model.dart';
import '../models/match_model.dart';
import '../models/player_model.dart';
import '../services/static_api_service.dart';

class TeamProvider with ChangeNotifier {
  final StaticApiService _apiService = StaticApiService();
  List<TeamModel> _teams = [];
  List<VenueModel> _venues = [];
  List<PlayerModel> _players = [];
  bool _isLoading = true;
  String _teamSearchQuery = '';
  Map<String, List<GroupStandingModel>> _groupStandings = {};

  List<TeamModel> get teams => _teams;
  List<VenueModel> get venues => _venues;
  List<PlayerModel> get players => _players;
  bool get isLoading => _isLoading;
  String get teamSearchQuery => _teamSearchQuery;
  Map<String, List<GroupStandingModel>> get groupStandings => _groupStandings;

  TeamProvider() {
    loadData();
  }

  List<PlayerModel> getPlayersForTeam(String teamName) {
    return _players
        .where((p) => p.teamName.toLowerCase().trim() == teamName.toLowerCase().trim())
        .toList();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _teams = await _apiService.loadTeams();
    _venues = await _apiService.loadVenues();
    _players = await _apiService.loadPlayers();
    final matches = await _apiService.loadMatches();

    _calculateStandings(matches);

    _isLoading = false;
    notifyListeners();
  }

  void _calculateStandings(List<MatchModel> matches) {
    final Map<String, List<GroupStandingModel>> standings = {};

    // 1. Initialize standings for all teams
    for (var team in _teams) {
      if (!standings.containsKey(team.group)) {
        standings[team.group] = [];
      }
      standings[team.group]!.add(GroupStandingModel(team: team));
    }

    // 2. Process all matches that are finished to update standings
    for (var match in matches) {
      if (match.status.toLowerCase() != 'finished') continue;

      GroupStandingModel? homeStanding;
      GroupStandingModel? awayStanding;

      for (var groupList in standings.values) {
        for (var standing in groupList) {
          if (standing.team.name.toLowerCase() == match.homeTeam.toLowerCase()) {
            homeStanding = standing;
          }
          if (standing.team.name.toLowerCase() == match.awayTeam.toLowerCase()) {
            awayStanding = standing;
          }
        }
      }

      if (homeStanding != null && awayStanding != null) {
        final homeScore = match.homeScore ?? 0;
        final awayScore = match.awayScore ?? 0;

        homeStanding.played += 1;
        awayStanding.played += 1;
        homeStanding.goalsFor += homeScore;
        homeStanding.goalsAgainst += awayScore;
        awayStanding.goalsFor += awayScore;
        awayStanding.goalsAgainst += homeScore;

        if (homeScore > awayScore) {
          homeStanding.won += 1;
          awayStanding.lost += 1;
        } else if (awayScore > homeScore) {
          awayStanding.won += 1;
          homeStanding.lost += 1;
        } else {
          homeStanding.drawn += 1;
          awayStanding.drawn += 1;
        }
      }
    }

    // 3. Sort each group's standing by points, then goal difference, then goals for, then name
    for (var group in standings.keys) {
      standings[group]!.sort((a, b) {
        if (a.points != b.points) {
          return b.points.compareTo(a.points);
        }
        if (a.goalDifference != b.goalDifference) {
          return b.goalDifference.compareTo(a.goalDifference);
        }
        if (a.goalsFor != b.goalsFor) {
          return b.goalsFor.compareTo(a.goalsFor);
        }
        return a.team.name.compareTo(b.team.name);
      });
    }

    // 4. Sort keys alphabetically
    final sortedKeys = standings.keys.toList()..sort();
    _groupStandings = {for (var key in sortedKeys) key: standings[key]!};
  }

  void setSearchQuery(String query) {
    _teamSearchQuery = query;
    notifyListeners();
  }

  List<TeamModel> get filteredTeams {
    if (_teamSearchQuery.isEmpty) {
      return _teams;
    }
    return _teams.where((team) => team.name.toLowerCase().contains(_teamSearchQuery.toLowerCase())).toList();
  }

  // Get teams grouped by Group
  Map<String, List<TeamModel>> get teamsByGroup {
    final Map<String, List<TeamModel>> grouped = {};
    for (var team in filteredTeams) {
      if (!grouped.containsKey(team.group)) {
        grouped[team.group] = [];
      }
      grouped[team.group]!.add(team);
    }
    // Sort keys alphabetically
    final sortedKeys = grouped.keys.toList()..sort();
    return {for (var key in sortedKeys) key: grouped[key]!};
  }
}
