class ProductModel {
  final String id;
  final String name;
  final double price;
  final double gstRate;
  final bool isAvailable;
  final bool isVeg;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.gstRate,
    required this.isAvailable,
    required this.isVeg,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      gstRate: (json['gstRate'] ?? 5).toDouble(),
      isAvailable: json['isAvailable'] ?? true,
      isVeg: json['isVeg'] ?? true,
    );
  }
}
