import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;

  // Keys
  static const String keyPets = 'tailO_pets_data';
  static const String keyReminders = 'tailO_reminders_data';
  static const String keyLogin = 'tailO_is_logged_in';
  static const String keyUser = 'tailO_user_info';

  /// Must be called before using any other method
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Generic Getters/Setters ---

  String? getString(String key) => _prefs.getString(key);

  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  List<String>? getStringList(String key) => _prefs.getStringList(key);

  Future<void> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  bool getBool(String key, {bool defaultValue = false}) =>
      _prefs.getBool(key) ?? defaultValue;

  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  // --- Maintenance ---

  Future<void> remove(String key) => _prefs.remove(key);

  Future<void> clearAll() => _prefs.clear();
}
