import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/match_model.dart';
import '../models/team_model.dart';
import '../models/venue_model.dart';
import '../models/bracket_model.dart';
import '../models/player_model.dart';

class StaticApiService {
  Future<List<MatchModel>> loadMatches() async {
    try {
      final String response = await rootBundle.loadString('assets/data/matches.json');
      final List<dynamic> data = json.decode(response) as List<dynamic>;
      return data.map((json) => MatchModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<TeamModel>> loadTeams() async {
    try {
      final String response = await rootBundle.loadString('assets/data/teams.json');
      final List<dynamic> data = json.decode(response) as List<dynamic>;
      return data.map((json) => TeamModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<PlayerModel>> loadPlayers() async {
    try {
      final String response = await rootBundle.loadString('assets/data/players.json');
      final List<dynamic> data = json.decode(response) as List<dynamic>;
      return data.map((json) => PlayerModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<VenueModel>> loadVenues() async {
    try {
      final String response = await rootBundle.loadString('assets/data/venues.json');
      final List<dynamic> data = json.decode(response) as List<dynamic>;
      return data.map((json) => VenueModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<BracketModel?> loadBracket() async {
    try {
      final String response = await rootBundle.loadString('assets/data/bracket.json');
      final Map<String, dynamic> data = json.decode(response) as Map<String, dynamic>;
      return BracketModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }
}
