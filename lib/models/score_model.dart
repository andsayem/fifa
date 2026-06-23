class ScoreModel {
  final List<int>? fullTime;
  final List<int>? halfTime;

  const ScoreModel({this.fullTime, this.halfTime});

  factory ScoreModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ScoreModel();
    return ScoreModel(
      fullTime: json['ft'] != null
          ? (json['ft'] as List).cast<int>()
          : null,
      halfTime: json['ht'] != null
          ? (json['ht'] as List).cast<int>()
          : null,
    );
  }

  Map<String, dynamic>? toJson() {
    if (fullTime == null && halfTime == null) return null;
    return {
      if (fullTime != null) 'ft': fullTime,
      if (halfTime != null) 'ht': halfTime,
    };
  }

  int? get homeScore => fullTime?.isNotEmpty == true ? fullTime![0] : null;
  int? get awayScore => fullTime?.length == 2 ? fullTime![1] : null;
  int? get homeHalf => halfTime?.isNotEmpty == true ? halfTime![0] : null;
  int? get awayHalf => halfTime?.length == 2 ? halfTime![1] : null;
}
