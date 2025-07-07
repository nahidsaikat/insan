// lib/providers/settings_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  String _currencySymbol = '\$'; // Default currency symbol
  String _dateFormat = 'DD/MM/YYYY'; // Default date format

  // List of available options (you can expand these)
  static const List<String> availableCurrencySymbols = ['\$', '৳', '€', '£', '₹']; // $, BDT, EUR, GBP, INR
  static const List<String> availableDateFormats = ['DD/MM/YYYY', 'MM/DD/YYYY', 'YYYY-MM-DD'];

  String get currencySymbol => _currencySymbol;
  String get dateFormat => _dateFormat;

  SettingsProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _currencySymbol = prefs.getString('currencySymbol') ?? '\$';
    _dateFormat = prefs.getString('dateFormat') ?? 'DD/MM/YYYY';
    notifyListeners();
  }

  Future<void> setCurrencySymbol(String symbol) async {
    if (_currencySymbol == symbol) return;
    _currencySymbol = symbol;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currencySymbol', symbol);
    notifyListeners();
  }

  Future<void> setDateFormat(String format) async {
    if (_dateFormat == format) return;
    _dateFormat = format;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dateFormat', format);
    notifyListeners();
  }
}