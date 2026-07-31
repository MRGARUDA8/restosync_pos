import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../models/product.dart';
import '../models/product_variant.dart';
import '../services/local_database.dart';

class CartItem {
  final Product product;
  final ProductVariant variant;
  final double quantity;

  CartItem({
    required this.product,
    required this.variant,
    required this.quantity,
  });

  double get lineTotal => variant.price * quantity;
}

class OrderProvider extends ChangeNotifier {
  final LocalDatabaseService _databaseService = LocalDatabaseService.instance;
  final _uuid = const Uuid();
  final List<CartItem> _cart = [];

  List<CartItem> get cartItems => List.unmodifiable(_cart);

  void addToCart(Product product, ProductVariant variant, double quantity) {
    final existingIndex = _cart.indexWhere((item) => item.product.id == product.id && item.variant.id == variant.id);
    if (existingIndex >= 0) {
      final existing = _cart[existingIndex];
      _cart[existingIndex] = CartItem(product: existing.product, variant: existing.variant, quantity: existing.quantity + quantity);
    } else {
      _cart.add(CartItem(product: product, variant: variant, quantity: quantity));
    }
    notifyListeners();
  }

  void removeFromCart(String variantId) {
    _cart.removeWhere((item) => item.variant.id == variantId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  double get subtotal => _cart.fold(0.0, (sum, item) => sum + item.lineTotal);

  double calculateTax(double rate) => subtotal * rate / 100;

  double calculateGrandTotal(double tax, double discount) => subtotal + tax - discount;

  Future<String> createInvoice({
    required String customerId,
    required PaymentMethod paymentMethod,
    required OrderType orderType,
    required String userId,
    double discount = 0,
    String deliveryAddress = '',
    String deliveryFee = '0',
    String riderName = '',
    String deliveryStatus = 'Pending',
  }) async {
    final invoiceNumber = await _databaseService.generateInvoiceNumber();
    final tax = calculateTax(5);
    final grandTotal = calculateGrandTotal(tax, discount);
    final invoice = Invoice(
      id: _uuid.v4(),
      invoiceNumber: invoiceNumber,
      timestamp: DateTime.now(),
      customerId: customerId,
      subtotal: subtotal,
      tax: tax,
      discount: discount,
      grandTotal: grandTotal,
      paymentMethod: paymentMethod,
      orderType: orderType,
      status: InvoiceStatus.completed,
      userId: userId,
      deliveryAddress: deliveryAddress,
      deliveryFee: deliveryFee,
      riderName: riderName,
      deliveryStatus: deliveryStatus,
    );
    final items = _cart.map((item) {
      return InvoiceItem(
        id: _uuid.v4(),
        invoiceId: invoice.id,
        productId: item.product.id,
        variantId: item.variant.id,
        quantity: item.quantity,
        unitPrice: item.variant.price,
        totalPrice: item.lineTotal,
        unit: item.product.unitType,
      );
    }).toList();
    await _databaseService.insertInvoice(invoice, items);
    clearCart();
    return invoiceNumber;
  }
}
