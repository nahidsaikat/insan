// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  // Load theme mode from SharedPreferences
  void _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode');
    if (isDarkMode == true) {
      _themeMode = ThemeMode.dark;
    } else if (isDarkMode == false) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system; // If not set, default to system
    }
    notifyListeners(); // Notify listeners after theme mode is loaded
  }

  // Set theme mode and save to SharedPreferences
  void setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return; // No change

    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.dark) {
      prefs.setBool('isDarkMode', true);
    } else if (mode == ThemeMode.light) {
      prefs.setBool('isDarkMode', false);
    } else {
      // If setting to system, remove the specific dark mode preference
      prefs.remove('isDarkMode');
    }
    notifyListeners(); // Notify listeners that the theme mode has changed
  }

  // Helper for toggle
  void toggleTheme(bool isDark) {
    setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}