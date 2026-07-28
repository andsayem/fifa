class TournamentModel {
  final int year;
  final List<String> host;
  final String winner;
  final String runnerUp;
  final String thirdPlace;
  final String fourthPlace;
  final int teams;
  final int matches;
  final int goals;
  final TopScorer topScorer;
  final String bestPlayer;
  final FinalMatch final_;
  final String poster;
  final String description;

  TournamentModel({
    required this.year,
    required this.host,
    required this.winner,
    required this.runnerUp,
    required this.thirdPlace,
    required this.fourthPlace,
    required this.teams,
    required this.matches,
    required this.goals,
    required this.topScorer,
    required this.bestPlayer,
    required this.final_,
    required this.poster,
    required this.description,
  });

  factory TournamentModel.fromJson(Map<String, dynamic> json) {
    return TournamentModel(
      year: json['year'] as int,
      host: (json['host'] as List<dynamic>).map((e) => e as String).toList(),
      winner: json['winner'] as String,
      runnerUp: json['runner_up'] as String,
      thirdPlace: json['third_place'] as String,
      fourthPlace: json['fourth_place'] as String,
      teams: json['teams'] as int,
      matches: json['matches'] as int,
      goals: json['goals'] as int,
      topScorer: TopScorer.fromJson(json['top_scorer'] as Map<String, dynamic>),
      bestPlayer: json['best_player'] as String,
      final_: FinalMatch.fromJson(json['final'] as Map<String, dynamic>),
      poster: json['poster'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  String get hostDisplay => host.join(' & ');

  bool get isTBD => winner == 'TBD';

  bool get hasPenalties =>
      final_.winnerScore == final_.runnerUpScore;
}

class TopScorer {
  final String name;
  final String country;
  final int goals;

  TopScorer({
    required this.name,
    required this.country,
    required this.goals,
  });

  factory TopScorer.fromJson(Map<String, dynamic> json) {
    return TopScorer(
      name: json['name'] as String,
      country: json['country'] as String,
      goals: json['goals'] as int,
    );
  }
}

class FinalMatch {
  final int winnerScore;
  final int runnerUpScore;
  final String stadium;
  final String city;

  FinalMatch({
    required this.winnerScore,
    required this.runnerUpScore,
    required this.stadium,
    required this.city,
  });

  factory FinalMatch.fromJson(Map<String, dynamic> json) {
    return FinalMatch(
      winnerScore: json['winner_score'] as int,
      runnerUpScore: json['runner_up_score'] as int,
      stadium: json['stadium'] as String,
      city: json['city'] as String,
    );
  }

  String get scoreDisplay => '$winnerScore - $runnerUpScore';
}
