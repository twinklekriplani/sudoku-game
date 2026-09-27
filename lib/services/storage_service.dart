import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyPlayerName = 'playerName';
  static const String _keyCurrentLevel = 'currentLevel';
  static const String _keyTotalScore = 'totalScore';
  static const String _keyUnlockedLevels = 'unlockedLevels';
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Save the player's name
  static Future<bool> savePlayerName(String name) async {
    if (_prefs == null) await init();
    return await _prefs!.setString(_keyPlayerName, name);
  }

  // Retrieve the player's name
  static Future<String> getPlayerName() async {
    if (_prefs == null) await init();
    return _prefs!.getString(_keyPlayerName) ?? "Player";
  }

  // Check if a player exists
  static Future<bool> hasPlayer() async {
    final name = _prefs?.getString(_keyPlayerName);
    return name != null && name.isNotEmpty;
  }

  // Current Level
  static Future<bool> saveCurrentLevel(int level) async {
    if (_prefs == null) await init();
    final playerName = await getPlayerName();
    return await _prefs!.setInt('${playerName}_$_keyCurrentLevel', level);
  }

  static Future<int> getCurrentLevel() async {
    if (_prefs == null) await init();
    final playerName = await getPlayerName();
    return _prefs!.getInt('${playerName}_$_keyCurrentLevel') ?? 1;
  }

  // Total Score
  static Future<bool> saveTotalScore(int score) async {
    if (_prefs == null) await init();
    final playerName = await getPlayerName();
    return await _prefs!.setInt('${playerName}_$_keyTotalScore', score);
  }

  static Future<int> getTotalScore() async {
    if (_prefs == null) await init();
    final playerName = await getPlayerName();
    return _prefs!.getInt('${playerName}_$_keyTotalScore') ?? 0;
  }

  // Unlocked Levels
  static Future<bool> saveUnlockedLevels(int levels) async {
    if (_prefs == null) await init();
    final playerName = await getPlayerName();
    return await _prefs!.setInt('${playerName}_$_keyUnlockedLevels', levels);
  }

  static Future<int> getUnlockedLevels() async {
    if (_prefs == null) await init();
    final playerName = await getPlayerName();
    return _prefs!.getInt('${playerName}_$_keyUnlockedLevels') ?? 1;
  }
}
