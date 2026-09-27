class SudokuLevel {
  final int level;
  final String difficulty;
  final List<List<int>> puzzle;
  final List<List<int>> solution;

  SudokuLevel({
    required this.level,
    required this.difficulty,
    required this.puzzle,
    required this.solution,
  });
}
