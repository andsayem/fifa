import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/tournament_model.dart';

class HistoryRepository {
  static const _cacheBox = 'history_cache';
  static const _cacheKey = 'tournaments';
  static const _assetPath = 'assets/data/world_cup_history.json';

  List<TournamentModel>? _cachedTournaments;

  Future<List<TournamentModel>> getTournaments() async {
    if (_cachedTournaments != null) return _cachedTournaments!;
    _cachedTournaments = await _loadFromAsset();
    return _cachedTournaments!;
  }

  Future<List<TournamentModel>> _loadFromAsset() async {
    try {
      final jsonStr = await rootBundle.loadString(_assetPath);
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final list = data['tournaments'] as List<dynamic>;
      final tournaments = list
          .map((e) => TournamentModel.fromJson(e as Map<String, dynamic>))
          .toList();
      await _cacheTournaments(tournaments);
      return tournaments;
    } catch (e) {
      final cached = await _loadFromCache();
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  Future<void> _cacheTournaments(List<TournamentModel> tournaments) async {
    try {
      final box = await Hive.openBox(_cacheBox);
      final jsonList = tournaments
          .map(
            (t) => {
              'year': t.year,
              'host': t.host,
              'winner': t.winner,
              'runner_up': t.runnerUp,
              'third_place': t.thirdPlace,
              'fourth_place': t.fourthPlace,
              'teams': t.teams,
              'matches': t.matches,
              'goals': t.goals,
              'top_scorer': {
                'name': t.topScorer.name,
                'country': t.topScorer.country,
                'goals': t.topScorer.goals,
              },
              'best_player': t.bestPlayer,
              'final': {
                'winner_score': t.final_.winnerScore,
                'runner_up_score': t.final_.runnerUpScore,
                'stadium': t.final_.stadium,
                'city': t.final_.city,
              },
              'poster': t.poster,
              'description': t.description,
            },
          )
          .toList();
      await box.put(_cacheKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  Future<List<TournamentModel>> _loadFromCache() async {
    try {
      final box = await Hive.openBox(_cacheBox);
      final cached = box.get(_cacheKey) as String?;
      if (cached == null) return [];
      final list = jsonDecode(cached) as List<dynamic>;
      return list
          .map((e) => TournamentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<TournamentModel> search(
    List<TournamentModel> tournaments,
    String query,
  ) {
    if (query.isEmpty) return tournaments;
    final q = query.toLowerCase();
    return tournaments.where((t) {
      return t.year.toString().contains(q) ||
          t.winner.toLowerCase().contains(q) ||
          t.runnerUp.toLowerCase().contains(q) ||
          t.hostDisplay.toLowerCase().contains(q) ||
          t.topScorer.name.toLowerCase().contains(q) ||
          t.topScorer.country.toLowerCase().contains(q) ||
          t.bestPlayer.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q);
    }).toList();
  }

  List<TournamentModel> filter(
    List<TournamentModel> tournaments, {
    String? champion,
    String? host,
    int? decade,
  }) {
    var list = List<TournamentModel>.from(tournaments);
    if (champion != null && champion.isNotEmpty) {
      list = list.where((t) => t.winner == champion).toList();
    }
    if (host != null && host.isNotEmpty) {
      list = list.where((t) => t.host.contains(host)).toList();
    }
    if (decade != null) {
      list = list
          .where((t) => t.year >= decade && t.year < decade + 10)
          .toList();
    }
    return list;
  }

  Map<String, int> getChampionCounts(List<TournamentModel> tournaments) {
    final counts = <String, int>{};
    for (final t in tournaments) {
      if (!t.isTBD) {
        counts[t.winner] = (counts[t.winner] ?? 0) + 1;
      }
    }
    return counts;
  }
}
