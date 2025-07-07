class Product {
  int? productId;
  String name;
  String unit;

  Product({
    this.productId,
    required this.name,
    required this.unit,
  });

  // Convert a Product object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'unit': unit,
    };
  }

  // Extract a Product object from a Map object
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      productId: map['productId'],
      name: map['name'],
      unit: map['unit'],
    );
  }
}
