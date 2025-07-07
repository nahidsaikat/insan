class Party {
  int? partyId;
  String name;
  String code; // Added code
  String type; // "Investor", "Farmer", "Chathal", "Other Stoker", "Customer"
  String? phone;
  String? email;
  String? address;
  String? notes;

  Party({
    this.partyId,
    required this.name,
    required this.code, // Required for constructor
    required this.type,
    this.phone,
    this.email,
    this.address,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'partyId': partyId,
      'name': name,
      'code': code, // Added to map
      'type': type,
      'phone': phone,
      'email': email,
      'address': address,
      'notes': notes,
    };
  }

  factory Party.fromMap(Map<String, dynamic> map) {
    return Party(
      partyId: map['partyId'],
      name: map['name'],
      code: map['code'], // Added from map
      type: map['type'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      notes: map['notes'],
    );
  }
}
