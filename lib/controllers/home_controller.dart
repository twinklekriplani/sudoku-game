import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';

class HomeController {
  // Use ValueNotifier for reactive state management without external packages
  final ValueNotifier<UserModel?> userModelNotifier = ValueNotifier<UserModel?>(null);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);

  Future<void> loadHomeData() async {
    isLoading.value = true;
    
    // Fetch from SharedPreferences
    final playerName = await StorageService.getPlayerName();
    final totalScore = await StorageService.getTotalScore();
    final unlockedLevels = await StorageService.getUnlockedLevels();
    // The current playable level is the highest unlocked level
    final currentLevel = unlockedLevels;

    // Create user model
    userModelNotifier.value = UserModel(
      playerName: playerName,
      currentLevel: currentLevel,
      totalScore: totalScore,
      unlockedLevels: unlockedLevels,
    );

    isLoading.value = false;
  }

  void onPlayPressed(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.levels).then((_) {
      loadHomeData();
    });
  }

  void onLeaderboardPressed(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.leaderboard);
  }

  void dispose() {
    userModelNotifier.dispose();
    isLoading.dispose();
  }
}
