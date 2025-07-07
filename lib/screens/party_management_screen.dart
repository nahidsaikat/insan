// lib/screens/party_management_screen.dart

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/party.dart';
import '../l10n/app_localizations.dart';

// Assuming you have these screens for navigation, even if not directly called in this file
// import '../screens/party_detail_screen.dart';
// import '../screens/add_edit_party_screen.dart';


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
  bool _isLoading = true; // Added loading state for clarity

  // Existing filter state variables for add/edit dialog
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _selectedPartyType; // For the dropdown in add/edit dialog

  // NEW: Filter state variables for search and filtering the list view
  String _currentSelectedPartyTypeFilter = 'All'; // Filter for displaying parties
  final TextEditingController _searchController = TextEditingController(); // For party name/phone search
  List<String> _availablePartyTypes = ['All', 'Investor', 'Farmer', 'Customer', 'Other Vendor']; // Initial list of types for filter dropdown

  @override
  void initState() {
    super.initState();
    _loadAvailablePartyTypesAndParties(); // Load available types and then parties
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _searchController.dispose(); // Dispose the new search controller
    super.dispose();
  }

  // NEW: Method to load available party types from DB and then initial parties
  Future<void> _loadAvailablePartyTypesAndParties() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Get types from DB. This is important to ensure consistency if types change.
      List<String> dbTypes = await widget.dbHelper.getDistinctPartyTypes();
      // Ensure 'All' is always the first option
      _availablePartyTypes = ['All', ...dbTypes];
      // Set initial selection
      _currentSelectedPartyTypeFilter = _availablePartyTypes.first;

    } catch (e) {
      print('Error loading available party types: $e');
    } finally {
      await _loadParties(); // Load parties with initial filters
    }
  }


  Future<void> _loadParties() async {
    setState(() {
      _isLoading = true; // Set loading to true before fetching
    });
    try {
      final AppLocalizations localizations = AppLocalizations.of(context);

      // Map "All" localized string back to null for database query
      String? queryPartyType;
      if (_currentSelectedPartyTypeFilter != localizations.allTypes) {
        queryPartyType = _currentSelectedPartyTypeFilter;
      }
      else {
        queryPartyType = null;
      }
      // If the localized 'All' is picked, pass null for type filtering

      final String? querySearchText = _searchController.text.trim().isNotEmpty ? _searchController.text.trim() : null;

      _parties = await widget.dbHelper.getParties(
        partyType: queryPartyType,
        searchText: querySearchText,
      );

    } catch (e) {
      print('Error loading parties: $e');
      // Optionally show a SnackBar or an error message
    } finally {
      setState(() {
        _isLoading = false; // Set loading to false after fetching
      });
    }
  }

  // NEW: Reset filters method
  void _resetFilters() {
    final localizations = AppLocalizations.of(context);
    setState(() {
      _searchController.clear();
      _currentSelectedPartyTypeFilter = localizations.allTypes;
      // Re-initialize _availablePartyTypes in case the list of types changes
      // This might not be strictly necessary with `getDistinctPartyTypes` but harmless.
      _loadAvailablePartyTypesAndParties(); // This will reload everything
    });
    // No need to call _loadParties directly as _loadAvailablePartyTypesAndParties does it.
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
        final localizations = AppLocalizations.of(context); // Ensured non-null
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
                      validator: (value) => value == null ? localizations.partyTypeEmptyValidation : null, // Localized
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
                        SnackBar(content: Text(localizations.partyNameTypeEmptyValidation)), // Localized
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
                    _loadParties(); // Refresh list after add/update
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
    final localizations = AppLocalizations.of(context); // Ensured non-null
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.deleteButton),
          content: Text(localizations.confirmDeleteParty), // Localized
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

  String getPartyTypeLocalization(AppLocalizations localizations, String partyType) {
    // This method now also handles the 'All' type for consistency
    if (partyType == 'All') return localizations.allTypes; // 'All' is handled by localization

    final partyTypeLocalization = {
      'Investor': localizations.partyTypeInvestor,
      'Farmer': localizations.partyTypeFarmer,
      'Customer': localizations.partyTypeCustomer,
      'Other Vendor': localizations.partyTypeOtherVendor,
    };

    return partyTypeLocalization[partyType] ?? partyType;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context); // Ensured non-null

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.partyManagementTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110.0), // Adjust height for filters
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: localizations.searchParty,
                    hintText: localizations.searchPartyHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _loadParties(); // Reload after clearing
                      },
                    )
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    // Implement a debounce if search is too frequent, or just call _loadParties immediately
                    // For simplicity, calling immediately. Consider debounce for large datasets.
                    _loadParties();
                  },
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _currentSelectedPartyTypeFilter,
                        decoration: InputDecoration(
                          labelText: localizations.partyType, // Re-using from previous suggestion
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _availablePartyTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(getPartyTypeLocalization(localizations, type)!), // Use localization helper
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _currentSelectedPartyTypeFilter = newValue;
                            });
                            _loadParties(); // Reload parties based on new filter
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    ElevatedButton.icon(
                      onPressed: _resetFilters,
                      icon: const Icon(Icons.refresh),
                      label: Text(localizations.resetFilters),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading // Use the _isLoading state
          ? const Center(child: CircularProgressIndicator())
          : _parties.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _currentSelectedPartyTypeFilter == localizations.allTypes && _searchController.text.isEmpty
                  ? localizations.noPartiesFoundMessage // Original no parties message when no filters applied
                  : localizations.noFilteredPartiesFoundMessage, // Message for filtered results
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
      floatingActionButton: _parties.isNotEmpty || (_searchController.text.isNotEmpty || _currentSelectedPartyTypeFilter != localizations.allTypes) // Show FAB even if filtered list is empty, but only if there are parties in general
          ? FloatingActionButton.extended(
        onPressed: () => _addOrUpdateParty(),
        label: Text(localizations.addPartyButton),
        icon: const Icon(Icons.person_add),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}