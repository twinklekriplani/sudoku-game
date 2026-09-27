class UserModel {
  final String playerName;
  final int currentLevel;
  final int totalScore;
  final int unlockedLevels;

  UserModel({
    required this.playerName,
    this.currentLevel = 1,
    this.totalScore = 0,
    this.unlockedLevels = 1,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      playerName: json['playerName'] as String? ?? 'Player',
      currentLevel: json['currentLevel'] as int? ?? 1,
      totalScore: json['totalScore'] as int? ?? 0,
      unlockedLevels: json['unlockedLevels'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerName': playerName,
      'currentLevel': currentLevel,
      'totalScore': totalScore,
      'unlockedLevels': unlockedLevels,
    };
  }
}
