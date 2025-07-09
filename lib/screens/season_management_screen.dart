import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/season.dart';
import '../l10n/app_localizations.dart';

class SeasonManagementScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final Function(Season?) onSeasonSelected;

  const SeasonManagementScreen({
    super.key,
    required this.dbHelper,
    required this.onSeasonSelected,
  });

  @override
  State<SeasonManagementScreen> createState() => _SeasonManagementScreenState();
}

class _SeasonManagementScreenState extends State<SeasonManagementScreen> {
  List<Season> _seasons = [];
  Season? _activeSeason;
  final TextEditingController _seasonNameController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSeasons();
  }

  @override
  void dispose() {
    _seasonNameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _loadSeasons() async {
    final seasons = await widget.dbHelper.getSeasons();
    final active = await widget.dbHelper.getActiveSeason();
    setState(() {
      _seasons = seasons;
      _activeSeason = active;
    });
  }

  Future<void> _addOrUpdateSeason({Season? seasonToEdit}) async {
    // Clear controllers if adding new, or pre-fill if editing
    if (seasonToEdit == null) {
      _seasonNameController.clear();
      _startDateController.clear();
      _endDateController.clear();
    } else {
      _seasonNameController.text = seasonToEdit.name;
      _startDateController.text = seasonToEdit.startDate.toIso8601String().split('T')[0];
      _endDateController.text = seasonToEdit.endDate?.toIso8601String().split('T')[0] ?? '';
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        // Use a StatefulWidget for the dialog content to manage its own state (e.g., date pickers)
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: Text(seasonToEdit == null
                  ? AppLocalizations.of(context).createSeasonButton
                  : AppLocalizations.of(context).editButton),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _seasonNameController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).addSeasonPrompt,
                        hintText: AppLocalizations.of(context).seasonNameHint,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Start Date Picker
                    TextField(
                      controller: _startDateController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).seasonStartHint,
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.tryParse(_startDateController.text) ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setStateInDialog(() {
                            _startDateController.text = pickedDate.toIso8601String().split('T')[0];
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    // End Date Picker
                    TextField(
                      controller: _endDateController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).seasonEndHint,
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.tryParse(_endDateController.text) ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setStateInDialog(() {
                            _endDateController.text = pickedDate.toIso8601String().split('T')[0];
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(AppLocalizations.of(context).cancelButton),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_seasonNameController.text.isEmpty || _startDateController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Season name and start date cannot be empty.')),
                      );
                      return;
                    }

                    final name = _seasonNameController.text;
                    final startDate = DateTime.parse(_startDateController.text);
                    final endDate = _endDateController.text.isNotEmpty ? DateTime.parse(_endDateController.text) : null;

                    // Generate a simple code from the name for now. You might refine this.
                    // Example: "Boro 2025" -> "Boro25"
                    String code = name.replaceAll(' ', '').replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
                    if (code.length > 10) code = code.substring(0, 10); // Keep code reasonably short

                    if (seasonToEdit == null) {
                      // Insert new season
                      final newSeason = Season(
                        name: name,
                        code: code,
                        startDate: startDate,
                        endDate: endDate,
                      );
                      await widget.dbHelper.insertSeason(newSeason);
                    } else {
                      // Update existing season
                      final updatedSeason = Season(
                        seasonId: seasonToEdit.seasonId,
                        name: name,
                        code: code, // Keep or regenerate code for update based on requirement
                        startDate: startDate,
                        endDate: endDate,
                        isActive: seasonToEdit.isActive, // Preserve current active status
                      );
                      await widget.dbHelper.updateSeason(updatedSeason);
                    }
                    Navigator.of(context).pop();
                    _loadSeasons(); // Refresh list
                  },
                  child: Text(AppLocalizations.of(context).saveButton),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteSeason(int seasonId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).deleteButton),
          content: Text(AppLocalizations.of(context).confirmDeleteSeason),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context).cancelButton),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(AppLocalizations.of(context).deleteButton),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // In a real app, you'd check for dependent data (sacks, expenses, etc.)
      // and prevent deletion or cascade delete. For simplicity, we'll delete directly.
      await widget.dbHelper.deleteSeason(seasonId);
      _loadSeasons(); // Refresh list
      // If the deleted season was active, unset activeSeason and notify parent
      if (_activeSeason?.seasonId == seasonId) {
        widget.onSeasonSelected(null);
      }
    }
  }

  Future<void> _setActiveSeason(Season season) async {
    // Deactivate current active season if any
    if (_activeSeason != null && _activeSeason!.seasonId != season.seasonId) {
      final oldActive = _activeSeason!.copyWith(isActive: false); // Create a copy with isActive set to false
      await widget.dbHelper.updateSeason(oldActive);
    }

    // Set new season as active
    final newActive = season.copyWith(isActive: true); // Create a copy with isActive set to true
    await widget.dbHelper.updateSeason(newActive);

    setState(() {
      _activeSeason = newActive;
    });

    // Notify the parent widget (MyApp) about the active season change
    widget.onSeasonSelected(newActive);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${season.name} ${AppLocalizations.of(context).activeStatus}.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).seasonManagementTitle),
      ),
      body: _seasons.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context).noActiveSeasonMessage),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _addOrUpdateSeason(),
                icon: const Icon(Icons.add),
                label: Text(AppLocalizations.of(context).createSeasonButton),
              ),
            ],
          ),
        ),
      )
          : ListView.builder(
        itemCount: _seasons.length,
        itemBuilder: (context, index) {
          final season = _seasons[index];
          final isActive = season.seasonId == _activeSeason?.seasonId;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            elevation: 2,
            color: isActive ? Colors.lightGreen.shade50 : null, // Highlight active season
            child: ListTile(
              title: Text(
                season.name,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? Theme.of(context).primaryColor : null,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${AppLocalizations.of(context).seasonStartHint}: ${season.startDate.toIso8601String().split('T')[0]}'),
                  if (season.endDate != null)
                    Text('${AppLocalizations.of(context).seasonEndHint}: ${season.endDate!.toIso8601String().split('T')[0]}'),
                  Text(
                    '${AppLocalizations.of(context).seasonStatus} ${isActive ? AppLocalizations.of(context).activeStatus : AppLocalizations.of(context).inactiveStatus}',
                    style: TextStyle(
                      color: isActive ? Colors.green.shade700 : Colors.grey.shade600,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isActive) // Only show "Set Active" if not already active
                    IconButton(
                      icon: Icon(Icons.check_circle_outline, color: Colors.green),
                      tooltip: AppLocalizations.of(context).activeStatus,
                      onPressed: () => _setActiveSeason(season),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: AppLocalizations.of(context).editButton,
                    onPressed: () => _addOrUpdateSeason(seasonToEdit: season),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: AppLocalizations.of(context).deleteButton,
                    onPressed: () => _deleteSeason(season.seasonId!),
                  ),
                ],
              ),
              onTap: isActive
                  ? null // No action if already active
                  : () => _setActiveSeason(season),
            ),
          );
        },
      ),
      floatingActionButton: _seasons.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: () => _addOrUpdateSeason(),
        label: Text(AppLocalizations.of(context).createSeasonButton),
        icon: const Icon(Icons.add),
      )
          : null, // FAB is only shown if seasons exist (or you could put it in the Center column)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
