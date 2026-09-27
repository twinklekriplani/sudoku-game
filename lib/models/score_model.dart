class ScoreModel {
  final String playerName;
  final int score;
  final int level;
  final DateTime timestamp;

  ScoreModel({
    required this.playerName,
    required this.score,
    required this.level,
    required this.timestamp,
  });

  factory ScoreModel.fromJson(Map<String, dynamic> json) {
    return ScoreModel(
      playerName: json['playerName'] as String,
      score: json['score'] as int,
      level: json['level'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerName': playerName,
      'score': score,
      'level': level,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
