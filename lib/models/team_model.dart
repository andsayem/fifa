class TeamModel {
  final int id;
  final String name;
  final String logo;
  final String group;

  TeamModel({
    required this.id,
    required this.name,
    required this.logo,
    required this.group,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'] as int,
      name: json['name'] as String,
      logo: json['logo'] as String,
      group: json['group'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'group': group,
    };
  }
}
