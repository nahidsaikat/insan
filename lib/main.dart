import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:path/path.dart';
import 'package:provider/provider.dart';
import './database/database_helper.dart';
import './models/season.dart';
import './l10n/app_localizations.dart';
import './screens/season_management_screen.dart';
import './screens/dashboard_screen.dart';
import './providers/theme_provider.dart';
import './providers/settings_provider.dart';

// Your existing main function (if any)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // Provide ThemeProvider
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Season? _activeSeason;

  @override
  void initState() {
    super.initState();
    _loadActiveSeason();
  }

  Future<void> _loadActiveSeason() async {
    final active = await _dbHelper.getActiveSeason();
    setState(() {
      _activeSeason = active;
    });
  }

  void _setActiveSeason(Season? season) {
    setState(() {
      _activeSeason = season;
    });
    // You might want to update the database here to mark it as active
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'insan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light, // Default light theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        // Define other light theme properties
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.indigo, // Or any color for dark mode primary
        brightness: Brightness.dark, // Dark theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo, // Darker app bar for dark mode
          foregroundColor: Colors.white,
        ),
        // Define other dark theme properties
      ),
      themeMode: themeProvider.themeMode,
      // Localization setup
      localizationsDelegates: const [
        AppLocalizations.delegate, // Your generated app localizations
        GlobalMaterialLocalizations.delegate, // Material Design localizations
        GlobalWidgetsLocalizations.delegate, // Widgets localizations
        GlobalCupertinoLocalizations.delegate, // Cupertino localizations (if you use Cupertino widgets)
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('bn', ''), // Bengali (Bangla)
      ],
      // Set the default locale or let the system decide
      locale: const Locale('bn', ''), // Force Bengali for now for testing

      // Here's where your UI will go.
      // For the landing screen logic, we'll use a `FutureBuilder` to wait for
      // the active season to load, and then conditionally show the appropriate screen.
      home: FutureBuilder<Season?>(
        future: _dbHelper.getActiveSeason(), // Your method to get active season
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error loading season: ${snapshot.error}')),
            );
          } else {
            final activeSeason = snapshot.data;
            if (activeSeason == null) {
              // No active season, go to Season Management to create/select one
              return SeasonManagementScreen(
                dbHelper: _dbHelper,
                onSeasonSelected: _setActiveSeason,
              );
            } else {
              // Active season exists, go to Dashboard
              return DashboardScreen(
                dbHelper: _dbHelper,
                activeSeason: activeSeason,
                onSeasonChanged: _setActiveSeason,
              );
            }
          }
        },
      ),
    );
  }
}

// Placeholder Screens (You'll create these files and their content next)
// For now, just define them as StatelessWidget to avoid errors.
// class SeasonManagementScreen extends StatelessWidget {
//   final DatabaseHelper dbHelper;
//   final Function(Season?) onSeasonSelected;
//
//   const SeasonManagementScreen({
//     super.key,
//     required this.dbHelper,
//     required this.onSeasonSelected,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // Implement UI later
//     return Scaffold(
//       appBar: AppBar(title: Text(AppLocalizations.of(context)!.seasonManagementTitle)),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(AppLocalizations.of(context)!.noActiveSeasonMessage),
//             ElevatedButton(
//               onPressed: () {
//                 // Logic to create a new season and set it active
//                 // For now, we'll just show a placeholder
//                 print("Create New Season button pressed");
//               },
//               child: Text(AppLocalizations.of(context)!.createSeasonButton),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class DashboardScreen extends StatelessWidget {
//   final DatabaseHelper dbHelper;
//   final Season activeSeason;
//   final Function(Season?) onSeasonChanged;
//
//   const DashboardScreen({
//     super.key,
//     required this.dbHelper,
//     required this.activeSeason,
//     required this.onSeasonChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // Implement UI later
//     return Scaffold(
//       appBar: AppBar(title: Text(AppLocalizations.of(context)!.dashboardTitle)),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('${AppLocalizations.of(context)!.activeSeasonLabel} ${activeSeason.name}'),
//             // More dashboard content will go here
//           ],
//         ),
//       ),
//     );
//   }
// }