class InvoiceItem {
  final String id;
  final String invoiceId;
  final String productId;
  final String variantId;
  final double quantity;
  final double unitPrice;
  final double totalPrice;
  final String unit;

  InvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.productId,
    required this.variantId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.unit,
  });

  factory InvoiceItem.fromMap(Map<String, Object?> map) {
    return InvoiceItem(
      id: map['id'] as String,
      invoiceId: map['invoice_id'] as String,
      productId: map['product_id'] as String,
      variantId: map['variant_id'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      unitPrice: (map['unit_price'] as num).toDouble(),
      totalPrice: (map['total_price'] as num).toDouble(),
      unit: map['unit'] as String,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'product_id': productId,
      'variant_id': variantId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'unit': unit,
    };
  }
}
