// lib/screens/inventory_screen.dart

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/sack.dart';
import '../models/inventory_location.dart'; // Make sure this is imported
import '../l10n/app_localizations.dart';
import '../screens/sack_detail_screen.dart'; // For navigating to sack details

class InventoryScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final int activeSeasonId;

  const InventoryScreen({
    super.key,
    required this.dbHelper,
    required this.activeSeasonId,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Sack> _sacks = [];
  bool _isLoading = true;

  // Filter state variables
  String? _selectedProductType;
  String? _selectedStatus;
  int? _selectedLocationId;
  final TextEditingController _searchController = TextEditingController();
  List<InventoryLocation> _locations = []; // To store available locations
  List<String> _productTypes = []; // To store available product types
  List<String> _statuses = ['In Stock', 'Sold', 'Discarded']; // Default statuses

  // Add keys for dropdowns to reset them easily
  Key _productTypeDropdownKey = UniqueKey();
  Key _statusDropdownKey = UniqueKey();
  Key _locationDropdownKey = UniqueKey();


  @override
  void initState() {
    super.initState();
    _loadFiltersAndSacks(); // Load filter options and then sacks
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // New method to load filter options (product types, locations)
  Future<void> _loadFiltersAndSacks() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _locations = await widget.dbHelper.getInventoryLocations();
      _productTypes = await widget.dbHelper.getDistinctProductTypes(widget.activeSeasonId);

      // Add an "All" option to the beginning of the lists
      _productTypes.insert(0, AppLocalizations.of(context).allProducts); // Need to add to localization
      _statuses.insert(0, AppLocalizations.of(context).allStatuses);     // Need to add to localization
      _locations.insert(0, InventoryLocation(locationId: null, name: AppLocalizations.of(context).allLocations)); // Need to add to localization, use null for ID

      // Set initial selected values to "All" (or null which we map to "All")
      _selectedProductType = AppLocalizations.of(context).allProducts;
      _selectedStatus = AppLocalizations.of(context).allStatuses;
      _selectedLocationId = null; // Represents "All Locations"

    } catch (e) {
      // Handle error loading filters
      print('Error loading filter options: $e');
    } finally {
      await _loadSacks(); // Load sacks after filter options are ready
    }
  }


  Future<void> _loadSacks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final AppLocalizations localizations = AppLocalizations.of(context);

      // Map "All" options back to null for database query
      final String? queryProductType = (_selectedProductType == localizations.allProducts) ? null : _selectedProductType;
      final String? queryStatus = (_selectedStatus == localizations.allStatuses) ? null : _selectedStatus;
      final int? queryLocationId = _selectedLocationId; // null already means all locations

      _sacks = await widget.dbHelper.getSacksForSeason(
        widget.activeSeasonId,
        productType: queryProductType,
        status: queryStatus,
        locationId: queryLocationId,
        searchText: _searchController.text.trim().isNotEmpty ? _searchController.text.trim() : null,
      );
    } catch (e) {
      // Handle error
      print('Error loading sacks: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetFilters() {
    final localizations = AppLocalizations.of(context);
    setState(() {
      _searchController.clear();
      _selectedProductType = localizations.allProducts;
      _selectedStatus = localizations.allStatuses;
      _selectedLocationId = null; // "All Locations"
      // Re-key dropdowns to force them to rebuild and show "All"
      _productTypeDropdownKey = UniqueKey();
      _statusDropdownKey = UniqueKey();
      _locationDropdownKey = UniqueKey();
    });
    _loadSacks(); // Reload sacks with no filters
  }


  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.inventoryTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(160.0), // Adjust height for filters
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: localizations.searchSacks,
                    hintText: localizations.searchSacksHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _loadSacks(); // Reload after clearing
                      },
                    )
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    // Implement a debounce if search is too frequent, or just call _loadSacks immediately
                    // For simplicity, we'll call it immediately. Consider debounce for large datasets.
                    _loadSacks();
                  },
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        key: _productTypeDropdownKey, // Use key for reset
                        value: _selectedProductType,
                        decoration: InputDecoration(
                          labelText: localizations.productType,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _productTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedProductType = value;
                          });
                          _loadSacks();
                        },
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        key: _statusDropdownKey, // Use key for reset
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: localizations.status,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _statuses.map((status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                          _loadSacks();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>( // Use int? for location ID
                        key: _locationDropdownKey, // Use key for reset
                        value: _selectedLocationId,
                        decoration: InputDecoration(
                          labelText: localizations.location,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _locations.map((location) {
                          return DropdownMenuItem<int?>(
                            value: location.locationId, // Use null for "All Locations"
                            child: Text(location.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLocationId = value;
                          });
                          _loadSacks();
                        },
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    ElevatedButton.icon(
                      onPressed: _resetFilters,
                      icon: const Icon(Icons.refresh),
                      label: Text(localizations.resetFilters), // Need to add to localization
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sacks.isEmpty
          ? Center(child: Text(localizations.noSacksFound)) // Need to add to localization
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _sacks.length,
        itemBuilder: (context, index) {
          final sack = _sacks[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 3,
            child: ListTile(
              title: Text('${localizations.productType}: ${sack.productType} - ${localizations.code}: ${sack.uniqueSackIdentifier}'),
              subtitle: Text(
                '${localizations.status}: ${sack.status}\n'
                    '${localizations.weight}: ${sack.purchaseWeightKg} Kg\n'
                    '${localizations.date}: ${sack.purchaseDate.toLocal().toString().split(' ')[0]}',
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              isThreeLine: true,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SackDetailScreen(
                      dbHelper: widget.dbHelper,
                      sackId: sack.sackId!,
                      onDataUpdated: _loadSacks,
                    ),
                  ),
                ).then((_) => _loadSacks()); // Reload when returning from detail screen
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to a screen to add a new sack (e.g., PurchaseScreen)
          // For now, let's assume adding a sack happens via PurchaseScreen
          // or create a dedicated AddSackScreen if needed.
          // Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddSackScreen()));
          // For this example, we'll just reload.
          _loadSacks();
        },
        child: const Icon(Icons.refresh), // Or Icons.add if you create an AddSackScreen
      ),
    );
  }
}