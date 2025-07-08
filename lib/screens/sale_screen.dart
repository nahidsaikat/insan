// lib/screens/sale_screen.dart

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../l10n/app_localizations.dart';
import '../models/party.dart';
import '../models/sack.dart';

class SaleScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  // Removed sackToSell as single sale tab is being removed
  final int activeSeasonId;
  // Removed initialTabIndex as there will be only one tab (bulk sale)
  // final int initialTabIndex; // No longer needed

  const SaleScreen({
    super.key,
    required this.dbHelper,
    // this.sackToSell, // Removed
    required this.activeSeasonId,
    // this.initialTabIndex = 0, // Removed
  });

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> { // Removed with SingleTickerProviderStateMixin
  // TabController is no longer needed
  // late TabController _tabController;

  // --- Bulk Sale Variables (formerly for Bulk Sale Tab) ---
  final TextEditingController _bulkSaleDateController = TextEditingController();
  final TextEditingController _bulkSalePriceController = TextEditingController();
  final TextEditingController _bulkSaleCarryingCostController = TextEditingController();
  Party? _selectedCustomerForBulkSale;
  List<Party> _customers = []; // Customers for the dropdown
  List<Sack> _sacksInStock = []; // All sacks in stock for the active season
  Map<int, bool> _selectedSacks = {}; // Map sackId to its selection state
  Map<int, String> _locationNames = {}; // To display location in bulk sale list

  double _totalSelectedWeight = 0.0;
  double _totalCalculatedSaleAmount = 0.0;

  @override
  void initState() {
    super.initState();
    // TabController initialization removed
    // _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
    // _tabController.addListener(_handleTabSelection); // Listener removed

    _bulkSaleDateController.text = DateTime.now().toIso8601String().split('T')[0];

    // Directly load data needed for bulk sale
    _loadCustomersAndSacks();
  }

  @override
  void didUpdateWidget(covariant SaleScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeSeasonId != oldWidget.activeSeasonId) {
      _loadCustomersAndSacks(); // Reload if active season changes
    }
  }

  @override
  void dispose() {
    // TabController disposal removed
    // _tabController.removeListener(_handleTabSelection);
    // _tabController.dispose();

    // Only dispose controllers relevant to bulk sale
    _bulkSaleDateController.dispose();
    _bulkSalePriceController.dispose();
    _bulkSaleCarryingCostController.dispose();
    super.dispose();
  }

  // _handleTabSelection is no longer needed
  // void _handleTabSelection() { ... }

  Future<void> _loadCustomersAndSacks() async {
    final allParties = await widget.dbHelper.getParties();
    final customers = allParties.where((p) => p.type == 'Customer').toList();

    await _loadSacksInStock(); // Load sacks for bulk sale

    setState(() {
      _customers = customers;
      if (_customers.isNotEmpty) {
        // Only initialize for bulk sale customer
        _selectedCustomerForBulkSale ??= _customers.first;
      }
    });
  }

  Future<void> _loadSacksInStock() async {
    final sacks = await widget.dbHelper.getSacks(seasonId: widget.activeSeasonId);
    final inStockSacks = sacks.where((s) => s.status == 'In Stock').toList();
    inStockSacks.sort((a, b) => a.uniqueSackIdentifier.compareTo(b.uniqueSackIdentifier)); // Sort for better UX

    final locations = await widget.dbHelper.getInventoryLocations();
    final Map<int, String> locationMap = {
      for (var loc in locations) loc.locationId!: loc.name
    };

    setState(() {
      _sacksInStock = inStockSacks;
      _locationNames = locationMap;
      // Preserve selection for existing sacks if possible, otherwise initialize to false
      _selectedSacks = { for (var s in inStockSacks) s.sackId!: _selectedSacks[s.sackId!] ?? false };
      _calculateBulkSaleTotals(); // Recalculate totals if sacks change
    });
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  void _calculateBulkSaleTotals() {
    double totalWeight = 0.0;
    double totalAmount = 0.0;
    final salePricePerKg = double.tryParse(_bulkSalePriceController.text) ?? 0.0;

    for (var sack in _sacksInStock) {
      if (_selectedSacks[sack.sackId!] == true) {
        totalWeight += sack.purchaseWeightKg; // Assuming selling entire purchase weight
        totalAmount += sack.purchaseWeightKg * salePricePerKg;
      }
    }
    setState(() {
      _totalSelectedWeight = totalWeight;
      _totalCalculatedSaleAmount = totalAmount;
    });
  }

  // --- Bulk Sale Logic ---
  Future<void> _recordBulkSale() async {
    final localizations = AppLocalizations.of(context);

    final selectedSackIds = _selectedSacks.keys.where((id) => _selectedSacks[id] == true).toList();

    if (selectedSackIds.isEmpty ||
        _bulkSaleDateController.text.isEmpty ||
        _bulkSalePriceController.text.isEmpty ||
        _selectedCustomerForBulkSale == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.selectSacksAndFillFields)),
      );
      return;
    }

    final salePricePerKg = double.tryParse(_bulkSalePriceController.text);
    final saleCarryingCost = double.tryParse(_bulkSaleCarryingCostController.text) ?? 0.0; // This is total carrying cost for bulk

    if (salePricePerKg == null || salePricePerKg <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.validPriceRequired)),
      );
      return;
    }

    final saleDate = DateTime.parse(_bulkSaleDateController.text);
    final customerId = _selectedCustomerForBulkSale!.partyId!;

    try {
      // Prepare a list of sacks to update
      final List<Sack> sacksToUpdate = [];
      for (var sackId in selectedSackIds) {
        final sack = _sacksInStock.firstWhere((s) => s.sackId == sackId);
        sacksToUpdate.add(sack.copyWith(
          saleDate: saleDate,
          saleWeightKg: sack.purchaseWeightKg, // Selling entire sack
          salePricePerKg: salePricePerKg,
          // Distribute saleCarryingCost proportionally based on sack's weight
          saleCarryingCost: (_totalSelectedWeight > 0)
              ? (saleCarryingCost / _totalSelectedWeight) * sack.purchaseWeightKg
              : 0.0, // Avoid division by zero
          saleCustomerId: customerId,
          status: 'Sold',
        ));
      }

      await widget.dbHelper.bulkUpdateSacks(sacksToUpdate); // New DB method

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.bulkSaleRecordedSuccessfully)),
        );
        _clearBulkSaleForm();
        _loadSacksInStock(); // Refresh the list of in-stock sacks
        Navigator.of(context).pop(true); // Pop with true to indicate success and refresh previous screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${localizations.errorRecordingBulkSale} $e')),
        );
      }
    }
  }

  void _clearBulkSaleForm() {
    _bulkSaleDateController.text = DateTime.now().toIso8601String().split('T')[0];
    _bulkSalePriceController.clear();
    _bulkSaleCarryingCostController.clear();
    setState(() {
      _selectedCustomerForBulkSale = _customers.isNotEmpty ? _customers.first : null;
      _selectedSacks.clear(); // Clear all selections
      _totalSelectedWeight = 0.0;
      _totalCalculatedSaleAmount = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.bulkSaleTab), // Title now directly reflects "Bulk Sale"
        // No bottom TabBar needed
      ),
      body: Column( // This is directly the content of the former Bulk Sale tab
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _bulkSaleDateController,
                  decoration: InputDecoration(
                    labelText: localizations.saleDateLabel,
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(_bulkSaleDateController),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<Party>(
                  value: _selectedCustomerForBulkSale,
                  hint: Text(localizations.selectCustomer),
                  decoration: InputDecoration(labelText: localizations.customerLabel),
                  items: _customers.map((party) {
                    return DropdownMenuItem(
                      value: party,
                      child: Text(party.name),
                    );
                  }).toList(),
                  onChanged: (Party? newValue) {
                    setState(() {
                      _selectedCustomerForBulkSale = newValue;
                    });
                  },
                  // Removed validator as it's not present in original bulk sale
                  // validator: (value) => value == null ? localizations.customerRequired : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _bulkSalePriceController,
                  decoration: InputDecoration(
                    labelText: localizations.salePricePerKgLabel,
                    prefixText: '৳ ',
                    suffixText: '/Kg (for selected sacks)',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _calculateBulkSaleTotals(), // Recalculate on price change
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _bulkSaleCarryingCostController,
                  decoration: InputDecoration(
                    labelText: localizations.totalCarryingCostLabel, // New label
                    prefixText: '৳ ',
                    hintText: localizations.totalCarryingCostHint, // New hint
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                _buildInfoRow(localizations.totalSelectedWeight, '${_totalSelectedWeight.toStringAsFixed(2)} Kg'),
                _buildInfoRow(localizations.calculatedSaleAmount, '৳ ${_totalCalculatedSaleAmount.toStringAsFixed(2)}'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _recordBulkSale,
                  child: Text(localizations.recordBulkSale),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // List of Sacks to select for bulk sale
          Expanded(
            child: _sacksInStock.isEmpty
                ? Center(child: Text(localizations.noSacksInStock))
                : ListView.builder(
              itemCount: _sacksInStock.length,
              itemBuilder: (context, index) {
                final sack = _sacksInStock[index];
                final isSelected = _selectedSacks[sack.sackId!] ?? false;
                final locationName = _locationNames[sack.currentLocationId] ?? localizations.unknownLocation;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  elevation: 1,
                  child: CheckboxListTile(
                    title: Text('${sack.uniqueSackIdentifier} (${sack.productType})'),
                    subtitle: Text(
                        '${localizations.weightLabel}: ${sack.purchaseWeightKg} Kg, '
                            '${localizations.locationLabel}: $locationName'
                    ),
                    value: isSelected,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _selectedSacks[sack.sackId!] = newValue!;
                        _calculateBulkSaleTotals(); // Recalculate when selection changes
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}