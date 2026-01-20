import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  // Key for storage
  static const String _keyTheme = 'tailO_theme_mode';

  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(
    ThemeMode.dark,
  );

  static bool get isDark => themeMode.value == ThemeMode.dark;

  /// Load saved theme from storage (Call this in main.dart)
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkStored = prefs.getBool(_keyTheme) ?? true; // Default to Dark
    themeMode.value = isDarkStored ? ThemeMode.dark : ThemeMode.light;
  }

  /// Toggle and Save
  static Future<void> toggleTheme(bool isDark) async {
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTheme, isDark);
  }
}
