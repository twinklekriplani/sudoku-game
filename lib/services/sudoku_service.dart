import '../models/sudoku_level_model.dart';

class SudokuService {
  // A standard valid Sudoku solution board
  static const List<List<int>> _baseSolution = [
    [5, 3, 4, 6, 7, 8, 9, 1, 2],
    [6, 7, 2, 1, 9, 5, 3, 4, 8],
    [1, 9, 8, 3, 4, 2, 5, 6, 7],
    [8, 5, 9, 7, 6, 1, 4, 2, 3],
    [4, 2, 6, 8, 5, 3, 7, 9, 1],
    [7, 1, 3, 9, 2, 4, 8, 5, 6],
    [9, 6, 1, 5, 3, 7, 2, 8, 4],
    [2, 8, 7, 4, 1, 9, 6, 3, 5],
    [3, 4, 5, 2, 8, 6, 1, 7, 9],
  ];

  static List<List<int>> _createPuzzle(int cellsToRemove) {
    // For this assignment, we use a fixed pattern of removal based on the level
    // to simulate predefined puzzles without random generation logic here.
    List<List<int>> puzzle = _baseSolution.map((row) => List<int>.from(row)).toList();
    
    // A simple deterministic way to punch holes
    int removed = 0;
    int r = 0;
    int c = 0;
    while (removed < cellsToRemove) {
      if (puzzle[r][c] != 0) {
        // Skip every other to scatter the holes deterministically
        if ((r * 9 + c + removed) % 3 != 0) {
          puzzle[r][c] = 0;
          removed++;
        }
      }
      c++;
      if (c >= 9) {
        c = 0;
        r++;
        if (r >= 9) r = 0;
      }
    }
    return puzzle;
  }

  static SudokuLevel getLevel(int levelNumber) {
    String difficulty;
    int blanks;

    if (levelNumber <= 3) {
      difficulty = 'EASY';
      blanks = 20 + (levelNumber * 5); // L1: 25, L2: 30, L3: 35
    } else if (levelNumber <= 6) {
      difficulty = 'MEDIUM';
      blanks = 35 + ((levelNumber - 3) * 5); // L4: 40, L5: 45, L6: 50
    } else {
      difficulty = 'HARD';
      blanks = 50 + ((levelNumber - 6) * 3); // L7: 53, L8: 56, L9: 59, L10: 62
    }

    return SudokuLevel(
      level: levelNumber,
      difficulty: difficulty,
      puzzle: _createPuzzle(blanks),
      solution: _baseSolution,
    );
  }
}
