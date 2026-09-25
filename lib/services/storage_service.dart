import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyPlayerName = 'playerName';
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save the player's name
  static Future<bool> savePlayerName(String name) async {
    if (_prefs == null) await init();
    return await _prefs!.setString(_keyPlayerName, name);
  }

  // Retrieve the player's name
  static Future<String?> getPlayerName() async {
    if (_prefs == null) await init();
    return _prefs!.getString(_keyPlayerName);
  }

  // Check if a player exists
  static Future<bool> hasPlayer() async {
    final name = await getPlayerName();
    return name != null && name.isNotEmpty;
  }
}
