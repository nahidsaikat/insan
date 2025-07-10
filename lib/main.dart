// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
  // >>>>> ADD THIS LINE <<<<<
  bool _isLoading = true; // Initialize to true, as we start by loading data

  @override
  void initState() {
    super.initState();
    _loadActiveSeason();
  }

  Future<void> _loadActiveSeason() async {
    setState(() {
      _isLoading = true; // Set loading to true when starting to load
    });
    final active = await _dbHelper.getActiveSeason();
    setState(() {
      _activeSeason = active;
      _isLoading = false; // Set loading to false after loading is complete
    });
  }

  void _setActiveSeason(Season? season) {
    setState(() {
      _activeSeason = season;
    });
    // The MyApp's build method will now automatically re-evaluate based on _activeSeason
    // If season is null, it will go to SeasonManagementScreen.
    // If season is not null, it will go to DashboardScreen.
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return MaterialApp(
      title: 'insan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: themeProvider.themeMode,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('bn', ''), // Bengali
      ],
      locale: settingsProvider.locale,

      home: _isLoading // Check the loading state first
          ? const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      )
          : _activeSeason == null // Then check if an active season exists
          ? SeasonManagementScreen(
        dbHelper: _dbHelper,
        onSeasonSelected: _setActiveSeason,
        // initialMessage: "Welcome! Please select or create a season.",
      )
          : DashboardScreen(
        dbHelper: _dbHelper,
        activeSeason: _activeSeason!,
        onSeasonChanged: _setActiveSeason,
      ),
    );
  }
}