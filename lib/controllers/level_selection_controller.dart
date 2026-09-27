import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../routes/app_routes.dart';

class LevelSelectionController {
  final ValueNotifier<int> unlockedLevelsNotifier = ValueNotifier<int>(1);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);

  Future<void> loadLevelProgress() async {
    isLoading.value = true;
    final unlocked = await StorageService.getUnlockedLevels();
    unlockedLevelsNotifier.value = unlocked;
    isLoading.value = false;
  }

  bool isLevelUnlocked(int level) {
    return level <= unlockedLevelsNotifier.value;
  }

  void onLevelSelected(BuildContext context, int level) {
    if (isLevelUnlocked(level)) {
      // Navigate to Game Screen passing the level argument
      Navigator.pushNamed(
        context,
        AppRoutes.game,
        arguments: level,
      ).then((_) {
        // Reload progress in case a level was completed and unlocked
        loadLevelProgress();
      });
    } else {
      // Show SnackBar for locked level
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Complete the previous level to unlock this level.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void dispose() {
    unlockedLevelsNotifier.dispose();
    isLoading.dispose();
  }
}
