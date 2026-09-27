import 'package:flutter/material.dart';
import '../views/welcome_screen.dart';
import '../views/home_screen.dart';
import '../views/level_selection_screen.dart';
import '../views/leaderboard_screen.dart';
import '../views/game_screen.dart';
import '../views/result_screen.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String home = '/home';
  static const String levels = '/levels';
  static const String leaderboard = '/leaderboard';
  static const String game = '/game';
  static const String result = '/result';

  static Map<String, WidgetBuilder> get routes {
    return {
      welcome: (context) => const WelcomeScreen(),
      home: (context) => const HomeScreen(),
      levels: (context) => const LevelSelectionScreen(),
      leaderboard: (context) => const LeaderboardScreen(),
      game: (context) => const GameScreen(),
      result: (context) => const ResultScreen(),
    };
  }
}
