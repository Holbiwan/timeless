import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setValue(String key, dynamic value) async {
    if (value is String) {
      await _prefs!.setString(key, value);
    } else if (value is int) {
      await _prefs!.setInt(key, value);
    } else if (value is double) {
      await _prefs!.setDouble(key, value);
    } else if (value is bool) {
      await _prefs!.setBool(key, value);
    } else if (value is List<String>) {
      await _prefs!.setStringList(key, value);
    } else {}
  }

  static String getString(String key) {
    return _prefs!.getString(key) ?? '';
  }

  static int getInt(String key) {
    return _prefs!.getInt(key) ?? 0;
  }

  static double getDouble(String key) {
    return _prefs!.getDouble(key) ?? 0;
  }

  static bool getBool(String key) {
    return _prefs!.getBool(key) ?? false;
  }

  static List<String> getList(String key) {
    return _prefs!.getStringList(key) ?? [];
  }

  static Future<void> remove(String key)async{
    await _prefs!.remove(key);
  }

  static Future<void> clear() async {
    await _prefs!.clear();
  }

  // Convenience methods
  static Future<void> setString(String key, String value) async {
    await _prefs!.setString(key, value);
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs!.setBool(key, value);
  }

  // User type management
  static Future<void> setUserType(String userType) async {
    await setString('userType', userType);
  }

  static String getUserType() {
    return getString('userType');
  }

  static bool isEmployer() {
    return getUserType() == 'employer';
  }

  static bool isCandidate() {
    return getUserType() == 'candidate';
  }
}
