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
