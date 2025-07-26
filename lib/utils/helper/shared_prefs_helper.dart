import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static final SharedPrefsHelper _instance = SharedPrefsHelper._internal();
  static SharedPreferences? _prefs;

  factory SharedPrefsHelper() {
    return _instance;
  }

  SharedPrefsHelper._internal();

  /// Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save String Value
  Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  /// Get String Value
  String? getString(String key) {
    return _prefs?.getString(key);
  }

  /// Save Boolean Value
  Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  /// Get Boolean Value
  bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  /// Remove Key
  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }
}
