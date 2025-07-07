import 'package:flutter/material.dart';
import 'package:insan/screens/sack_detail_screen.dart';
import '../database/database_helper.dart';
import '../models/season.dart';
import '../models/sack.dart';
import '../models/inventory_location.dart';
import '../models/party.dart';
import '../l10n/app_localizations.dart';

// Import other screens for navigation
import '../screens/purchase_sale_screen.dart';

// Required for FAB navigation


class InventoryScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final Season activeSeason;

  const InventoryScreen({
    super.key,
    required this.dbHelper,
    required this.activeSeason,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Sack> _sacks = [];
  Map<int, InventoryLocation> _locationsMap = {}; // Cache locations by ID
  Map<int, Party> _partiesMap = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Reload data if the active season changes
  @override
  void didUpdateWidget(covariant InventoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeSeason.seasonId != oldWidget.activeSeason.seasonId) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    // Load all sacks for the active season
    final sacks = await widget.dbHelper.getSacks(seasonId: widget.activeSeason.seasonId);

    // Pre-load all locations and parties to build maps for quick lookup
    final allLocations = await widget.dbHelper.getInventoryLocations();
    _locationsMap = {for (var loc in allLocations) loc.locationId!: loc};

    final allParties = await widget.dbHelper.getParties();
    _partiesMap = {for (var party in allParties) party.partyId!: party};

    setState(() {
      _sacks = sacks;
    });
  }

  // Helper to get location name
  String? _getLocationName(int? locationId) {
    if (locationId == null) return null;
    return _locationsMap[locationId]?.name;
  }

  // Helper to get party name (vendor)
  String? _getVendorName(int? vendorId) {
    if (vendorId == null) return null;
    return _partiesMap[vendorId]?.name;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.inventoryTitle),
        // Future: Add filter/sort buttons here
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _sacks.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                localizations.noSacksFound,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              // Optionally, add a button to record a purchase
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to Purchase screen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PurchaseSaleScreen(
                        dbHelper: widget.dbHelper,
                        activeSeason: widget.activeSeason,
                        initialTabIndex: 0, // Go directly to the Purchase tab
                      ),
                    ),
                  ).then((_) => _loadData()); // Reload data when returning
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: Text(localizations.recordPurchaseButton),
              ),
            ],
          ),
        )
            : ListView.builder(
          itemCount: _sacks.length,
          itemBuilder: (context, index) {
            final sack = _sacks[index];
            final locationName = _getLocationName(sack.currentLocationId);
            final vendorName = _getVendorName(sack.purchaseVendorId);
            final isSold = sack.status == 'Sold';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              elevation: 2,
              color: isSold ? Colors.grey.shade200 : null, // Use null for default background instead of Colors.white
              child: ListTile(
                title: Text('${sack.productType} - ${sack.uniqueSackIdentifier}'),
                subtitle: Text(
                  '${localizations.statusLabel}: ${sack.status}\n'
                      '${localizations.weightLabel}: ${sack.purchaseWeightKg} Kg\n'
                      '${localizations.currentLocation}: $locationName',
                ),
                trailing: Text(
                  '৳ ${sack.purchasePricePerKg.toStringAsFixed(2)}/Kg',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SackDetailScreen(
                      dbHelper: widget.dbHelper,
                      sackId: sack.sackId!,
                      onDataUpdated: _loadData,
                    ),
                  ));
                },
              ),
            );
          },
        ),
      ), // This closing parenthesis was missing for the RefreshIndicator's child
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to Purchase screen to add new sack
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PurchaseSaleScreen(
                dbHelper: widget.dbHelper,
                activeSeason: widget.activeSeason,
                initialTabIndex: 0, // Go directly to the Purchase tab
              ),
            ),
          ).then((_) => _loadData()); // Reload data when returning
        },
        label: Text(localizations.addNewSack), // "Add New Sack"
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}