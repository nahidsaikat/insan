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

// --- NEW: Data model for Dashboard Action Items ---
class DashboardActionItem {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor; // Optional: to customize icon color per item

  DashboardActionItem({
    required this.title,
    required this.icon,
    required this.onPressed,
    this.iconColor,
  });
}
// --- END NEW ---


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
    final localizations = AppLocalizations.of(context)!; // Use ! as it should not be null after AppLocalizations.delegate

    // --- Define Dashboard Action Items ---
    // Grouped by category for better organization
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
        title: localizations.recordSaleButton, // Assuming this is for generic sales
        icon: Icons.point_of_sale,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SaleScreen(
              dbHelper: widget.dbHelper,
              activeSeasonId: widget.activeSeason.seasonId!,
              // initialTabIndex: 1,
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
        title: localizations.seasonManagementTitle, // Ensure this key exists or add it
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
                localizations.overviewTitle, // NEW: "Overview"
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
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

              // --- Transactions Section ---
              Text(
                localizations.transactionsTitle, // NEW: "Transactions"
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildActionGrid(context, transactionActions),
              const SizedBox(height: 30),

              // --- Management Section ---
              Text(
                localizations.managementTitle, // NEW: "Management"
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildActionGrid(context, managementActions),
              const SizedBox(height: 30),

              // --- Reporting Section ---
              Text(
                localizations.reportingTitle, // NEW: "Reporting"
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildActionGrid(context, reportingActions),
              const SizedBox(height: 30),

              // Note: The original `SaleScreen` import seems to be for a separate screen.
              // If `PurchaseSaleScreen` handles both, SaleScreen might be redundant.
              // I've kept it in the imports but removed from actions if it duplicates logic.
              // If it's a dedicated "View Sales" screen, it should be in Reporting/Management.
              // I've commented out the original `SaleScreen` action button as `recordSaleButton` already directs to `PurchaseSaleScreen`.
              // _buildActionButton(
              //   context,
              //   localizations.saleScreenTitle, // If this is for viewing sales
              //   Icons.point_of_sale,
              //       () {
              //     Navigator.of(context).push(MaterialPageRoute(
              //       builder: (context) => SaleScreen(
              //         dbHelper: widget.dbHelper,
              //         activeSeasonId: widget.activeSeason.seasonId!,
              //         initialTabIndex: 1, // Assuming it has tabs, check SaleScreen for this
              //       ),
              //     )).then((_) => _loadDashboardData());
              //   },
              // ),
            ],
          ),
        ),
      ),
      // No bottomNavigationBar defined in your original code, so keeping it out for now.
    );
  }

  // Helper widget for statistics cards - largely unchanged, but ensures good padding/margin
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

  // --- NEW: Helper for GridView of Action Buttons ---
  Widget _buildActionGrid(BuildContext context, List<DashboardActionItem> actions) {
    return GridView.builder(
      shrinkWrap: true, // Important: allows GridView to take only necessary space inside SingleChildScrollView
      physics: const NeverScrollableScrollPhysics(), // Important: GridView itself should not scroll
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 columns
        crossAxisSpacing: 16.0, // Spacing between columns
        mainAxisSpacing: 16.0, // Spacing between rows
        childAspectRatio: 1.5, // Adjust aspect ratio for card shape (width/height)
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final item = actions[index];
        return _buildGridActionButton(context, item);
      },
    );
  }

  // --- NEW: Grid Button Widget ---
  Widget _buildGridActionButton(BuildContext context, DashboardActionItem item) {
    return Card(
      elevation: 4, // Slightly higher elevation for grid items
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
      clipBehavior: Clip.antiAlias, // Ensures content respects rounded corners
      child: InkWell(
        onTap: item.onPressed,
        borderRadius: BorderRadius.circular(12), // Match card border radius
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
                maxLines: 2, // Allow text to wrap
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}