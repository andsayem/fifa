enum MatchStatus { upcoming, live, finished }

class MatchModel {
  final int id;
  final String homeTeam;
  final String awayTeam;
  final String date;
  final String time;
  final String stadium;
  final String status; // upcoming, live, finished
  final int? homeScore;
  final int? awayScore;
  final String? liveMinute;
  final String? group; // group name from GitHub
  final String? round; // round name from GitHub
  final List<Map<String, dynamic>>? goals1;
  final List<Map<String, dynamic>>? goals2;

  MatchModel({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.date,
    required this.time,
    required this.stadium,
    required this.status,
    this.homeScore,
    this.awayScore,
    this.liveMinute,
    this.group,
    this.round,
    this.goals1,
    this.goals2,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] as int,
      homeTeam: json['home_team'] as String,
      awayTeam: json['away_team'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      stadium: json['stadium'] as String,
      status: json['status'] as String,
      homeScore: json['home_score'] as int?,
      awayScore: json['away_score'] as int?,
      liveMinute: json['live_minute'] as String?,
    );
  }

  factory MatchModel.fromGitHubJson(Map<String, dynamic> json, int index) {
    final date = json['date'] as String? ?? '';
    final timeRaw = json['time'] as String? ?? '';
    final timeClean = timeRaw.replaceAll(RegExp(r'\s*UTC[+-]\d+(:\d+)?'), '');
    final score = json['score'] as Map<String, dynamic>?;
    final ft = score?['ft'] as List<dynamic>?;
    final homeScore = ft != null && ft.length > 1 ? ft[0] as int? : null;
    final awayScore = ft != null && ft.length > 1 ? ft[1] as int? : null;

    // Determine status
    String status;
    if (ft != null) {
      status = 'finished';
    } else {
      status = 'upcoming';
    }

    return MatchModel(
      id: index,
      homeTeam: json['team1'] as String? ?? '',
      awayTeam: json['team2'] as String? ?? '',
      date: date,
      time: timeClean,
      stadium: json['ground'] as String? ?? '',
      status: status,
      homeScore: homeScore,
      awayScore: awayScore,
      group: json['group'] as String?,
      round: json['round'] as String?,
      goals1: (json['goals1'] as List<dynamic>?)
          ?.map((g) => g as Map<String, dynamic>)
          .toList(),
      goals2: (json['goals2'] as List<dynamic>?)
          ?.map((g) => g as Map<String, dynamic>)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'home_team': homeTeam,
      'away_team': awayTeam,
      'date': date,
      'time': time,
      'stadium': stadium,
      'status': status,
      'home_score': homeScore,
      'away_score': awayScore,
      'live_minute': liveMinute,
    };
  }
}
