class GoalModel {
  final String name;
  final String minute;
  final bool penalty;
  final bool ownGoal;

  const GoalModel({
    required this.name,
    required this.minute,
    this.penalty = false,
    this.ownGoal = false,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      name: json['name'] as String? ?? '',
      minute: json['minute'] as String? ?? '',
      penalty: json['penalty'] as bool? ?? false,
      ownGoal: json['owngoal'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'minute': minute,
        'penalty': penalty,
        'owngoal': ownGoal,
      };
}
