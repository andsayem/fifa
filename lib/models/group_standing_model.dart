import 'team_model.dart';

class GroupStandingModel {
  final TeamModel team;
  int played = 0;
  int won = 0;
  int drawn = 0;
  int lost = 0;
  int goalsFor = 0;
  int goalsAgainst = 0;

  GroupStandingModel({required this.team});

  int get goalDifference => goalsFor - goalsAgainst;
  int get points => (won * 3) + (drawn * 1);
}
