class ScoreService {
  static const int baseScore = 1000;
  static const int wrongMovePenalty = 20;

  static int calculateTimeBonus(int secondsElapsed) {
    if (secondsElapsed < 120) {
      // Less than 2 minutes
      return 500;
    } else if (secondsElapsed < 300) {
      // Less than 5 minutes
      return 300;
    } else if (secondsElapsed < 600) {
      // Less than 10 minutes
      return 100;
    } else {
      // 10 minutes or more
      return 0;
    }
  }

  static int calculateWrongMovePenalty(int wrongMoves) {
    return wrongMoves * wrongMovePenalty;
  }

  static int calculateFinalScore({
    required int secondsElapsed,
    required int wrongMoves,
  }) {
    int timeBonus = calculateTimeBonus(secondsElapsed);
    int penalty = calculateWrongMovePenalty(wrongMoves);

    int finalScore = baseScore + timeBonus - penalty;

    if (finalScore < 0) {
      finalScore = 0;
    }

    return finalScore;
  }
}
