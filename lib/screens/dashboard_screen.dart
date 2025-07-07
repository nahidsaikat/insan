import 'package:flutter/material.dart';
import '../screens/profit_distribution_screen.dart';
import '../database/database_helper.dart';
import '../models/season.dart';
import '../l10n/app_localizations.dart';

// Import other screens for navigation
import '../screens/season_management_screen.dart';
import '../screens/inventory_screen.dart';
import '../screens/purchase_sale_screen.dart';
import '../screens/expense_investment_screen.dart';
import '../screens/party_management_screen.dart';
import '../screens/inventory_locations_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/sale_screen.dart';

import '../screens/settings_screen.dart';


class DashboardScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final Season activeSeason;
  final Function(Season?) onSeasonChanged; // Callback to notify parent of season change

  const DashboardScreen({
    super.key,
    required this.dbHelper,
    required this.activeSeason,
    required this.onSeasonChanged,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // State variables to hold dashboard data
  int _totalSacksPurchased = 0;
  int _totalSacksSold = 0;
  double _currentInStockValue = 0.0;
  double _totalExpenses = 0.0;
  double _totalInvestments = 0.0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // Reload data if the active season changes
  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeSeason.seasonId != oldWidget.activeSeason.seasonId) {
      _loadDashboardData();
    }
  }

  Future<void> _loadDashboardData() async {
    // Fetch all sacks for the active season
    final allSacks = await widget.dbHelper.getSacks(seasonId: widget.activeSeason.seasonId);

    // Filter sacks by status
    final purchasedSacks = allSacks; // All sacks recorded are considered purchased
    final soldSacks = allSacks.where((sack) => sack.status == 'Sold').toList();
    final inStockSacks = allSacks.where((sack) => sack.status == 'In Stock').toList();

    // Calculate totals
    _totalSacksPurchased = purchasedSacks.length;
    _totalSacksSold = soldSacks.length;

    _currentInStockValue = inStockSacks.fold(0.0, (sum, sack) {
      // Calculate value based on purchase price (or estimated current market value if available)
      // For simplicity, let's use purchase price for now.
      return sum + (sack.purchaseWeightKg * sack.purchasePricePerKg);
    });

    // Fetch expenses and investments for the active season
    final expenses = await widget.dbHelper.getExpenses(seasonId: widget.activeSeason.seasonId);
    final investments = await widget.dbHelper.getInvestments(seasonId: widget.activeSeason.seasonId);

    _totalExpenses = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    _totalInvestments = investments.fold(0.0, (sum, investment) => sum + investment.amount);

    setState(() {
      // Update UI with calculated values
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context); // Access localized strings

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.dashboardTitle),
        actions: [
          TextButton(
            onPressed: () async {
              // Navigate to Season Management and wait for a result (if active season changes)
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SeasonManagementScreen(
                    dbHelper: widget.dbHelper,
                    onSeasonSelected: widget.onSeasonChanged, // Pass the callback
                  ),
                ),
              );
              // After returning from SeasonManagementScreen, reload dashboard data
              // This ensures if active season was changed, dashboard reflects it.
              _loadDashboardData(); // Reload data based on potentially new active season
            },
            child: Text(
              '${localizations.activeSeasonLabel} ${widget.activeSeason.name}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: localizations.settingsTitle, // Localized tooltip
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator( // Allow pull-to-refresh for data
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const AlwaysScrollableScrollPhysics(), // Always allow scrolling even if content fits
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active Season Display
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    '${localizations.activeSeasonLabel} ${widget.activeSeason.name}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              // Overview Statistics Cards
              _buildStatCard(
                context,
                localizations.totalSacksPurchased,
                _totalSacksPurchased.toString(),
                Icons.shopping_cart,
                Colors.blue,
              ),
              _buildStatCard(
                context,
                localizations.totalSacksSold,
                _totalSacksSold.toString(),
                Icons.sell,
                Colors.green,
              ),
              _buildStatCard(
                context,
                localizations.currentInStockValue,
                '৳ ${_currentInStockValue.toStringAsFixed(2)}', // Assuming BDT currency
                Icons.warehouse,
                Colors.orange,
              ),
              _buildStatCard(
                context,
                localizations.totalExpenses,
                '৳ ${_totalExpenses.toStringAsFixed(2)}',
                Icons.money_off,
                Colors.red,
              ),
              _buildStatCard(
                context,
                localizations.totalInvestments,
                '৳ ${_totalInvestments.toStringAsFixed(2)}',
                Icons.attach_money,
                Colors.purple,
              ),

              const SizedBox(height: 30),

              // Quick Actions Section
              Text(
                '${localizations.transactionsTitle} ${localizations.reportsTitle}', // Placeholder for header
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              _buildActionButton(
                context,
                localizations.recordPurchaseButton,
                Icons.add_shopping_cart,
                    () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PurchaseSaleScreen(
                      dbHelper: widget.dbHelper,
                      activeSeason: widget.activeSeason,
                      initialTabIndex: 0, // Go to Purchase tab
                    ),
                  )).then((_) => _loadDashboardData()); // Reload on return
                },
              ),
              _buildActionButton(
                context,
                localizations.recordSaleButton,
                Icons.point_of_sale,
                    () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PurchaseSaleScreen(
                      dbHelper: widget.dbHelper,
                      activeSeason: widget.activeSeason,
                      initialTabIndex: 1, // Go to Sale tab
                    ),
                  )).then((_) => _loadDashboardData()); // Reload on return
                },
              ),
              _buildActionButton(
                context,
                localizations.addExpenseButton,
                Icons.receipt_long,
                    () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ExpenseInvestmentScreen(
                      dbHelper: widget.dbHelper,
                      activeSeason: widget.activeSeason,
                      initialTabIndex: 0, // Go to Expense tab
                    ),
                  )).then((_) => _loadDashboardData()); // Reload on return
                },
              ),
              _buildActionButton(
                context,
                localizations.addInvestmentButton,
                Icons.account_balance_wallet,
                    () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ExpenseInvestmentScreen(
                      dbHelper: widget.dbHelper,
                      activeSeason: widget.activeSeason,
                      initialTabIndex: 1, // Go to Investment tab
                    ),
                  )).then((_) => _loadDashboardData()); // Reload on return
                },
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                context,
                localizations.viewAllInventory,
                Icons.inventory_2,
                    () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => InventoryScreen(
                      dbHelper: widget.dbHelper,
                      activeSeasonId: widget.activeSeason.seasonId!,
                    ),
                  )).then((_) => _loadDashboardData()); // Reload on return
                },
              ),
              _buildActionButton(
                context,
                localizations.partyManagementTitle, // Make sure you have this key in your .arb files
                Icons.group, // Or Icons.people
                    () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PartyManagementScreen(dbHelper: widget.dbHelper),
                  )).then((_) {
                    // No need to reload dashboard data on return from PartyManagement
                    // unless party changes affect dashboard stats directly (not likely in this version)
                  });
                },
              ),
              // In _DashboardScreenState build method, add this action button:
              _buildActionButton(
                context,
                localizations.inventoryLocationsTitle,
                Icons.location_on,
                    () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => InventoryLocationsScreen(dbHelper: widget.dbHelper),
                  ));
                },
              ),
              // In _DashboardScreenState build method
              _buildActionButton(
                context,
                localizations.profitDistributionTitle, // Add this key
                Icons.pie_chart, // Or Icons.payments, Icons.currency_exchange
                    () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProfitDistributionScreen(
                      dbHelper: widget.dbHelper,
                      activeSeason: widget.activeSeason, // Pass the active season
                    ),
                  )).then((_) => _loadDashboardData()); // Reload dashboard data when returning
                },
              ),
              _buildActionButton(
                context,
                localizations.saleScreenTitle,
                Icons.point_of_sale,
                    () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SaleScreen(
                      dbHelper: widget.dbHelper,
                      activeSeasonId: widget.activeSeason.seasonId!,
                      initialTabIndex: 1,
                    ),
                  )).then((_) => _loadDashboardData());
                },
              ),
              _buildActionButton(
                context,
                localizations.reportsTitle, // New localization key
                Icons.bar_chart, // Icon for reports/analytics
                    () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ReportsScreen(
                      dbHelper: widget.dbHelper,
                    ),
                  ));
                },
              ),
              // You can add more buttons for Reports, Party Management etc.
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String title, IconData icon, VoidCallback onPressed) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 2,
      child: InkWell( // Use InkWell for splash effect on tap
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(icon, size: 30, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
