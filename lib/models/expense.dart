class Expense {
  int? expenseId;
  int seasonId;
  DateTime date;
  String category;
  String? description;
  double amount;

  Expense({
    this.expenseId,
    required this.seasonId,
    required this.date,
    required this.category,
    this.description,
    required this.amount,
  });

  // Convert an Expense object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'expenseId': expenseId,
      'seasonId': seasonId,
      'date': date.toIso8601String(),
      'category': category,
      'description': description,
      'amount': amount,
    };
  }

  // Extract an Expense object from a Map object
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      expenseId: map['expenseId'],
      seasonId: map['seasonId'],
      date: DateTime.parse(map['date']),
      category: map['category'],
      description: map['description'],
      amount: map['amount'],
    );
  }
}