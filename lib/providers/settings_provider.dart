// lib/providers/settings_provider.dart (Example of how it should look)
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _currencySymbol = '\$'; // Default currency symbol
  Locale _locale = const Locale('en', ''); // Default locale

  // Static list of available currency symbols (if not already in SettingsProvider)
  static const List<String> availableCurrencySymbols = ['৳', '\$', '€', '£']; // Added '৳' for Taka

  ThemeMode get themeMode => _themeMode;
  String get currencySymbol => _currencySymbol;
  Locale get locale => _locale; // Getter for locale

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? ThemeMode.system.index];
    _currencySymbol = prefs.getString('currencySymbol') ?? '\$';
    _locale = Locale(prefs.getString('languageCode') ?? 'en', ''); // Load language code

    notifyListeners();
  }

  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    _saveSettings();
    notifyListeners();
  }

  void setCurrencySymbol(String symbol) {
    _currencySymbol = symbol;
    _saveSettings();
    notifyListeners();
  }

  // --- New method to set locale ---
  void setLocale(Locale newLocale) {
    if (_locale != newLocale) {
      _locale = newLocale;
      _saveSettings();
      notifyListeners();
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('themeMode', _themeMode.index);
    prefs.setString('currencySymbol', _currencySymbol);
    prefs.setString('languageCode', _locale.languageCode); // Save language code
  }
}