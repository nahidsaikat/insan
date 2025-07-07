import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/party.dart';
import '../l10n/app_localizations.dart';

class PartyManagementScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const PartyManagementScreen({
    super.key,
    required this.dbHelper,
  });

  @override
  State<PartyManagementScreen> createState() => _PartyManagementScreenState();
}

class _PartyManagementScreenState extends State<PartyManagementScreen> {
  List<Party> _parties = [];
  String _selectedPartyTypeFilter = 'All'; // Filter for displaying parties

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _selectedPartyType; // For the dropdown in add/edit dialog

  @override
  void initState() {
    super.initState();
    _loadParties();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadParties() async {
    List<Party> parties;
    if (_selectedPartyTypeFilter == 'All') {
      parties = await widget.dbHelper.getParties();
    } else {
      parties = await widget.dbHelper.getPartiesByType(_selectedPartyTypeFilter);
    }
    setState(() {
      _parties = parties;
    });
  }

  Future<void> _addOrUpdateParty({Party? partyToEdit}) async {
    // Clear controllers and reset dropdown for new party
    if (partyToEdit == null) {
      _nameController.clear();
      _contactController.clear();
      _addressController.clear();
      _selectedPartyType = null;
    } else {
      // Pre-fill controllers and set dropdown for editing
      _nameController.text = partyToEdit.name;
      _contactController.text = partyToEdit.phone ?? '';
      _addressController.text = partyToEdit.address ?? '';
      _selectedPartyType = partyToEdit.type;
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        final localizations = AppLocalizations.of(context);
        return StatefulBuilder( // Use StatefulBuilder for dropdown to rebuild
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: Text(partyToEdit == null
                  ? localizations.addPartyButton
                  : localizations.editButton),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: localizations.partyNameHint,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedPartyType,
                      hint: Text(localizations.partyTypeHint),
                      items: [
                        DropdownMenuItem(value: 'Investor', child: Text(localizations.partyTypeInvestor)),
                        DropdownMenuItem(value: 'Farmer', child: Text(localizations.partyTypeFarmer)),
                        DropdownMenuItem(value: 'Customer', child: Text(localizations.partyTypeCustomer)),
                        DropdownMenuItem(value: 'Other Vendor', child: Text(localizations.partyTypeOtherVendor)),
                      ],
                      onChanged: (String? newValue) {
                        setStateInDialog(() {
                          _selectedPartyType = newValue;
                        });
                      },
                      validator: (value) => value == null ? 'Please select a party type.' : null,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _contactController,
                      decoration: InputDecoration(
                        labelText: localizations.partyContactHint,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: localizations.partyAddressHint,
                      ),
                      maxLines: 2,
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
                    if (_nameController.text.isEmpty || _selectedPartyType == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Party name and type cannot be empty.')), // Consider localizing this message
                      );
                      return;
                    }

                    // Generate a simple code from the name.
                    String code = _nameController.text.replaceAll(' ', '').replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
                    if (code.length > 10) code = code.substring(0, 10);

                    if (partyToEdit == null) {
                      // Insert new party
                      final newParty = Party(
                        name: _nameController.text,
                        code: code,
                        type: _selectedPartyType!,
                        phone: _contactController.text.isEmpty ? null : _contactController.text,
                        address: _addressController.text.isEmpty ? null : _addressController.text,
                      );
                      await widget.dbHelper.insertParty(newParty);
                    } else {
                      // Update existing party
                      final updatedParty = Party(
                        partyId: partyToEdit.partyId,
                        name: _nameController.text,
                        code: partyToEdit.code, // Keep original code for update
                        type: _selectedPartyType!,
                        phone: _contactController.text.isEmpty ? null : _contactController.text,
                        address: _addressController.text.isEmpty ? null : _addressController.text,
                      );
                      await widget.dbHelper.updateParty(updatedParty);
                    }
                    Navigator.of(context).pop();
                    _loadParties(); // Refresh list
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

  Future<void> _deleteParty(int partyId) async {
    final localizations = AppLocalizations.of(context);
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.deleteButton),
          content: Text('Are you sure you want to delete this party?'), // Localize this
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
      // In a real app, you would check for dependent records (sacks, investments, etc.)
      // and either prevent deletion or handle cascade deletion.
      // For now, we're assuming direct deletion.
      await widget.dbHelper.deleteParty(partyId);
      _loadParties(); // Refresh list
    }
  }

  String? getPartyTypeLocalization(AppLocalizations localizations, String partyType) {
    final partyTypeLocalization = {
      'Investor': localizations.partyTypeInvestor,
      'Farmer': localizations.partyTypeFarmer,
      'Customer': localizations.partyTypeCustomer,
      'Other Vendor': localizations.partyTypeOtherVendor,
    };
    return partyTypeLocalization[partyType];
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.partyManagementTitle),
        actions: [
          // Filter dropdown
          DropdownButton<String>(
            value: _selectedPartyTypeFilter,
            items: [
              DropdownMenuItem(value: 'All', child: Text('All')), // Localize this
              DropdownMenuItem(value: 'Investor', child: Text(localizations.partyTypeInvestor)),
              DropdownMenuItem(value: 'Farmer', child: Text(localizations.partyTypeFarmer)),
              DropdownMenuItem(value: 'Customer', child: Text(localizations.partyTypeCustomer)),
              DropdownMenuItem(value: 'Other Vendor', child: Text(localizations.partyTypeOtherVendor)),
            ],
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedPartyTypeFilter = newValue;
                });
                _loadParties(); // Reload parties based on new filter
              }
            },
            dropdownColor: Theme.of(context).primaryColor, // Match app bar color
            style: const TextStyle(color: Colors.white),
            underline: const SizedBox(), // Remove default underline
            iconEnabledColor: Colors.white, // Color of the dropdown arrow
          ),
          const SizedBox(width: 16), // Padding for the dropdown
        ],
      ),
      body: _parties.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _selectedPartyTypeFilter == 'All'
                  ? localizations.noPartiesFoundMessage // Localize this
                  : localizations.noFilteredPartiesFoundMessage, // Localize this
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _addOrUpdateParty(),
              icon: const Icon(Icons.person_add),
              label: Text(localizations.addPartyButton),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _parties.length,
        itemBuilder: (context, index) {
          final party = _parties[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            elevation: 2,
            child: ListTile(
              title: Text(
                party.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${localizations.partyTypeHint}: ${getPartyTypeLocalization(localizations, party.type)}'),
                  if (party.phone != null && party.phone!.isNotEmpty)
                    Text('${localizations.partyContactHint}: ${party.phone}'),
                  if (party.address != null && party.address!.isNotEmpty)
                    Text('${localizations.partyAddressHint}: ${party.address}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: localizations.editButton,
                    onPressed: () => _addOrUpdateParty(partyToEdit: party),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: localizations.deleteButton,
                    onPressed: () => _deleteParty(party.partyId!),
                  ),
                ],
              ),
              // onTap: () { /* Future: View Party Details */ },
            ),
          );
        },
      ),
      floatingActionButton: _parties.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: () => _addOrUpdateParty(),
        label: Text(localizations.addPartyButton),
        icon: const Icon(Icons.person_add),
      )
          : null, // FAB is only shown if parties exist
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
