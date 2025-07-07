class InventoryLocation {
  int? locationId;
  String name;
  String? address;
  double? rentCostPerMonth;
  String? notes;

  InventoryLocation({
    this.locationId,
    required this.name,
    this.address,
    this.rentCostPerMonth,
    this.notes,
  });

  // Convert an InventoryLocation object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'locationId': locationId,
      'name': name,
      'address': address,
      'rentCostPerMonth': rentCostPerMonth,
      'notes': notes,
    };
  }

  // Extract an InventoryLocation object from a Map object
  factory InventoryLocation.fromMap(Map<String, dynamic> map) {
    return InventoryLocation(
      locationId: map['locationId'],
      name: map['name'],
      address: map['address'],
      rentCostPerMonth: map['rentCostPerMonth'],
      notes: map['notes'],
    );
  }
}
