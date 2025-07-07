import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../l10n/app_localizations.dart';
import '../models/expense.dart';
import '../models/investment.dart';
import '../models/party.dart';
import '../models/season.dart';

class ExpenseInvestmentScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final Season activeSeason;
  final int initialTabIndex; // 0 for Expense, 1 for Investment

  const ExpenseInvestmentScreen({
    super.key,
    required this.dbHelper,
    required this.activeSeason,
    this.initialTabIndex = 0,
  });

  @override
  State<ExpenseInvestmentScreen> createState() => _ExpenseInvestmentScreenState();
}

class _ExpenseInvestmentScreenState extends State<ExpenseInvestmentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Expense Form Controllers
  final TextEditingController _expenseDateController = TextEditingController();
  final TextEditingController _expenseAmountController = TextEditingController();
  final TextEditingController _expenseDescriptionController = TextEditingController();
  final TextEditingController _expenseCategoryController = TextEditingController();

  List<Expense> _expenses = [];

  // Investment Form Controllers
  final TextEditingController _investmentDateController = TextEditingController();
  final TextEditingController _investmentAmountController = TextEditingController();
  final TextEditingController _investmentDescriptionController = TextEditingController();

  Party? _selectedInvestor;
  List<Party> _investors = [];
  List<Investment> _investments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
    _tabController.addListener(_handleTabSelection); // Listen for tab changes
    _expenseDateController.text = DateTime.now().toIso8601String().split('T')[0];
    _investmentDateController.text = DateTime.now().toIso8601String().split('T')[0];

    _loadData();
  }

  @override
  void didUpdateWidget(covariant ExpenseInvestmentScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeSeason.seasonId != oldWidget.activeSeason.seasonId) {
      _loadData(); // Reload if active season changes
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _expenseDateController.dispose();
    _expenseAmountController.dispose();
    _expenseDescriptionController.dispose();
    _expenseCategoryController.dispose();
    _investmentDateController.dispose();
    _investmentAmountController.dispose();
    _investmentDescriptionController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      // Potentially reload data if needed based on tab, or clear forms
      _clearExpenseForm();
      _clearInvestmentForm();
      // _loadData(); // Could call this, but probably not necessary on tab switch
    }
  }

  Future<void> _loadData() async {
    // Load expenses and investments for the current active season
    final expenses = await widget.dbHelper.getExpenses(seasonId: widget.activeSeason.seasonId);
    final investments = await widget.dbHelper.getInvestments(seasonId: widget.activeSeason.seasonId);

    // Load investors for the dropdown
    final allParties = await widget.dbHelper.getParties();
    final investors = allParties.where((p) => p.type == 'Investor').toList();

    setState(() {
      _expenses = expenses;
      _investments = investments;
      _investors = investors;
      _selectedInvestor = _investors.isNotEmpty ? _investors.first : null; // Auto-select first investor if available
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

  Future<void> _recordExpense() async {
    final localizations = AppLocalizations.of(context);
    if (_expenseDateController.text.isEmpty ||
        _expenseAmountController.text.isEmpty ||
        _expenseDescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required expense fields.')), // Localize
      );
      return;
    }

    final amount = double.tryParse(_expenseAmountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid positive amount for expense.')), // Localize
      );
      return;
    }

    final newExpense = Expense(
      seasonId: widget.activeSeason.seasonId!,
      date: DateTime.parse(_expenseDateController.text),
      amount: amount,
      description: _expenseDescriptionController.text,
      category: _expenseCategoryController.text.isEmpty ? '' : _expenseCategoryController.text,
    );

    try {
      await widget.dbHelper.insertExpense(newExpense);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Expense recorded successfully!')), // Localize
      );
      _clearExpenseForm();
      _loadData(); // Refresh list and dashboard on return
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error recording expense: $e')), // Localize
      );
    }
  }

  void _clearExpenseForm() {
    _expenseDateController.text = DateTime.now().toIso8601String().split('T')[0];
    _expenseAmountController.clear();
    _expenseDescriptionController.clear();
    _expenseCategoryController.clear();
  }

  Future<void> _recordInvestment() async {
    final localizations = AppLocalizations.of(context);
    if (_investmentDateController.text.isEmpty ||
        _investmentAmountController.text.isEmpty ||
        _selectedInvestor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an investor and fill all required investment fields.')), // Localize
      );
      return;
    }

    final amount = double.tryParse(_investmentAmountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid positive amount for investment.')), // Localize
      );
      return;
    }

    final newInvestment = Investment(
      seasonId: widget.activeSeason.seasonId!,
      investorId: _selectedInvestor!.partyId!,
      date: DateTime.parse(_investmentDateController.text),
      amount: amount,
      notes: _investmentDescriptionController.text.isEmpty ? null : _investmentDescriptionController.text,
    );

    try {
      await widget.dbHelper.insertInvestment(newInvestment);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Investment recorded successfully!')), // Localize
      );
      _clearInvestmentForm();
      _loadData(); // Refresh list and dashboard on return
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error recording investment: $e')), // Localize
      );
    }
  }

  void _clearInvestmentForm() {
    _investmentDateController.text = DateTime.now().toIso8601String().split('T')[0];
    _investmentAmountController.clear();
    _investmentDescriptionController.clear();
    setState(() {
      _selectedInvestor = _investors.isNotEmpty ? _investors.first : null;
    });
  }

  // --- DELETE FUNCTIONALITY ---
  Future<void> _deleteExpense(int expenseId) async {
    final localizations = AppLocalizations.of(context);
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.deleteButton),
          content: Text(localizations.confirmDeleteExpense), // Localize
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
      await widget.dbHelper.deleteExpense(expenseId);
      _loadData(); // Refresh list
    }
  }

  Future<void> _deleteInvestment(int investmentId) async {
    final localizations = AppLocalizations.of(context);
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.deleteButton),
          content: Text(localizations.confirmDeleteInvestment), // Localize
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
      await widget.dbHelper.deleteInvestment(investmentId);
      _loadData(); // Refresh list
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTabIndex,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.expensesInvestmentsTitle),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: localizations.addExpenseButton),
              Tab(text: localizations.addInvestmentButton),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Expense Tab Content
            Column(
              children: [
                Expanded(
                  flex: 3, // Form takes 3 parts
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _expenseDateController,
                          decoration: InputDecoration(
                            labelText: localizations.dateLabel,
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          onTap: () => _selectDate(_expenseDateController),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _expenseAmountController,
                          decoration: InputDecoration(
                            labelText: localizations.amountLabel,
                            prefixText: '৳ ',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _expenseDescriptionController,
                          decoration: InputDecoration(
                            labelText: localizations.descriptionLabel,
                            hintText: localizations.expenseDescriptionHint,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _expenseCategoryController,
                          decoration: InputDecoration(
                            labelText: localizations.categoryLabel,
                            hintText: localizations.expenseCategoryHint,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _recordExpense,
                          child: Text(localizations.recordExpense),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                // List of Expenses
                Expanded(
                  flex: 2, // List takes 2 parts
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          localizations.recentExpenses,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      _expenses.isEmpty
                          ? Center(child: Text(localizations.noExpensesFound))
                          : Expanded(
                        child: ListView.builder(
                          itemCount: _expenses.length,
                          itemBuilder: (context, index) {
                            final expense = _expenses[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              elevation: 1,
                              child: ListTile(
                                title: Text(expense.description!),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${localizations.dateLabel} ${expense.date.toIso8601String().split('T')[0]}'),
                                    if (expense.category.isNotEmpty)
                                      Text('${localizations.categoryLabel}: ${expense.category}'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '৳ ${expense.amount.toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteExpense(expense.expenseId!),
                                      tooltip: localizations.deleteButton,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Investment Tab Content
            Column(
              children: [
                Expanded(
                  flex: 3, // Form takes 3 parts
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _investmentDateController,
                          decoration: InputDecoration(
                            labelText: localizations.dateLabel,
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          onTap: () => _selectDate(_investmentDateController),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<Party>(
                          value: _selectedInvestor,
                          hint: Text(localizations.investorLabel),
                          decoration: InputDecoration(
                            labelText: localizations.investorLabel,
                          ),
                          items: _investors.map((party) {
                            return DropdownMenuItem(
                              value: party,
                              child: Text(party.name),
                            );
                          }).toList(),
                          onChanged: (Party? newValue) {
                            setState(() {
                              _selectedInvestor = newValue;
                            });
                          },
                          validator: (value) => value == null ? 'Please select an investor.' : null, // Localize
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _investmentAmountController,
                          decoration: InputDecoration(
                            labelText: localizations.amountLabel,
                            prefixText: '৳ ',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _investmentDescriptionController,
                          decoration: InputDecoration(
                            labelText: localizations.descriptionLabel,
                            hintText: localizations.investmentDescriptionHint,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _recordInvestment,
                          child: Text(localizations.recordInvestment),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                // List of Investments
                Expanded(
                  flex: 2, // List takes 2 parts
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          localizations.recentInvestments,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      _investments.isEmpty
                          ? Center(child: Text(localizations.noInvestmentsFound))
                          : Expanded(
                        child: ListView.builder(
                          itemCount: _investments.length,
                          itemBuilder: (context, index) {
                            final investment = _investments[index];
                            // Find investor name for display
                            final investorName = _investors.firstWhere(
                                  (party) => party.partyId == investment.investorId,
                              orElse: () => Party(name: 'Unknown Investor', code: '', type: ''), // Fallback
                            ).name;

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              elevation: 1,
                              child: ListTile(
                                title: Text('$investorName - ${investment.notes ?? ''}'),
                                subtitle: Text('${localizations.dateLabel} ${investment.date.toIso8601String().split('T')[0]}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '৳ ${investment.amount.toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteInvestment(investment.investmentId!),
                                      tooltip: localizations.deleteButton,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
