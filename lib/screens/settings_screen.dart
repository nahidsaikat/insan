// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart'; // For localization
import '../providers/theme_provider.dart'; // <--- Import ThemeProvider
import '../providers/settings_provider.dart'; // <--- Also import SettingsProvider for other settings

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    // Access the ThemeProvider instance
    final themeProvider = Provider.of<ThemeProvider>(context);
    // Access the SettingsProvider instance (for currency/date, if implemented)
    final settingsProvider = Provider.of<SettingsProvider>(context);


    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settingsTitle), // Localized title for settings
      ),
      body: ListView(
        children: [
          // --- DARK MODE TOGGLE ---
          ListTile(
            title: Text(localizations.darkMode), // Localized "Dark Mode" text
            trailing: Switch(
              // Check if the current theme mode is dark to set the switch state
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (bool isDark) {
                // When the switch is toggled, update the theme mode in ThemeProvider
                themeProvider.setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
              },
            ),
          ),
          const Divider(), // Visual separator

          // --- Currency Symbol Selection (from SettingsProvider) ---
          ListTile(
            title: Text(localizations.currencySymbol),
            trailing: DropdownButton<String>(
              value: settingsProvider.currencySymbol,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  settingsProvider.setCurrencySymbol(newValue);
                }
              },
              items: SettingsProvider.availableCurrencySymbols
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          const Divider(),

          // --- Date Format Selection (from SettingsProvider) ---
          ListTile(
            title: Text(localizations.dateFormat),
            trailing: DropdownButton<String>(
              value: settingsProvider.dateFormat,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  settingsProvider.setDateFormat(newValue);
                }
              },
              items: SettingsProvider.availableDateFormats
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          const Divider(),

          // You can add more settings options here later
        ],
      ),
    );
  }
}