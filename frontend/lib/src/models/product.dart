class Product {
  final String id;
  final String name;
  final String category;
  final String imagePath;
  final String unitType;
  final double purchasePrice;
  final double sellingPrice;
  final bool isActive;
  final int lowStockLimit;
  final double taxRate;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.imagePath,
    required this.unitType,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.isActive,
    required this.lowStockLimit,
    required this.taxRate,
  });

  factory Product.fromMap(Map<String, Object?> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      imagePath: map['image_path'] as String,
      unitType: map['unit_type'] as String,
      purchasePrice: (map['purchase_price'] as num).toDouble(),
      sellingPrice: (map['selling_price'] as num).toDouble(),
      isActive: (map['is_active'] as int) == 1,
      lowStockLimit: map['low_stock_limit'] as int,
      taxRate: (map['tax_rate'] as num).toDouble(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'image_path': imagePath,
      'unit_type': unitType,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'is_active': isActive ? 1 : 0,
      'low_stock_limit': lowStockLimit,
      'tax_rate': taxRate,
    };
  }
}
