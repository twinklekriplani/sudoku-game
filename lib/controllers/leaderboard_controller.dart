import 'package:flutter/material.dart';
import '../models/score_model.dart';
import '../services/leaderboard_service.dart';
import '../services/storage_service.dart';

class LeaderboardController {
  final ValueNotifier<List<ScoreModel>> leaderboardNotifier = ValueNotifier<List<ScoreModel>>([]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);
  String currentPlayerName = 'Player';

  Future<void> loadLeaderboard() async {
    isLoading.value = true;
    
    // Get current player name for highlighting
    currentPlayerName = await StorageService.getPlayerName();
    
    // Fetch top 10 scores
    final scores = await LeaderboardService.getLeaderboard();
    
    leaderboardNotifier.value = scores;
    isLoading.value = false;
  }

  void dispose() {
    leaderboardNotifier.dispose();
    isLoading.dispose();
  }
}
