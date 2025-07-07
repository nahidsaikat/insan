import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../l10n/app_localizations.dart';
import '../models/inventory_location.dart';
import '../models/party.dart';
import '../models/sack.dart';

class SackDetailScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final int sackId;
  final Function() onDataUpdated; // Callback to refresh previous screen

  const SackDetailScreen({
    super.key,
    required this.dbHelper,
    required this.sackId,
    required this.onDataUpdated,
  });

  @override
  State<SackDetailScreen> createState() => _SackDetailScreenState();
}

class _SackDetailScreenState extends State<SackDetailScreen> {
  Sack? _sack;
  Party? _vendor;
  Party? _customer;
  InventoryLocation? _currentLocation;

  // Controllers for editable fields
  final TextEditingController _productTypeController = TextEditingController();
  final TextEditingController _uniqueSackIdentifierController = TextEditingController();

  List<InventoryLocation> _locations = [];
  InventoryLocation? _selectedLocationForEdit; // For changing sack's location

  bool _isEditing = false; // To toggle edit mode

  @override
  void initState() {
    super.initState();
    _loadSackDetails();
  }

  @override
  void dispose() {
    _productTypeController.dispose();
    _uniqueSackIdentifierController.dispose();
    super.dispose();
  }

  Future<void> _loadSackDetails() async {
    final sack = await widget.dbHelper.getSackById(widget.sackId);
    if (sack == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).sackNotFound)), // Localize
        );
        Navigator.of(context).pop();
      }
      return;
    }

    final vendor = await widget.dbHelper.getPartyById(sack.purchaseVendorId);
    final customer = sack.saleCustomerId != null
        ? await widget.dbHelper.getPartyById(sack.saleCustomerId!)
        : null;
    final currentLocation = await widget.dbHelper.getInventoryLocationById(sack.currentLocationId);
    final locations = await widget.dbHelper.getInventoryLocations(); // For location dropdown

    setState(() {
      _sack = sack;
      _vendor = vendor;
      _customer = customer;
      _currentLocation = currentLocation;
      _locations = locations;

      // Initialize controllers for editable fields
      _productTypeController.text = sack.productType;
      _uniqueSackIdentifierController.text = sack.uniqueSackIdentifier;
      _selectedLocationForEdit = currentLocation; // Set initial value for dropdown
    });
  }

  Future<void> _updateSackDetails() async {
    final localizations = AppLocalizations.of(context);
    if (_sack == null) return;

    // Create a new Sack object with updated values using copyWith
    final updatedSack = _sack!.copyWith(
      productType: _productTypeController.text,
      uniqueSackIdentifier: _uniqueSackIdentifierController.text,
      currentLocationId: _selectedLocationForEdit?.locationId ?? _sack!.currentLocationId, // Update location
    );

    try {
      await widget.dbHelper.updateSack(updatedSack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.sackUpdatedSuccessfully)), // Localize
        );
        setState(() {
          _isEditing = false; // Exit edit mode
          _sack = updatedSack; // Update local sack object
          _currentLocation = _selectedLocationForEdit; // Update local location object
        });
        widget.onDataUpdated(); // Notify previous screen (InventoryScreen) to refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${localizations.errorUpdatingSack} $e')), // Localize
        );
      }
    }
  }

  Future<void> _deleteSack() async {
    final localizations = AppLocalizations.of(context);
    if (_sack == null) return;

    // Warn if sack has been sold
    if (_sack!.status == 'Sold') {
      bool? confirmSoldDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(localizations.deleteButton),
            content: Text(localizations.confirmDeleteSoldSack), // Localize
            actions: <Widget>[
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(localizations.cancelButton)),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(localizations.deleteAnyway), // Localize
              ),
            ],
          );
        },
      );
      if (confirmSoldDelete != true) return; // If user cancels or doesn't confirm sold sack delete
    } else {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(localizations.deleteButton),
            content: Text(localizations.confirmDeleteSack), // Localize
            actions: <Widget>[
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(localizations.cancelButton)),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(localizations.deleteButton),
              ),
            ],
          );
        },
      );
      if (confirm != true) return;
    }


    try {
      await widget.dbHelper.deleteSack(widget.sackId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.sackDeletedSuccessfully)), // Localize
        );
        widget.onDataUpdated(); // Notify previous screen to refresh
        Navigator.of(context).pop(); // Go back after deletion
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${localizations.errorDeletingSack} $e')), // Localize
        );
      }
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    if (_sack == null) {
      return Scaffold(
        appBar: AppBar(title: Text(localizations.sackDetailsTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${localizations.sackDetailsTitle} - ${_sack!.uniqueSackIdentifier}'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _updateSackDetails();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
            tooltip: _isEditing ? localizations.saveButton : localizations.editButton,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteSack,
            tooltip: localizations.deleteButton,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.generalInfo,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            if (_isEditing)
              Column(
                children: [
                  TextFormField(
                    controller: _productTypeController,
                    decoration: InputDecoration(labelText: localizations.productLabel),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _uniqueSackIdentifierController,
                    decoration: InputDecoration(labelText: localizations.uniqueSackIdentifierLabel),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<InventoryLocation>(
                    value: _selectedLocationForEdit,
                    hint: Text(localizations.locationLabel),
                    decoration: InputDecoration(labelText: localizations.currentLocation),
                    items: _locations.map((location) {
                      return DropdownMenuItem(
                        value: location,
                        child: Text(location.name),
                      );
                    }).toList(),
                    onChanged: (InventoryLocation? newValue) {
                      setState(() {
                        _selectedLocationForEdit = newValue;
                      });
                    },
                  ),
                ],
              )
            else
              Column(
                children: [
                  _buildDetailRow(localizations.productLabel, _sack!.productType),
                  _buildDetailRow(localizations.uniqueSackIdentifierLabel, _sack!.uniqueSackIdentifier),
                  _buildDetailRow(localizations.statusLabel, _sack!.status),
                  _buildDetailRow(localizations.currentLocation, _currentLocation?.name ?? localizations.unknown),
                ],
              ),
            const SizedBox(height: 20),

            Text(
              localizations.purchaseDetails,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            _buildDetailRow(localizations.dateLabel, _sack!.purchaseDate.toIso8601String().split('T')[0]),
            _buildDetailRow(localizations.vendorLabel, _vendor?.name ?? localizations.unknown),
            _buildDetailRow(localizations.weightLabel, '${_sack!.purchaseWeightKg} Kg'),
            _buildDetailRow(localizations.pricePerKgLabel, '৳ ${_sack!.purchasePricePerKg.toStringAsFixed(2)}/Kg'),
            if (_sack!.purchaseCarryingCost > 0)
              _buildDetailRow(localizations.carryingCostLabel, '৳ ${_sack!.purchaseCarryingCost.toStringAsFixed(2)}'),
            _buildDetailRow(localizations.totalPurchaseValue, '৳ ${(_sack!.purchaseWeightKg * _sack!.purchasePricePerKg + (_sack!.purchaseCarryingCost ?? 0)).toStringAsFixed(2)}'),
            const SizedBox(height: 20),

            if (_sack!.status == 'Sold') ...[
              Text(
                localizations.saleDetails,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Divider(),
              _buildDetailRow(localizations.dateLabel, _sack!.saleDate?.toIso8601String().split('T')[0] ?? localizations.notAvailable),
              _buildDetailRow(localizations.customerLabel, _customer?.name ?? localizations.unknown),
              _buildDetailRow(localizations.weightLabel, '${_sack!.saleWeightKg?.toStringAsFixed(2) ?? localizations.notAvailable} Kg'),
              _buildDetailRow(localizations.pricePerKgLabel, '৳ ${_sack!.salePricePerKg?.toStringAsFixed(2) ?? localizations.notAvailable}/Kg'),
              if (_sack!.saleCarryingCost != null && _sack!.saleCarryingCost! > 0)
                _buildDetailRow(localizations.carryingCostLabel, '৳ ${_sack!.saleCarryingCost!.toStringAsFixed(2)}'),
              _buildDetailRow(localizations.totalSaleValue, '৳ ${((_sack!.saleWeightKg ?? 0) * (_sack!.salePricePerKg ?? 0) - (_sack!.saleCarryingCost ?? 0)).toStringAsFixed(2)}'),
              _buildDetailRow(localizations.netGainLoss, '৳ ${(_sack!.netProfitLoss ?? 0).toStringAsFixed(2)}'), // Ensure netProfitLoss is calculated in Sack model
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}