class ProductVariant {
  final String id;
  final String productId;
  final String sizeName;
  final double price;
  final double weightVolume;
  final bool isAvailable;

  ProductVariant({
    required this.id,
    required this.productId,
    required this.sizeName,
    required this.price,
    required this.weightVolume,
    required this.isAvailable,
  });

  factory ProductVariant.fromMap(Map<String, Object?> map) {
    return ProductVariant(
      id: map['id'] as String,
      productId: map['product_id'] as String,
      sizeName: map['size_name'] as String,
      price: (map['price'] as num).toDouble(),
      weightVolume: (map['weight_volume'] as num).toDouble(),
      isAvailable: (map['is_available'] as int) == 1,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'size_name': sizeName,
      'price': price,
      'weight_volume': weightVolume,
      'is_available': isAvailable ? 1 : 0,
    };
  }
}
