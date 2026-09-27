import 'dart:async';
import 'package:flutter/material.dart';
import '../models/sudoku_level_model.dart';
import '../models/sudoku_cell_model.dart';
import '../models/result_data_model.dart';
import '../models/score_model.dart';
import '../services/sudoku_service.dart';
import '../services/score_service.dart';
import '../services/leaderboard_service.dart';
import '../services/storage_service.dart';
import '../routes/app_routes.dart';

class GameState {
  final List<List<SudokuCell>> board;
  final SudokuCell? selectedCell;
  final int wrongMoveCount;
  final int timeElapsed;
  final bool isCompleted;

  GameState({
    required this.board,
    this.selectedCell,
    this.wrongMoveCount = 0,
    this.timeElapsed = 0,
    this.isCompleted = false,
  });

  GameState copyWith({
    List<List<SudokuCell>>? board,
    SudokuCell? selectedCell,
    int? wrongMoveCount,
    int? timeElapsed,
    bool? isCompleted,
    bool clearSelected = false,
  }) {
    return GameState(
      board: board ?? this.board,
      selectedCell: clearSelected ? null : (selectedCell ?? this.selectedCell),
      wrongMoveCount: wrongMoveCount ?? this.wrongMoveCount,
      timeElapsed: timeElapsed ?? this.timeElapsed,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class GameController {
  late SudokuLevel currentLevelData;
  final ValueNotifier<GameState?> gameState = ValueNotifier<GameState?>(null);
  
  Timer? _timer;

  void initializeGame(int levelNumber) {
    currentLevelData = SudokuService.getLevel(levelNumber);
    _initBoard();
    startTimer();
  }

  void _initBoard() {
    List<List<SudokuCell>> initialBoard = [];
    
    for (int r = 0; r < 9; r++) {
      List<SudokuCell> row = [];
      for (int c = 0; c < 9; c++) {
        int puzzleVal = currentLevelData.puzzle[r][c];
        int solutionVal = currentLevelData.solution[r][c];
        
        row.add(SudokuCell(
          row: r,
          col: c,
          correctValue: solutionVal,
          isPrefilled: puzzleVal != 0,
          currentValue: puzzleVal,
          isError: false,
        ));
      }
      initialBoard.add(row);
    }

    gameState.value = GameState(board: initialBoard);
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (gameState.value != null && !gameState.value!.isCompleted) {
        gameState.value = gameState.value!.copyWith(
          timeElapsed: gameState.value!.timeElapsed + 1,
        );
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  void selectCell(int row, int col) {
    final state = gameState.value;
    if (state == null || state.isCompleted) return;

    final cell = state.board[row][col];
    if (cell.isPrefilled) return; // Cannot select prefilled cells

    gameState.value = state.copyWith(selectedCell: cell);
  }

  void enterNumber(BuildContext context, int number) {
    final state = gameState.value;
    if (state == null || state.selectedCell == null || state.isCompleted) return;

    final cell = state.selectedCell!;
    if (cell.isPrefilled) return;
    
    if (cell.currentValue == number) return;

    // Validation
    bool isValid = _validateMove(cell.row, cell.col, number, state.board);
    
    // Update the cell
    cell.currentValue = number;
    cell.isError = !isValid;

    int newWrongCount = state.wrongMoveCount + (isValid ? 0 : 1);

    // Create a new board reference to trigger update
    List<List<SudokuCell>> newBoard = List.from(state.board);

    gameState.value = state.copyWith(
      board: newBoard,
      wrongMoveCount: newWrongCount,
    );

    if (!isValid) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid move!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          duration: const Duration(milliseconds: 1000),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void removeNumber() {
    final state = gameState.value;
    if (state == null || state.selectedCell == null || state.isCompleted) return;

    final cell = state.selectedCell!;
    if (cell.isPrefilled) return;

    cell.currentValue = 0;
    cell.isError = false;

    List<List<SudokuCell>> newBoard = List.from(state.board);
    gameState.value = state.copyWith(board: newBoard);
  }

  bool _validateMove(int r, int c, int num, List<List<SudokuCell>> board) {
    // As per requirement, validation strictly compares against the authoritative solution
    // rather than the current user board state, which prevents the issue where 
    // an earlier incorrect move blocks the correct number from being accepted later.
    return num == board[r][c].correctValue;
  }

  void checkSolution(BuildContext context) {
    final state = gameState.value;
    if (state == null || state.isCompleted) return;

    bool isFull = true;
    bool isCorrect = true;

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final cell = state.board[r][c];
        if (cell.currentValue == 0) {
          isFull = false;
        } else if (cell.currentValue != cell.correctValue) {
          isCorrect = false;
        }
      }
    }

    if (!isFull) {
      _showMessage(context, 'Complete all cells before checking the solution.');
      return;
    }

    if (isCorrect) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      stopTimer();
      gameState.value = state.copyWith(isCompleted: true);
      _processWin(context, state);
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showMessage(context, 'Some numbers are incorrect.', color: Colors.orange);
    }
  }

  Future<void> _processWin(BuildContext context, GameState state) async {
    final int secondsElapsed = state.timeElapsed;
    final int wrongMoves = state.wrongMoveCount;
    
    // Calculate Scores
    final int timeBonus = ScoreService.calculateTimeBonus(secondsElapsed);
    final int penalty = ScoreService.calculateWrongMovePenalty(wrongMoves);
    final int finalScore = ScoreService.calculateFinalScore(
      secondsElapsed: secondsElapsed,
      wrongMoves: wrongMoves,
    );

    // Save Total Score
    final int currentTotalScore = await StorageService.getTotalScore();
    await StorageService.saveTotalScore(currentTotalScore + finalScore);

    // Unlock Next Level
    final int currentUnlocked = await StorageService.getUnlockedLevels();
    final int thisLevel = currentLevelData.level;
    if (thisLevel == currentUnlocked && thisLevel < 10) {
      await StorageService.saveUnlockedLevels(thisLevel + 1);
    }

    // Save to Leaderboard
    final String playerName = await StorageService.getPlayerName();
    final newScore = ScoreModel(
      playerName: playerName,
      score: finalScore,
      level: thisLevel,
      timestamp: DateTime.now(),
    );
    
    await LeaderboardService.saveScore(newScore);

    // Prepare Result Data
    final resultData = ResultData(
      level: thisLevel,
      difficulty: currentLevelData.difficulty,
      timeElapsed: secondsElapsed,
      wrongMoves: wrongMoves,
      baseScore: ScoreService.baseScore,
      timeBonus: timeBonus,
      wrongMovePenalty: penalty,
      finalScore: finalScore,
    );

    if (context.mounted) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.result,
        arguments: resultData,
      );
    }
  }

  void restartGame() {
    _initBoard();
    gameState.value = gameState.value?.copyWith(
      wrongMoveCount: 0,
      timeElapsed: 0,
      isCompleted: false,
      clearSelected: true,
    );
    startTimer();
  }

  void _showMessage(BuildContext context, String msg, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void dispose() {
    stopTimer();
    gameState.dispose();
  }

  String formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
