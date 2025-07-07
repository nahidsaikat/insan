class ProfitDistribution {
  int? distributionId;
  int investorId;
  int seasonId;
  DateTime date;
  double amount;
  String? notes;

  ProfitDistribution({
    this.distributionId,
    required this.investorId,
    required this.seasonId,
    required this.date,
    required this.amount,
    this.notes,
  });

  // Convert a ProfitDistribution object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'distributionId': distributionId,
      'investorId': investorId,
      'seasonId': seasonId,
      'date': date.toIso8601String(),
      'amount': amount,
      'notes': notes,
    };
  }

  // Extract a ProfitDistribution object from a Map object
  factory ProfitDistribution.fromMap(Map<String, dynamic> map) {
    return ProfitDistribution(
      distributionId: map['distributionId'],
      investorId: map['investorId'],
      seasonId: map['seasonId'],
      date: DateTime.parse(map['date']),
      amount: map['amount'],
      notes: map['notes'],
    );
  }
}