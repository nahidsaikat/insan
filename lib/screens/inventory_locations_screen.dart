import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/inventory_location.dart';
import '../l10n/app_localizations.dart';

class InventoryLocationsScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const InventoryLocationsScreen({
    super.key,
    required this.dbHelper,
  });

  @override
  State<InventoryLocationsScreen> createState() => _InventoryLocationsScreenState();
}

class _InventoryLocationsScreenState extends State<InventoryLocationsScreen> {
  List<InventoryLocation> _locations = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _rentCostController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _rentCostController.dispose();
    super.dispose();
  }

  Future<void> _loadLocations() async {
    final locations = await widget.dbHelper.getInventoryLocations();
    setState(() {
      _locations = locations;
    });
  }

  Future<void> _addOrUpdateLocation({InventoryLocation? locationToEdit}) async {
    final localizations = AppLocalizations.of(context);
    // Clear controllers for new location, or pre-fill for editing
    if (locationToEdit == null) {
      _nameController.clear();
      _addressController.clear();
      _rentCostController.clear();
    } else {
      _nameController.text = locationToEdit.name;
      _addressController.text = locationToEdit.address ?? '';
      _rentCostController.text = locationToEdit.rentCostPerMonth?.toString() ?? '';
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: Text(locationToEdit == null
                  ? localizations.addLocationButton
                  : localizations.editButton),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: localizations.locationNameHint,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: localizations.locationAddressHint,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _rentCostController,
                      decoration: InputDecoration(
                        labelText: localizations.locationRentCostHint,
                        prefixText: '৳ ', // Assuming BDT
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(localizations.cancelButton),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Location name cannot be empty.')), // Localize this
                      );
                      return;
                    }

                    final name = _nameController.text;
                    final address = _addressController.text.isEmpty ? null : _addressController.text;
                    final rentCost = double.tryParse(_rentCostController.text);

                    if (locationToEdit == null) {
                      // Insert new location
                      final newLocation = InventoryLocation(
                        name: name,
                        address: address,
                        rentCostPerMonth: rentCost,
                      );
                      await widget.dbHelper.insertInventoryLocation(newLocation);
                    } else {
                      // Update existing location
                      final updatedLocation = InventoryLocation(
                        locationId: locationToEdit.locationId,
                        name: name,
                        address: address,
                        rentCostPerMonth: rentCost,
                      );
                      await widget.dbHelper.updateInventoryLocation(updatedLocation);
                    }
                    Navigator.of(context).pop();
                    _loadLocations(); // Refresh list
                  },
                  child: Text(localizations.saveButton),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteLocation(int locationId) async {
    final localizations = AppLocalizations.of(context);
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.deleteButton),
          content: Text('Are you sure you want to delete this inventory location?'), // Localize this
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(localizations.cancelButton),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(localizations.deleteButton),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // IMPORTANT: In a real application, you must check if any Sacks are
      // currently assigned to this location. If so, you should:
      // 1. Prevent deletion and inform the user.
      // 2. Or, prompt the user to reassign sacks to another location before deleting.
      // For now, we're doing a direct delete, which would orphan sacks in production.
      await widget.dbHelper.deleteInventoryLocation(locationId);
      _loadLocations(); // Refresh list
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.inventoryLocationsTitle),
      ),
      body: _locations.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              localizations.noLocationsFoundMessage,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _addOrUpdateLocation(),
              icon: const Icon(Icons.add_location_alt),
              label: Text(localizations.addLocationButton),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _locations.length,
        itemBuilder: (context, index) {
          final location = _locations[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            elevation: 2,
            child: ListTile(
              title: Text(
                location.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (location.address != null && location.address!.isNotEmpty)
                    Text('${localizations.locationAddressHint}: ${location.address}'),
                  if (location.rentCostPerMonth != null)
                    Text('${localizations.locationRentCostHint}: ৳ ${location.rentCostPerMonth!.toStringAsFixed(2)}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: localizations.editButton,
                    onPressed: () => _addOrUpdateLocation(locationToEdit: location),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: localizations.deleteButton,
                    onPressed: () => _deleteLocation(location.locationId!),
                  ),
                ],
              ),
              // onTap: () { /* Future: View Sacks in this location */ },
            ),
          );
        },
      ),
      floatingActionButton: _locations.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: () => _addOrUpdateLocation(),
        label: Text(localizations.addLocationButton),
        icon: const Icon(Icons.add_location_alt),
      )
          : null, // FAB is only shown if locations exist
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
