class PlayerModel {
  final String teamName;
  final String name;
  final String position;
  final int number;

  PlayerModel({
    required this.teamName,
    required this.name,
    required this.position,
    required this.number,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      teamName: json['team_name'] as String,
      name: json['name'] as String,
      position: json['position'] as String,
      number: json['number'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'team_name': teamName,
      'name': name,
      'position': position,
      'number': number,
    };
  }
}
