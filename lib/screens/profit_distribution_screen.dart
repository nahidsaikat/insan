import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../l10n/app_localizations.dart';
import '../models/party.dart';
import '../models/profit_distribution.dart';
import '../models/season.dart';

class ProfitDistributionScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final Season activeSeason;

  const ProfitDistributionScreen({
    super.key,
    required this.dbHelper,
    required this.activeSeason,
  });

  @override
  State<ProfitDistributionScreen> createState() => _ProfitDistributionScreenState();
}

class _ProfitDistributionScreenState extends State<ProfitDistributionScreen> {
  // Financial Summary
  double _totalRevenue = 0.0;
  double _totalPurchaseCost = 0.0;
  double _totalSaleCarryingCost = 0.0;
  double _totalPurchaseCarryingCost = 0.0;
  double _totalExpenses = 0.0;
  double _netProfit = 0.0;
  double _totalDistributedAmount = 0.0; // New variable
  double _undistributedProfit = 0.0; // New variable

  // Distribution Form Controllers
  final TextEditingController _distributionDateController = TextEditingController();
  final TextEditingController _distributionAmountController = TextEditingController();
  final TextEditingController _distributionDescriptionController = TextEditingController();

  Party? _selectedRecipient;
  List<Party> _recipients = []; // Can be Investors, or anyone profit is distributed to
  List<ProfitDistribution> _distributions = [];

  @override
  void initState() {
    super.initState();
    _distributionDateController.text = DateTime.now().toIso8601String().split('T')[0];
    _loadData();
  }

  @override
  void didUpdateWidget(covariant ProfitDistributionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeSeason.seasonId != oldWidget.activeSeason.seasonId) {
      _loadData(); // Reload if active season changes
    }
  }

  @override
  void dispose() {
    _distributionDateController.dispose();
    _distributionAmountController.dispose();
    _distributionDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final seasonId = widget.activeSeason.seasonId!;

    // 1. Fetch financial data for the active season
    _totalRevenue = await widget.dbHelper.getSeasonTotalRevenue(seasonId);
    _totalPurchaseCost = await widget.dbHelper.getSeasonTotalPurchaseCost(seasonId);
    _totalSaleCarryingCost = await widget.dbHelper.getSeasonTotalSaleCarryingCost(seasonId);
    _totalPurchaseCarryingCost = await widget.dbHelper.getSeasonTotalPurchaseCarryingCost(seasonId);
    _totalExpenses = await widget.dbHelper.getSeasonTotalExpenses(seasonId);

    _netProfit = _totalRevenue -
        (_totalPurchaseCost + _totalPurchaseCarryingCost + _totalSaleCarryingCost + _totalExpenses);

    // 2. Load existing profit distributions and calculate total distributed
    _distributions = await widget.dbHelper.getProfitDistributions(seasonId: seasonId);
    _totalDistributedAmount = _distributions.fold(0.0, (sum, item) => sum + item.amount); // Calculate total distributed

    // Calculate undistributed profit
    _undistributedProfit = _netProfit - _totalDistributedAmount;

    // 3. Load parties for recipients (e.g., Investors, or owners)
    final allParties = await widget.dbHelper.getParties();
    _recipients = allParties.where((p) => p.type == 'Investor' || p.type == 'Other Vendor').toList();
    if (_selectedRecipient != null && !_recipients.any((p) => p.partyId == _selectedRecipient!.partyId)) {
      _selectedRecipient = null;
    }
    if (_selectedRecipient == null && _recipients.isNotEmpty) {
      _selectedRecipient = _recipients.first;
    }

    setState(() {
      // UI will rebuild with updated values
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

  Future<void> _recordDistribution() async {
    final localizations = AppLocalizations.of(context);
    if (_distributionDateController.text.isEmpty ||
        _distributionAmountController.text.isEmpty ||
        _selectedRecipient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.distributionRequiredFieldsMessage)),
      );
      return;
    }

    final amount = double.tryParse(_distributionAmountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.invalidDistributionAmount)),
      );
      return;
    }

    // --- New Validation: Check against undistributed profit ---
    if (amount > _undistributedProfit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.distributionExceedsProfit)), // New localization key
      );
      return;
    }
    // If net profit is zero or negative, and they are trying to distribute a positive amount
    if (_netProfit <= 0 && amount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.cannotDistributeNegativeProfit)), // New localization key
      );
      return;
    }


    final newDistribution = ProfitDistribution(
      seasonId: widget.activeSeason.seasonId!,
      investorId: _selectedRecipient!.partyId!,
      date: DateTime.parse(_distributionDateController.text),
      amount: amount,
      notes: _distributionDescriptionController.text.isEmpty ? null : _distributionDescriptionController.text,
    );

    try {
      await widget.dbHelper.insertProfitDistribution(newDistribution);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.distributionSuccessMessage)),
      );
      _clearDistributionForm();
      _loadData(); // Refresh totals and list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${localizations.errorRecordingDistribution} $e')),
      );
    }
  }

  void _clearDistributionForm() {
    _distributionDateController.text = DateTime.now().toIso8601String().split('T')[0];
    _distributionAmountController.clear();
    _distributionDescriptionController.clear();
    setState(() {
      _selectedRecipient = _recipients.isNotEmpty ? _recipients.first : null;
    });
  }

  Future<void> _deleteDistribution(int distributionId) async {
    final localizations = AppLocalizations.of(context);
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.deleteButton),
          content: Text(localizations.confirmDeleteDistribution),
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
    if (confirm == true) {
      await widget.dbHelper.deleteProfitDistribution(distributionId);
      _loadData(); // Refresh list
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.profitDistributionTitle),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Financial Summary Card
              Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.seasonFinancialSummary,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Divider(),
                      _buildSummaryRow(localizations.totalRevenue, _totalRevenue, Colors.green),
                      _buildSummaryRow(localizations.totalPurchaseCost, _totalPurchaseCost, Colors.red),
                      _buildSummaryRow(localizations.totalCarryingCost, _totalPurchaseCarryingCost + _totalSaleCarryingCost, Colors.red),
                      _buildSummaryRow(localizations.totalExpenses, _totalExpenses, Colors.red),
                      const Divider(),
                      _buildSummaryRow(localizations.netProfitLoss, _netProfit, _netProfit >= 0 ? Colors.green.shade800 : Colors.red.shade800, isBold: true),
                      const SizedBox(height: 10),
                      _buildSummaryRow(
                        localizations.totalDistributedAmount, // New localization
                        _totalDistributedAmount,
                        Colors.blue,
                      ),
                      _buildSummaryRow(
                        localizations.undistributedProfit, // New localization
                        _undistributedProfit,
                        _undistributedProfit >= 0 ? Colors.green.shade900 : Colors.deepOrange.shade800,
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ),

              // Profit Distribution Form
              Text(
                localizations.recordProfitDistribution,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _distributionDateController,
                decoration: InputDecoration(
                  labelText: localizations.dateLabel,
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(_distributionDateController),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<Party>(
                value: _selectedRecipient,
                hint: Text(localizations.recipientLabel),
                decoration: InputDecoration(
                  labelText: localizations.recipientLabel,
                ),
                items: _recipients.map((party) {
                  return DropdownMenuItem(
                    value: party,
                    child: Text(party.name),
                  );
                }).toList(),
                onChanged: (Party? newValue) {
                  setState(() {
                    _selectedRecipient = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return localizations.selectRecipientPrompt;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _distributionAmountController,
                decoration: InputDecoration(
                  labelText: localizations.amountLabel,
                  prefixText: '৳ ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _distributionDescriptionController,
                decoration: InputDecoration(
                  labelText: localizations.descriptionLabel,
                  hintText: localizations.distributionDescriptionHint,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _recordDistribution,
                child: Text(localizations.recordDistribution),
              ),
              const SizedBox(height: 30),

              // Recent Distributions List
              Text(
                localizations.recentDistributions,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              _distributions.isEmpty
                  ? Center(child: Text(localizations.noDistributionsFound))
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _distributions.length,
                itemBuilder: (context, index) {
                  final distribution = _distributions[index];
                  final recipientName = _recipients.firstWhere(
                        (party) => party.partyId == distribution.investorId,
                    orElse: () => Party(name: 'Unknown Recipient', code: '', type: ''),
                  ).name;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                    elevation: 1,
                    child: ListTile(
                      title: Text('$recipientName - ${distribution.notes ?? ''}'),
                      subtitle: Text('${localizations.dateLabel} ${distribution.date.toIso8601String().split('T')[0]}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '৳ ${distribution.amount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteDistribution(distribution.distributionId!),
                            tooltip: localizations.deleteButton,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
          Text(
            '৳ ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}