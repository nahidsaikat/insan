import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../l10n/app_localizations.dart';
import '../models/season.dart'; // Make sure you import your Season model
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart'; // Ensure this is imported

class SettingsScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  // This can be nullable if your app flow allows SettingsScreen to be opened without an active season.
  // Based on previous errors, it's safer to keep it non-nullable here if it's always passed from Dashboard.
  final Season activeSeason;
  final Function(Season?) onSeasonChanged; // Callback to notify parent (MyApp)

  const SettingsScreen({
    super.key,
    required this.dbHelper,
    required this.activeSeason,
    required this.onSeasonChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  Future<void> _deactivateCurrentSeason() async {
    // Safely get localizations instance. Add ! if you're sure it won't be null
    final localizations = AppLocalizations.of(context); // Added ! for safety based on typical usage

    // Optional: Show a confirmation dialog before deactivating
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.deactivateSeasonConfirmTitle),
          content: Text(localizations.deactivateSeasonConfirmMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(localizations.cancelButton),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(localizations.deactivateButton),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // Create a copy of the active season, setting isActive to false
      final deactivatedSeason = widget.activeSeason.copyWith(
        isActive: false,
        endDate: DateTime.now(), // Changed endDate to saleEndDate as per Season model often has
      );

      // Update the season in the database
      await widget.dbHelper.updateSeason(deactivatedSeason);

      // Notify the parent widget (MyApp in this case) that there is no active season anymore.
      widget.onSeasonChanged(null);

      // Show a success message to the user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.seasonDeactivatedSuccess)),
        );
      }

      // Pop the SettingsScreen to go back to the previous screen.
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safely get localizations instance. Add ! if you're sure it won't be null
    final localizations = AppLocalizations.of(context); // Added ! for safety
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
            title: Text(localizations.currentActiveSeason),
            subtitle: Text(widget.activeSeason.name),
            leading: const Icon(Icons.leaderboard),
          ),
          const Divider(),

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
            title: Text(localizations.language), // New localization key
            trailing: DropdownButton<String>(
              value: settingsProvider.locale.languageCode, // Get current locale from provider
              onChanged: (String? newValue) {
                if (newValue != null) {
                  settingsProvider.setLocale(Locale(newValue)); // Set new locale via provider
                }
              },
              items: <String>['en', 'bn'] // Available language codes
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  // Display language names using localization
                  child: Text(value == 'en' ? localizations.english : localizations.bengali),
                );
              }).toList(),
            ),
          ),
          const Divider(),

          // Currency Symbol settings section (Moved after language for better grouping)
          // ListTile(
          //   title: Text(localizations.currencySymbol),
          //   trailing: DropdownButton<String>(
          //     value: settingsProvider.currencySymbol,
          //     onChanged: (String? newValue) {
          //       if (newValue != null) {
          //         settingsProvider.setCurrencySymbol(newValue);
          //       }
          //     },
          //     items: SettingsProvider.availableCurrencySymbols
          //         .map<DropdownMenuItem<String>>((String value) {
          //       return DropdownMenuItem<String>(
          //         value: value,
          //         child: Text(value),
          //       );
          //     }).toList(),
          //   ),
          // ),
          // const Divider(),

          // Option to deactivate the current season
          ListTile(
            title: Text(localizations.deactivateCurrentSeason),
            subtitle: Text(localizations.deactivateSeasonSubtitle),
            leading: const Icon(Icons.cancel, color: Colors.red),
            onTap: _deactivateCurrentSeason,
          ),
          const Divider(),

          // Add any other settings options here...
        ],
      ),
    );
  }
}