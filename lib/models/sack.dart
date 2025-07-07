class Sack {
  int? sackId;
  String uniqueSackIdentifier; // e.g., "FARM001-Boro25-001"
  // int productId;
  final String productType;
  int purchaseSeasonId;
  DateTime purchaseDate;
  int purchaseVendorId;
  double purchaseWeightKg;
  double purchasePricePerKg;
  double purchaseCarryingCost;
  int currentLocationId;

  DateTime? saleDate;
  int? saleCustomerId;
  double? saleWeightKg;
  double? salePricePerKg;
  double? saleCarryingCost;
  String status; // "In Stock", "Sold", "Discarded"
  int seasonId;

  Sack({
    this.sackId,
    required this.uniqueSackIdentifier,
    // required this.productId,
    required this.productType,
    required this.purchaseSeasonId,
    required this.purchaseDate,
    required this.purchaseVendorId,
    required this.purchaseWeightKg,
    required this.purchasePricePerKg,
    this.purchaseCarryingCost = 0.0,
    required this.currentLocationId,
    this.saleDate,
    this.saleCustomerId,
    this.saleWeightKg,
    this.salePricePerKg,
    this.saleCarryingCost = 0.0,
    this.status = 'In Stock',
    required this.seasonId,
  });

  double get netProfitLoss {
    if (status != 'Sold') return 0.0; // Profit/Loss is only relevant for sold sacks

    final effectivePurchaseCost = (purchaseWeightKg * purchasePricePerKg) + (purchaseCarryingCost ?? 0.0);
    final effectiveSaleRevenue = (saleWeightKg ?? 0.0) * (salePricePerKg ?? 0.0);
    final effectiveSaleCost = (saleCarryingCost ?? 0.0);

    return effectiveSaleRevenue - effectiveSaleCost - effectivePurchaseCost;
  }

  // Convert a Sack object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'sackId': sackId,
      'uniqueSackIdentifier': uniqueSackIdentifier,
      // 'productId': productId,
      'productType': productType,
      'purchaseSeasonId': purchaseSeasonId,
      'purchaseDate': purchaseDate.toIso8601String(),
      'purchaseVendorId': purchaseVendorId,
      'purchaseWeightKg': purchaseWeightKg,
      'purchasePricePerKg': purchasePricePerKg,
      'purchaseCarryingCost': purchaseCarryingCost,
      'currentLocationId': currentLocationId,
      'saleDate': saleDate?.toIso8601String(),
      'saleCustomerId': saleCustomerId,
      'saleWeightKg': saleWeightKg,
      'salePricePerKg': salePricePerKg,
      'saleCarryingCost': saleCarryingCost,
      'status': status,
      'seasonId': seasonId,
    };
  }

  // Extract a Sack object from a Map object
  factory Sack.fromMap(Map<String, dynamic> map) {
    return Sack(
      sackId: map['sackId'],
      uniqueSackIdentifier: map['uniqueSackIdentifier'],
      // productId: map['productId'],
      productType: map['productType'],
      purchaseSeasonId: map['purchaseSeasonId'],
      purchaseDate: DateTime.parse(map['purchaseDate']),
      purchaseVendorId: map['purchaseVendorId'],
      purchaseWeightKg: map['purchaseWeightKg'],
      purchasePricePerKg: map['purchasePricePerKg'],
      purchaseCarryingCost: map['purchaseCarryingCost'],
      currentLocationId: map['currentLocationId'],
      saleDate: map['saleDate'] != null ? DateTime.parse(map['saleDate']) : null,
      saleCustomerId: map['saleCustomerId'],
      saleWeightKg: map['saleWeightKg'],
      salePricePerKg: map['salePricePerKg'],
      saleCarryingCost: map['saleCarryingCost'],
      status: map['status'],
      seasonId: map['seasonId'],
    );
  }

  Sack copyWith({
    int? sackId,
    int? seasonId,
    String? productType,
    String? uniqueSackIdentifier,
    DateTime? purchaseDate,
    double? purchaseWeightKg,
    double? purchasePricePerKg,
    double? purchaseCarryingCost,
    int? purchaseVendorId,
    int? currentLocationId,
    String? status,
    DateTime? saleDate,
    double? saleWeightKg,
    double? salePricePerKg,
    double? saleCarryingCost,
    int? saleCustomerId,
  }) {
    return Sack(
      sackId: sackId ?? this.sackId,
      seasonId: seasonId ?? this.seasonId,
      productType: productType ?? this.productType, // Changed this
      uniqueSackIdentifier: uniqueSackIdentifier ?? this.uniqueSackIdentifier,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchaseWeightKg: purchaseWeightKg ?? this.purchaseWeightKg,
      purchasePricePerKg: purchasePricePerKg ?? this.purchasePricePerKg,
      purchaseCarryingCost: purchaseCarryingCost ?? this.purchaseCarryingCost,
      purchaseVendorId: purchaseVendorId ?? this.purchaseVendorId,
      currentLocationId: currentLocationId ?? this.currentLocationId,
      status: status ?? this.status,
      saleDate: saleDate ?? this.saleDate,
      saleWeightKg: saleWeightKg ?? this.saleWeightKg,
      salePricePerKg: salePricePerKg ?? this.salePricePerKg,
      saleCarryingCost: saleCarryingCost ?? this.saleCarryingCost,
      saleCustomerId: saleCustomerId ?? this.saleCustomerId,
      purchaseSeasonId: seasonId ?? this.seasonId,
    );
  }
}
