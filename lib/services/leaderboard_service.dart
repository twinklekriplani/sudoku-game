import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/score_model.dart';

class LeaderboardService {
  static const String _keyLeaderboard = 'leaderboard';

  static Future<void> saveScore(ScoreModel newScore) async {
    final prefs = await SharedPreferences.getInstance();
    final playerName = newScore.playerName;
    final String userLeaderboardKey = '${playerName}_$_keyLeaderboard';
    
    // Read existing scores
    final String? jsonString = prefs.getString(userLeaderboardKey);
    List<ScoreModel> scores = [];
    
    if (jsonString != null && jsonString.isNotEmpty) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      scores = jsonList.map((json) => ScoreModel.fromJson(json as Map<String, dynamic>)).toList();
    }

    // Add new score
    scores.add(newScore);

    // Sort descending by score
    scores.sort((a, b) => b.score.compareTo(a.score));

    // Keep only top 10
    if (scores.length > 10) {
      scores = scores.take(10).toList();
    }

    // Save back to SharedPreferences
    final List<Map<String, dynamic>> updatedJsonList = scores.map((s) => s.toJson()).toList();
    await prefs.setString(userLeaderboardKey, jsonEncode(updatedJsonList));
  }

  static Future<List<ScoreModel>> getLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final playerName = prefs.getString('playerName') ?? "Player";
    final String userLeaderboardKey = '${playerName}_$_keyLeaderboard';
    
    final String? jsonString = prefs.getString(userLeaderboardKey);
    
    if (jsonString != null && jsonString.isNotEmpty) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final scores = jsonList.map((json) => ScoreModel.fromJson(json as Map<String, dynamic>)).toList();
      return scores;
    }
    
    return [];
  }
}
