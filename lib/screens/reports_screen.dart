import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../l10n/app_localizations.dart';
import '../models/season.dart';

class ReportsScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const ReportsScreen({super.key, required this.dbHelper});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<Season> _seasons = [];
  Map<int, Map<String, dynamic>> _seasonReports = {}; // Changed to dynamic for different types
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReportsData();
  }

  Future<void> _loadReportsData() async {
    setState(() {
      _isLoading = true;
    });

    final allSeasons = await widget.dbHelper.getSeasons();
    allSeasons.sort((a, b) => b.startDate.compareTo(a.startDate)); // Sort by most recent season first

    final Map<int, Map<String, dynamic>> tempReports = {}; // Changed to dynamic

    for (var season in allSeasons) {
      if (season.seasonId != null) {
        // Financial Metrics
        final totalRevenue = await widget.dbHelper.getSeasonTotalRevenue(season.seasonId!);
        final totalPurchaseCost = await widget.dbHelper.getSeasonTotalPurchaseCost(season.seasonId!);
        final totalSaleCarryingCost = await widget.dbHelper.getSeasonTotalSaleCarryingCost(season.seasonId!);
        final totalPurchaseCarryingCost = await widget.dbHelper.getSeasonTotalPurchaseCarryingCost(season.seasonId!);
        final totalExpenses = await widget.dbHelper.getSeasonTotalExpenses(season.seasonId!);
        final totalDistributedAmount = await widget.dbHelper.getSeasonTotalDistributedAmount(season.seasonId!);

        final totalCarryingCost = totalPurchaseCarryingCost + totalSaleCarryingCost;
        final netProfit = totalRevenue - (totalPurchaseCost + totalCarryingCost + totalExpenses);
        final undistributedProfit = netProfit - totalDistributedAmount;

        // Inventory Metrics (NEW)
        final totalSacksInStock = await widget.dbHelper.getTotalSacksByStatus(season.seasonId!, 'In Stock');
        final totalWeightInStock = await widget.dbHelper.getTotalPurchaseWeightByStatus(season.seasonId!, 'In Stock');
        final totalStockValue = await widget.dbHelper.getTotalStockValue(season.seasonId!);

        final totalSacksSold = await widget.dbHelper.getTotalSacksByStatus(season.seasonId!, 'Sold');
        final totalWeightSold = await widget.dbHelper.getTotalSaleWeightByStatus(season.seasonId!, 'Sold');

        final totalSacksDiscarded = await widget.dbHelper.getTotalSacksByStatus(season.seasonId!, 'Discarded'); // Assuming you might have 'Discarded' status

        tempReports[season.seasonId!] = {
          // Financial
          'totalRevenue': totalRevenue,
          'totalPurchaseCost': totalPurchaseCost,
          'totalCarryingCost': totalCarryingCost,
          'totalExpenses': totalExpenses,
          'netProfit': netProfit,
          'totalDistributedAmount': totalDistributedAmount,
          'undistributedProfit': undistributedProfit,
          // Inventory
          'totalSacksInStock': totalSacksInStock,
          'totalWeightInStock': totalWeightInStock,
          'totalStockValue': totalStockValue,
          'totalSacksSold': totalSacksSold,
          'totalWeightSold': totalWeightSold,
          'totalSacksDiscarded': totalSacksDiscarded,
        };
      }
    }

    setState(() {
      _seasons = allSeasons;
      _seasonReports = tempReports;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.reportsTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadReportsData,
        child: _seasons.isEmpty
            ? Center(child: Text(localizations.noSeasonsFoundForReports))
            : ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: _seasons.length,
          itemBuilder: (context, index) {
            final season = _seasons[index];
            final report = _seasonReports[season.seasonId!];

            if (report == null) {
              return const SizedBox.shrink();
            }

            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${localizations.season}: ${season.name}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${localizations.duration}: ${season.startDate.toIso8601String().split('T')[0]} - ${season.endDate?.toIso8601String().split('T')[0]}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                    ),
                    const Divider(),
                    Text(
                      localizations.financialSummary,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    _buildSummaryRow(localizations.totalRevenue, report['totalRevenue']!, Colors.green),
                    _buildSummaryRow(localizations.totalPurchaseCost, report['totalPurchaseCost']!, Colors.red),
                    _buildSummaryRow(localizations.totalCarryingCost, report['totalCarryingCost']!, Colors.red),
                    _buildSummaryRow(localizations.totalExpenses, report['totalExpenses']!, Colors.red),
                    const Divider(),
                    _buildSummaryRow(
                      localizations.netProfitLoss,
                      report['netProfit']!,
                      report['netProfit']! >= 0 ? Colors.green.shade800 : Colors.red.shade800,
                      isBold: true,
                    ),
                    _buildSummaryRow(
                      localizations.totalDistributedAmount,
                      report['totalDistributedAmount']!,
                      Colors.blue,
                    ),
                    _buildSummaryRow(
                      localizations.undistributedProfit,
                      report['undistributedProfit']!,
                      report['undistributedProfit']! >= 0 ? Colors.green.shade900 : Colors.deepOrange.shade800,
                      isBold: true,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      localizations.inventorySummary, // New localization
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    _buildInventoryRow(localizations.sacksInStock, report['totalSacksInStock']!, localizations.totalWeightInStock, report['totalWeightInStock']!),
                    _buildInventoryRow(localizations.sacksSold, report['totalSacksSold']!, localizations.totalWeightSold, report['totalWeightSold']!),
                    if (report['totalSacksDiscarded']! > 0) // Only show if there are discarded sacks
                      _buildInventoryRow(localizations.sacksDiscarded, report['totalSacksDiscarded']!, localizations.notApplicable, 0.0, isWeightApplicable: false),
                    _buildSummaryRow(localizations.totalStockValue, report['totalStockValue']!, Colors.blue, isBold: true),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
          Text(
            '৳ ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // New helper widget for inventory rows
  Widget _buildInventoryRow(String labelSacks, int numSacks, String labelWeight, double totalWeightKg, {bool isWeightApplicable = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$labelSacks: $numSacks',
            style: const TextStyle(fontSize: 16),
          ),
          if (isWeightApplicable)
            Text(
              '$labelWeight: ${totalWeightKg.toStringAsFixed(2)} Kg',
              style: const TextStyle(fontSize: 16),
            )
          else
            Text(
              labelWeight, // e.g., "N/A"
              style: const TextStyle(fontSize: 16),
            ),
        ],
      ),
    );
  }
}