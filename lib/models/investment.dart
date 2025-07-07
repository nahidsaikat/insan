class Investment {
  int? investmentId;
  int investorId;
  int seasonId;
  DateTime date;
  double amount;
  String? notes;

  Investment({
    this.investmentId,
    required this.investorId,
    required this.seasonId,
    required this.date,
    required this.amount,
    this.notes,
  });

  // Convert an Investment object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'investmentId': investmentId,
      'investorId': investorId,
      'seasonId': seasonId,
      'date': date.toIso8601String(),
      'amount': amount,
      'notes': notes,
    };
  }

  // Extract an Investment object from a Map object
  factory Investment.fromMap(Map<String, dynamic> map) {
    return Investment(
      investmentId: map['investmentId'],
      investorId: map['investorId'],
      seasonId: map['seasonId'],
      date: DateTime.parse(map['date']),
      amount: map['amount'],
      notes: map['notes'],
    );
  }
}
