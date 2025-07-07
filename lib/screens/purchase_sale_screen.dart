import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/season.dart';
import '../models/sack.dart';
import '../models/party.dart';
import '../models/inventory_location.dart';
import '../l10n/app_localizations.dart';

class PurchaseSaleScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final Season activeSeason;
  final int initialTabIndex;

  const PurchaseSaleScreen({
    super.key,
    required this.dbHelper,
    required this.activeSeason,
    this.initialTabIndex = 0,
  });

  @override
  State<PurchaseSaleScreen> createState() => _PurchaseSaleScreenState();
}

class _PurchaseSaleScreenState extends State<PurchaseSaleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers for Purchase Form
  final TextEditingController _purchaseDateController = TextEditingController();
  final TextEditingController _purchaseProductTypeController = TextEditingController();
  final TextEditingController _purchaseWeightController = TextEditingController();
  final TextEditingController _purchasePricePerKgController = TextEditingController();
  final TextEditingController _purchaseCarryingCostController = TextEditingController();
  final TextEditingController _purchaseSackIdentifierController = TextEditingController();

  Party? _selectedVendor;
  InventoryLocation? _selectedPurchaseLocation;

  // Controllers for Sale Form
  final TextEditingController _saleDateController = TextEditingController();
  final TextEditingController _saleWeightController = TextEditingController();
  final TextEditingController _salePricePerKgController = TextEditingController();
  final TextEditingController _saleCarryingCostController = TextEditingController();
  final TextEditingController _saleSackIdentifierController = TextEditingController();

  Party? _selectedCustomer;

  List<Party> _vendors = [];
  List<Party> _customers = [];
  List<InventoryLocation> _locations = [];
  List<Sack> _availableSacks = []; // Sacks currently "In Stock" for selection

  Sack? _selectedSackForSale;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
    _purchaseDateController.text = DateTime.now().toIso8601String().split('T')[0]; // Default to today

    _loadDropdownData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _purchaseDateController.dispose();
    _purchaseProductTypeController.dispose();
    _purchaseWeightController.dispose();
    _purchasePricePerKgController.dispose();
    _purchaseCarryingCostController.dispose();
    _purchaseSackIdentifierController.dispose();

    _saleDateController.dispose();
    _saleWeightController.dispose();
    _salePricePerKgController.dispose();
    _saleCarryingCostController.dispose();
    _saleSackIdentifierController.dispose();

    super.dispose();
  }

  Future<void> _loadDropdownData() async {
    final parties = await widget.dbHelper.getParties();
    final locations = await widget.dbHelper.getInventoryLocations();
    final inStockSacks = await widget.dbHelper.getSacks(
      seasonId: widget.activeSeason.seasonId,
      status: 'In Stock',
    );

    setState(() {
      _vendors = parties.where((p) => p.type == 'Farmer' || p.type == 'Other Vendor').toList();
      _customers = parties.where((p) => p.type == 'Customer' || p.type == 'Other Vendor').toList();
      _locations = locations;
      _availableSacks = inStockSacks;
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

  Future<void> _recordPurchase() async {
    final localizations = AppLocalizations.of(context);
    if (_purchaseProductTypeController.text.isEmpty ||
        _purchaseWeightController.text.isEmpty ||
        _purchasePricePerKgController.text.isEmpty ||
        _purchaseDateController.text.isEmpty ||
        _selectedVendor == null ||
        _selectedPurchaseLocation == null ||
        _purchaseSackIdentifierController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required purchase fields.')), // Localize this
      );
      return;
    }

    final purchaseWeight = double.tryParse(_purchaseWeightController.text);
    final purchasePrice = double.tryParse(_purchasePricePerKgController.text);
    final carryingCost = double.tryParse(_purchaseCarryingCostController.text) ?? 0.0;

    if (purchaseWeight == null || purchasePrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid numbers for weight and price.')), // Localize this
      );
      return;
    }

    final newSack = Sack(
      seasonId: widget.activeSeason.seasonId!,
      productType: _purchaseProductTypeController.text,
      uniqueSackIdentifier: _purchaseSackIdentifierController.text,
      purchaseDate: DateTime.parse(_purchaseDateController.text),
      purchaseWeightKg: purchaseWeight,
      purchasePricePerKg: purchasePrice,
      purchaseCarryingCost: carryingCost,
      purchaseVendorId: _selectedVendor!.partyId!,
      currentLocationId: _selectedPurchaseLocation!.locationId!,
      status: 'In Stock',
      purchaseSeasonId: widget.activeSeason.seasonId!,
    );

    try {
      await widget.dbHelper.insertSack(newSack);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase recorded successfully!')), // Localize this
      );
      _clearPurchaseForm();
      _loadDropdownData(); // Refresh available sacks and dropdowns
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error recording purchase: $e')), // Localize this
      );
    }
  }

  void _clearPurchaseForm() {
    _purchaseProductTypeController.clear();
    _purchaseWeightController.clear();
    _purchasePricePerKgController.clear();
    _purchaseCarryingCostController.clear();
    _purchaseSackIdentifierController.clear();
    _purchaseDateController.text = DateTime.now().toIso8601String().split('T')[0];
    setState(() {
      _selectedVendor = null;
      _selectedPurchaseLocation = null;
    });
  }

  Future<void> _recordSale() async {
    final localizations = AppLocalizations.of(context);
    if (_selectedSackForSale == null ||
        _saleDateController.text.isEmpty ||
        _saleWeightController.text.isEmpty ||
        _salePricePerKgController.text.isEmpty ||
        _selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a sack and fill all required sale fields.')), // Localize this
      );
      return;
    }

    final saleWeight = double.tryParse(_saleWeightController.text);
    final salePrice = double.tryParse(_salePricePerKgController.text);
    final carryingCost = double.tryParse(_saleCarryingCostController.text) ?? 0.0;

    if (saleWeight == null || salePrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid numbers for weight and price.')), // Localize this
      );
      return;
    }

    // Update the existing sack
    final updatedSack = _selectedSackForSale!.copyWith(
      saleDate: DateTime.parse(_saleDateController.text),
      saleWeightKg: saleWeight,
      salePricePerKg: salePrice,
      saleCarryingCost: carryingCost,
      saleCustomerId: _selectedCustomer!.partyId!,
      status: 'Sold', // Mark as sold
      // current_location_id remains the last location it was in when sold
    );

    try {
      await widget.dbHelper.updateSack(updatedSack);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sale recorded successfully!')), // Localize this
      );
      _clearSaleForm();
      _loadDropdownData(); // Refresh available sacks and dropdowns
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error recording sale: $e')), // Localize this
      );
    }
  }

  void _clearSaleForm() {
    _saleDateController.text = DateTime.now().toIso8601String().split('T')[0];
    _saleWeightController.clear();
    _salePricePerKgController.clear();
    _saleCarryingCostController.clear();
    _saleSackIdentifierController.clear(); // Clear info from selected sack
    setState(() {
      _selectedSackForSale = null;
      _selectedCustomer = null;
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
          title: Text(localizations.transactionsTitle),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: localizations.recordPurchaseButton),
              Tab(text: localizations.recordSaleButton),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Purchase Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _purchaseDateController,
                    decoration: InputDecoration(
                      labelText: localizations.dateLabel,
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(_purchaseDateController),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<Party>(
                    value: _selectedVendor,
                    hint: Text(localizations.vendorLabel),
                    decoration: InputDecoration(
                      labelText: localizations.vendorLabel,
                    ),
                    items: _vendors.map((party) {
                      return DropdownMenuItem(
                        value: party,
                        child: Text(party.name),
                      );
                    }).toList(),
                    onChanged: (Party? newValue) {
                      setState(() {
                        _selectedVendor = newValue;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a vendor.' : null, // Localize this
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<InventoryLocation>(
                    value: _selectedPurchaseLocation,
                    hint: Text(localizations.locationLabel),
                    decoration: InputDecoration(
                      labelText: localizations.locationLabel,
                    ),
                    items: _locations.map((location) {
                      return DropdownMenuItem(
                        value: location,
                        child: Text(location.name),
                      );
                    }).toList(),
                    onChanged: (InventoryLocation? newValue) {
                      setState(() {
                        _selectedPurchaseLocation = newValue;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a location.' : null, // Localize this
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _purchaseProductTypeController,
                    decoration: InputDecoration(
                      labelText: localizations.productLabel,
                      hintText: 'e.g., Paddy, Corn', // Localize this
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _purchaseSackIdentifierController,
                    decoration: InputDecoration(
                      labelText: localizations.uniqueSackIdentifierLabel,
                      hintText: 'e.g., P001, C-Batch-A', // Localize this
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _purchaseWeightController,
                    decoration: InputDecoration(
                      labelText: localizations.weightLabel,
                      suffixText: 'Kg',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _purchasePricePerKgController,
                    decoration: InputDecoration(
                      labelText: localizations.pricePerKgLabel,
                      prefixText: '৳ ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _purchaseCarryingCostController,
                    decoration: InputDecoration(
                      labelText: localizations.carryingCostLabel,
                      prefixText: '৳ ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _recordPurchase,
                    child: Text(localizations.recordPurchaseButton),
                  ),
                ],
              ),
            ),

            // Sale Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<Sack>(
                    value: _selectedSackForSale,
                    hint: Text(localizations.uniqueSackIdentifierLabel), // Select a Sack
                    decoration: InputDecoration(
                      labelText: localizations.uniqueSackIdentifierLabel,
                    ),
                    items: _availableSacks.map((sack) {
                      return DropdownMenuItem(
                        value: sack,
                        child: Text('${sack.uniqueSackIdentifier} (${sack.purchaseWeightKg} Kg)'),
                      );
                    }).toList(),
                    onChanged: (Sack? newValue) {
                      setState(() {
                        _selectedSackForSale = newValue;
                        if (newValue != null) {
                          // Pre-fill some details from the selected sack for convenience
                          _saleSackIdentifierController.text = newValue.uniqueSackIdentifier;
                          _saleWeightController.text = newValue.purchaseWeightKg.toString(); // Default sale weight to purchase weight
                          // _salePricePerKgController.text = ''; // Clear for new sale price
                          // _saleCarryingCostController.text = ''; // Clear for new carrying cost
                        } else {
                          _saleSackIdentifierController.clear();
                          _saleWeightController.clear();
                        }
                      });
                    },
                    validator: (value) => value == null ? 'Please select a sack to sell.' : null, // Localize this
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _saleDateController,
                    decoration: InputDecoration(
                      labelText: localizations.dateLabel,
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(_saleDateController),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<Party>(
                    value: _selectedCustomer,
                    hint: Text(localizations.customerLabel),
                    decoration: InputDecoration(
                      labelText: localizations.customerLabel,
                    ),
                    items: _customers.map((party) {
                      return DropdownMenuItem(
                        value: party,
                        child: Text(party.name),
                      );
                    }).toList(),
                    onChanged: (Party? newValue) {
                      setState(() {
                        _selectedCustomer = newValue;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a customer.' : null, // Localize this
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _saleSackIdentifierController,
                    decoration: InputDecoration(
                      labelText: localizations.uniqueSackIdentifierLabel,
                      enabled: false, // Make it non-editable as it's from selected sack
                      fillColor: Colors.grey.shade200,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _saleWeightController,
                    decoration: InputDecoration(
                      labelText: localizations.weightLabel,
                      suffixText: 'Kg',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _salePricePerKgController,
                    decoration: InputDecoration(
                      labelText: localizations.pricePerKgLabel,
                      prefixText: '৳ ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _saleCarryingCostController,
                    decoration: InputDecoration(
                      labelText: localizations.carryingCostLabel,
                      prefixText: '৳ ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _recordSale,
                    child: Text(localizations.recordSaleButton),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}