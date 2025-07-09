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
import '../screens/sale_screen.dart'; // Note: SaleScreen might be redundant if PurchaseSaleScreen handles sales
import '../screens/settings_screen.dart';

// --- Data model for Dashboard Action Items (unchanged) ---
class DashboardActionItem {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;

  DashboardActionItem({
    required this.title,
    required this.icon,
    required this.onPressed,
    this.iconColor,
  });
}
// --- END Data model ---


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
  // --- NEW: New state variables for quantities ---
  double _totalKgPurchased = 0.0;
  double _totalKgSold = 0.0;
  // --- END NEW ---

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

    // --- NEW: Calculate total quantities in Kg ---
    _totalKgPurchased = purchasedSacks.fold(0.0, (sum, sack) => sum + sack.purchaseWeightKg);
    _totalKgSold = soldSacks.fold(0.0, (sum, sack) => sum + (sack.saleWeightKg ?? 0.0)); // Use ?? 0.0 for saleWeightKg
    // --- END NEW ---

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
    final localizations = AppLocalizations.of(context);

    // --- Define Dashboard Action Items (unchanged) ---
    final List<DashboardActionItem> transactionActions = [
      DashboardActionItem(
        title: localizations.recordPurchaseButton,
        icon: Icons.add_shopping_cart,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PurchaseSaleScreen(
              dbHelper: widget.dbHelper,
              activeSeason: widget.activeSeason,
              initialTabIndex: 0, // Go to Purchase tab
            ),
          )).then((_) => _loadDashboardData()); // Reload on return
        },
      ),
      DashboardActionItem(
        title: localizations.recordSaleButton,
        icon: Icons.point_of_sale,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SaleScreen(
              dbHelper: widget.dbHelper,
              activeSeasonId: widget.activeSeason.seasonId!,
            ),
          )).then((_) => _loadDashboardData()); // Reload on return
        },
      ),
      DashboardActionItem(
        title: localizations.addExpenseButton,
        icon: Icons.receipt_long,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ExpenseInvestmentScreen(
              dbHelper: widget.dbHelper,
              activeSeason: widget.activeSeason,
              initialTabIndex: 0, // Go to Expense tab
            ),
          )).then((_) => _loadDashboardData()); // Reload on return
        },
      ),
      DashboardActionItem(
        title: localizations.addInvestmentButton,
        icon: Icons.account_balance_wallet,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ExpenseInvestmentScreen(
              dbHelper: widget.dbHelper,
              activeSeason: widget.activeSeason,
              initialTabIndex: 1, // Go to Investment tab
            ),
          )).then((_) => _loadDashboardData()); // Reload on return
        },
      ),
    ];

    final List<DashboardActionItem> managementActions = [
      DashboardActionItem(
        title: localizations.partyManagementTitle,
        icon: Icons.group,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PartyManagementScreen(dbHelper: widget.dbHelper),
          ));
        },
      ),
      DashboardActionItem(
        title: localizations.viewAllInventory,
        icon: Icons.inventory_2,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => InventoryScreen(
              dbHelper: widget.dbHelper,
              activeSeasonId: widget.activeSeason.seasonId!,
            ),
          )).then((_) => _loadDashboardData());
        },
      ),
      DashboardActionItem(
        title: localizations.inventoryLocationsTitle,
        icon: Icons.location_on,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => InventoryLocationsScreen(dbHelper: widget.dbHelper),
          ));
        },
      ),
      DashboardActionItem(
        title: localizations.seasonManagementTitle,
        icon: Icons.calendar_today,
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SeasonManagementScreen(
                dbHelper: widget.dbHelper,
                onSeasonSelected: widget.onSeasonChanged,
              ),
            ),
          );
          _loadDashboardData();
        },
      ),
    ];

    final List<DashboardActionItem> reportingActions = [
      DashboardActionItem(
        title: localizations.profitDistributionTitle,
        icon: Icons.pie_chart,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ProfitDistributionScreen(
              dbHelper: widget.dbHelper,
              activeSeason: widget.activeSeason,
            ),
          )).then((_) => _loadDashboardData());
        },
      ),
      DashboardActionItem(
        title: localizations.reportsTitle,
        icon: Icons.bar_chart,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ReportsScreen(dbHelper: widget.dbHelper),
          ));
        },
      ),
    ];
    // --- END Define Dashboard Action Items ---


    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.dashboardTitle),
        actions: [
          // Active Season Selector in AppBar
          TextButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SeasonManagementScreen(
                    dbHelper: widget.dbHelper,
                    onSeasonSelected: widget.onSeasonChanged,
                  ),
                ),
              );
              _loadDashboardData(); // Reload data after potential season change
            },
            child: Text(
              '${localizations.activeSeasonLabel}: ${widget.activeSeason.name}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: localizations.settingsTitle,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Overview Statistics Section ---
              Text(
                localizations.overviewTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // --- NEW: 2x2 Grid for Sack Counts and Quantities ---
              GridView.count(
                shrinkWrap: true, // Important for nesting in SingleChildScrollView
                physics: const NeverScrollableScrollPhysics(), // GridView itself should not scroll
                crossAxisCount: 2, // Two cards per row
                crossAxisSpacing: 16.0, // Spacing between columns
                mainAxisSpacing: 16.0, // Spacing between rows
                childAspectRatio: 1.2, // Adjust this ratio for desired card height/width
                children: [
                  _buildCompactStatCard(
                    context,
                    localizations.totalSacksPurchased,
                    _totalSacksPurchased.toString(),
                    localizations.sacksLabel, // e.g., "Sacks"
                    Icons.shopping_cart,
                    Colors.blue,
                  ),
                  _buildCompactStatCard(
                    context,
                    localizations.totalSacksSold,
                    _totalSacksSold.toString(),
                    localizations.sacksLabel, // e.g., "Sacks"
                    Icons.sell,
                    Colors.green,
                  ),
                  _buildCompactStatCard(
                    context,
                    localizations.totalKgPurchased, // New localization key
                    _totalKgPurchased.toStringAsFixed(2),
                    localizations.kgLabel, // e.g., "Kg"
                    Icons.scale, // Icon for weight/quantity
                    Colors.deepOrange,
                  ),
                  _buildCompactStatCard(
                    context,
                    localizations.totalKgSold, // New localization key
                    _totalKgSold.toStringAsFixed(2),
                    localizations.kgLabel, // e.g., "Kg"
                    Icons.balance, // Another icon for weight/quantity
                    Colors.teal,
                  ),
                ],
              ),
              const SizedBox(height: 20), // Spacing between the grid and full-width cards

              // --- Original Full-width cards for financial summaries ---
              _buildStatCard( // Reusing original _buildStatCard for these
                context,
                localizations.currentInStockValue,
                '৳ ${_currentInStockValue.toStringAsFixed(2)}', // Using BDT currency symbol
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

              // --- Transactions Section (unchanged) ---
              Text(
                localizations.transactionsTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildActionGrid(context, transactionActions),
              const SizedBox(height: 30),

              // --- Management Section (unchanged) ---
              Text(
                localizations.managementTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildActionGrid(context, managementActions),
              const SizedBox(height: 30),

              // --- Reporting Section (unchanged) ---
              Text(
                localizations.reportingTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildActionGrid(context, reportingActions),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- Original _buildStatCard (now used for financial summaries) ---
  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0), // Margin between these cards
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

  // --- NEW: Compact Stat Card for Grid (e.g., Sacks/Kg counts) ---
  Widget _buildCompactStatCard(BuildContext context, String title, String value, String unit, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.all(0), // GridView handles spacing
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically within the card
          crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start
          children: [
            Icon(icon, size: 28, color: color), // Slightly smaller icon for compact display
            const SizedBox(height: 6),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w600), // Smaller title text
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '$value $unit', // Value with its unit
              style: Theme.of(context).textTheme.titleMedium!.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper for GridView of Action Buttons (unchanged) ---
  Widget _buildActionGrid(BuildContext context, List<DashboardActionItem> actions) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 1.5,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final item = actions[index];
        return _buildGridActionButton(context, item);
      },
    );
  }

  // --- Grid Button Widget (unchanged) ---
  Widget _buildGridActionButton(BuildContext context, DashboardActionItem item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: item.onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item.icon, size: 36, color: item.iconColor ?? Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                item.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}