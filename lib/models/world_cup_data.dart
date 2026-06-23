import 'match_model.dart';

class WorldCupData {
  final String name;
  final List<MatchModel> matches;

  const WorldCupData({required this.name, required this.matches});

  factory WorldCupData.fromJson(Map<String, dynamic> json) {
    return WorldCupData(
      name: json['name'] as String? ?? 'World Cup 2026',
      matches: (json['matches'] as List<dynamic>?)
              ?.map((m) => MatchModel.fromGitHubJson(
                  m as Map<String, dynamic>, 0))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'matches': matches.map((m) => m.toJson()).toList(),
      };

  List<MatchModel> get allMatches => matches;

  List<MatchModel> get finishedMatches =>
      matches.where((m) => m.status == 'finished').toList();

  List<MatchModel> get upcomingMatches =>
      matches.where((m) => m.status == 'upcoming').toList();

  List<MatchModel> get liveMatches =>
      matches.where((m) => m.status == 'live').toList();

  List<MatchModel> get todayMatches {
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return matches.where((m) => m.date == todayStr).toList();
  }

  List<String> get teams {
    final names = <String>{};
    for (final m in matches) {
      if (m.homeTeam.isNotEmpty) names.add(m.homeTeam);
      if (m.awayTeam.isNotEmpty) names.add(m.awayTeam);
    }
    return names.toList()..sort();
  }

  List<String> get venues {
    final names = <String>{};
    for (final m in matches) {
      if (m.stadium.isNotEmpty) names.add(m.stadium);
    }
    return names.toList()..sort();
  }

  List<String> get groups {
    final names = <String>{};
    for (final m in matches) {
      if (m.group != null && m.group!.isNotEmpty) names.add(m.group!);
    }
    return names.toList()..sort();
  }

  List<String> get rounds {
    final names = <String>{};
    for (final m in matches) {
      if (m.round != null && m.round!.isNotEmpty) names.add(m.round!);
    }
    return names.toList();
  }
}
