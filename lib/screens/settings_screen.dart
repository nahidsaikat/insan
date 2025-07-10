import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../l10n/app_localizations.dart';
import '../models/season.dart'; // Make sure you import your Season model
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final Season activeSeason; // The currently active season passed from Dashboard/Main
  final Function(Season?) onSeasonChanged; // Callback to notify parent (MyApp)

  const SettingsScreen({
    super.key,
    required this.dbHelper,
    required this.activeSeason, // Expects an active season to manage its settings
    required this.onSeasonChanged, // This callback is crucial for state updates in MyApp
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  // --- New method to deactivate the current active season ---
  Future<void> _deactivateCurrentSeason() async {
    final localizations = AppLocalizations.of(context);

    // Optional: Show a confirmation dialog before deactivating
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.deactivateSeasonConfirmTitle), // New localization key
          content: Text(localizations.deactivateSeasonConfirmMessage), // New localization key
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(localizations.cancelButton),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(localizations.deactivateButton), // New localization key
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // Create a copy of the active season, setting isActive to false
      final deactivatedSeason = widget.activeSeason.copyWith(
        isActive: false,
        endDate: DateTime.now(), // Set the end date when deactivating
      );

      // Update the season in the database
      await widget.dbHelper.updateSeason(deactivatedSeason);

      // Notify the parent widget (MyApp in this case) that there is no active season anymore.
      // This will cause MyApp to re-render the SeasonManagementScreen.
      widget.onSeasonChanged(null);

      // Show a success message to the user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.seasonDeactivatedSuccess)),
        );
      }

      // Pop the SettingsScreen to go back to the previous screen.
      // The parent (MyApp) will then automatically navigate to SeasonManagementScreen
      // because _activeSeason is now null.
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // It's generally safe to get AppLocalizations here within a child widget's build method
    final localizations = AppLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settingsTitle),
      ),
      body: ListView(
        children: [
          // Display the name of the currently active season for context
          ListTile(
            title: Text(localizations.currentActiveSeason), // New localization key
            subtitle: Text(widget.activeSeason.name),
            leading: const Icon(Icons.leaderboard),
          ),
          const Divider(), // A visual separator

          // Theme settings section
          SwitchListTile(
            title: Text(localizations.darkMode),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
          ),
          const Divider(),

          // Language settings section
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

          // --- New option to deactivate the current season ---
          ListTile(
            title: Text(localizations.deactivateCurrentSeason), // New localization key
            subtitle: Text(localizations.deactivateSeasonSubtitle), // New localization key
            leading: const Icon(Icons.cancel, color: Colors.red), // A clear icon
            onTap: _deactivateCurrentSeason, // Call the new method when tapped
          ),
          const Divider(),

          // Add any other settings options here...
        ],
      ),
    );
  }
}