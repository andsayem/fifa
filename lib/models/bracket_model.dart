class BracketMatchModel {
  final String id;
  final String home;
  final String away;
  final String venue;
  final String date;
  final String time;
  final int? homeScore;
  final int? awayScore;
  final String status;

  BracketMatchModel({
    required this.id,
    required this.home,
    required this.away,
    required this.venue,
    required this.date,
    required this.time,
    this.homeScore,
    this.awayScore,
    required this.status,
  });

  factory BracketMatchModel.fromJson(Map<String, dynamic> json) {
    return BracketMatchModel(
      id: json['id'] ?? '',
      home: json['home'] ?? 'TBD',
      away: json['away'] ?? 'TBD',
      venue: json['venue'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      homeScore: json['home_score'],
      awayScore: json['away_score'],
      status: json['status'] ?? 'upcoming',
    );
  }
}

class BracketModel {
  final List<BracketMatchModel> roundOf32;
  final List<BracketMatchModel> roundOf16;
  final List<BracketMatchModel> quarterFinals;
  final List<BracketMatchModel> semiFinals;
  final BracketMatchModel thirdPlace;
  final BracketMatchModel final_;

  BracketModel({
    required this.roundOf32,
    required this.roundOf16,
    required this.quarterFinals,
    required this.semiFinals,
    required this.thirdPlace,
    required this.final_,
  });

  factory BracketModel.fromJson(Map<String, dynamic> json) {
    return BracketModel(
      roundOf32: (json['round_of_32'] as List)
          .map((e) => BracketMatchModel.fromJson(e))
          .toList(),
      roundOf16: (json['round_of_16'] as List)
          .map((e) => BracketMatchModel.fromJson(e))
          .toList(),
      quarterFinals: (json['quarter_finals'] as List)
          .map((e) => BracketMatchModel.fromJson(e))
          .toList(),
      semiFinals: (json['semi_finals'] as List)
          .map((e) => BracketMatchModel.fromJson(e))
          .toList(),
      thirdPlace: BracketMatchModel.fromJson(json['third_place']),
      final_: BracketMatchModel.fromJson(json['final']),
    );
  }
}
