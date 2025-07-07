// lib/screens/sale_screen.dart

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../l10n/app_localizations.dart';
import '../models/party.dart';
import '../models/sack.dart';

class SaleScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final Sack? sackToSell; // For single sack sale, if navigating from inventory
  final int activeSeasonId;
  final int initialTabIndex;

  const SaleScreen({
    super.key,
    required this.dbHelper,
    this.sackToSell,
    required this.activeSeasonId,
    this.initialTabIndex = 0,
  });

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- Single Sack Sale Variables ---
  final TextEditingController _singleSaleDateController = TextEditingController();
  final TextEditingController _singleSaleWeightController = TextEditingController();
  final TextEditingController _singleSalePriceController = TextEditingController();
  final TextEditingController _singleSaleCarryingCostController = TextEditingController();
  Party? _selectedCustomerForSingleSale;
  List<Party> _customers = [];
  Sack? _currentSack; // The sack being sold in single sale mode

  // --- Bulk Sale Variables ---
  final TextEditingController _bulkSaleDateController = TextEditingController();
  final TextEditingController _bulkSalePriceController = TextEditingController();
  final TextEditingController _bulkSaleCarryingCostController = TextEditingController();
  Party? _selectedCustomerForBulkSale;
  List<Sack> _sacksInStock = []; // All sacks in stock for the active season
  Map<int, bool> _selectedSacks = {}; // Map sackId to its selection state
  Map<int, String> _locationNames = {}; // To display location in bulk sale list

  double _totalSelectedWeight = 0.0;
  double _totalCalculatedSaleAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
    _tabController.addListener(_handleTabSelection);

    _singleSaleDateController.text = DateTime.now().toIso8601String().split('T')[0];
    _bulkSaleDateController.text = DateTime.now().toIso8601String().split('T')[0];

    if (widget.sackToSell != null) {
      _currentSack = widget.sackToSell;
      _singleSaleWeightController.text = widget.sackToSell!.purchaseWeightKg.toString();
      _singleSaleDateController.text = DateTime.now().toIso8601String().split('T')[0];
    }

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
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _singleSaleDateController.dispose();
    _singleSaleWeightController.dispose();
    _singleSalePriceController.dispose();
    _singleSaleCarryingCostController.dispose();
    _bulkSaleDateController.dispose();
    _bulkSalePriceController.dispose();
    _bulkSaleCarryingCostController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      // Clear forms on tab switch if needed
      if (_tabController.index == 0) { // Switching to Single Sale
        _clearSingleSaleForm();
        if (widget.sackToSell != null) {
          _currentSack = widget.sackToSell;
          _singleSaleWeightController.text = widget.sackToSell!.purchaseWeightKg.toString();
        }
      } else { // Switching to Bulk Sale
        _clearBulkSaleForm();
        _loadSacksInStock(); // Ensure sacks are loaded for bulk sale
      }
    }
  }

  Future<void> _loadCustomersAndSacks() async {
    final allParties = await widget.dbHelper.getParties();
    final customers = allParties.where((p) => p.type == 'Customer').toList();

    await _loadSacksInStock(); // Load sacks for bulk sale

    setState(() {
      _customers = customers;
      if (_customers.isNotEmpty) {
        _selectedCustomerForSingleSale ??= _customers.first;
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
      _selectedSacks = { for (var s in inStockSacks) s.sackId!: _selectedSacks[s.sackId!] ?? false }; // Preserve selection if possible
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

  // --- Single Sale Logic ---
  Future<void> _recordSingleSale() async {
    final localizations = AppLocalizations.of(context);
    if (_currentSack == null ||
        _singleSaleDateController.text.isEmpty ||
        _singleSaleWeightController.text.isEmpty ||
        _singleSalePriceController.text.isEmpty ||
        _selectedCustomerForSingleSale == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.fillAllFields)),
      );
      return;
    }

    final saleWeight = double.tryParse(_singleSaleWeightController.text);
    final salePricePerKg = double.tryParse(_singleSalePriceController.text);
    final saleCarryingCost = double.tryParse(_singleSaleCarryingCostController.text) ?? 0.0;

    if (saleWeight == null || saleWeight <= 0 || salePricePerKg == null || salePricePerKg <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.validAmountRequired)),
      );
      return;
    }

    if (saleWeight > _currentSack!.purchaseWeightKg) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.saleWeightExceedsPurchase)),
      );
      return;
    }

    final updatedSack = _currentSack!.copyWith(
      saleDate: DateTime.parse(_singleSaleDateController.text),
      saleWeightKg: saleWeight,
      salePricePerKg: salePricePerKg,
      saleCarryingCost: saleCarryingCost,
      saleCustomerId: _selectedCustomerForSingleSale!.partyId,
      status: 'Sold', // Mark as sold
    );

    try {
      await widget.dbHelper.updateSack(updatedSack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.saleRecordedSuccessfully)),
        );
        Navigator.of(context).pop(true); // Pop with true to indicate success and refresh previous screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${localizations.errorRecordingSale} $e')),
        );
      }
    }
  }

  void _clearSingleSaleForm() {
    _singleSaleDateController.text = DateTime.now().toIso8601String().split('T')[0];
    _singleSaleWeightController.clear();
    _singleSalePriceController.clear();
    _singleSaleCarryingCostController.clear();
    setState(() {
      _selectedCustomerForSingleSale = _customers.isNotEmpty ? _customers.first : null;
      _currentSack = null; // Clear current sack in single sale
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
          // How to distribute saleCarryingCost? For simplicity, we can assign it to the first sack,
          // or leave it null here and treat it as a separate expense, or distribute proportionally.
          // For now, let's assign proportionally based on weight.
          // This is a simplification; in a real scenario, you'd divide total carrying cost by total kg sold.
          saleCarryingCost: (saleCarryingCost / _totalSelectedWeight) * sack.purchaseWeightKg, // Proportional
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

    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTabIndex,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.saleTitle),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: localizations.singleSaleTab),
              Tab(text: localizations.bulkSaleTab),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // --- Single Sack Sale Tab ---
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _currentSack == null
                        ? localizations.selectSackForSale
                        : '${localizations.sellingSack}: ${_currentSack!.uniqueSackIdentifier} (${_currentSack!.productType})',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  if (_currentSack != null) ...[
                    const SizedBox(height: 10),
                    _buildInfoRow(localizations.purchaseWeightLabel, '${_currentSack!.purchaseWeightKg} Kg'),
                    _buildInfoRow(localizations.purchasePricePerKgLabel, '৳ ${_currentSack!.purchasePricePerKg.toStringAsFixed(2)}/Kg'),
                    _buildInfoRow(localizations.purchaseDateLabel, _currentSack!.purchaseDate.toIso8601String().split('T')[0]),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _singleSaleDateController,
                      decoration: InputDecoration(
                        labelText: localizations.saleDateLabel,
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(_singleSaleDateController),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _singleSaleWeightController,
                      decoration: InputDecoration(
                        labelText: localizations.saleWeightLabel,
                        suffixText: 'Kg',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _singleSalePriceController,
                      decoration: InputDecoration(
                        labelText: localizations.salePricePerKgLabel,
                        prefixText: '৳ ',
                        suffixText: '/Kg',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _singleSaleCarryingCostController,
                      decoration: InputDecoration(
                        labelText: localizations.saleCarryingCostLabel,
                        prefixText: '৳ ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<Party>(
                      value: _selectedCustomerForSingleSale,
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
                          _selectedCustomerForSingleSale = newValue;
                        });
                      },
                      validator: (value) => value == null ? localizations.customerRequired : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _recordSingleSale,
                      child: Text(localizations.recordSale),
                    ),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Text(
                        localizations.selectSackFromInventoryTip,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontStyle: FontStyle.italic, color: Theme.of(context).hintColor),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // --- Bulk Sale Tab ---
            Column(
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
                        validator: (value) => value == null ? localizations.customerRequired : null,
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
          ],
        ),
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