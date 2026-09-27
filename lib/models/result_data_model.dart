class ResultData {
  final int level;
  final String difficulty;
  final int timeElapsed;
  final int wrongMoves;
  final int baseScore;
  final int timeBonus;
  final int wrongMovePenalty;
  final int finalScore;

  ResultData({
    required this.level,
    required this.difficulty,
    required this.timeElapsed,
    required this.wrongMoves,
    required this.baseScore,
    required this.timeBonus,
    required this.wrongMovePenalty,
    required this.finalScore,
  });
}
