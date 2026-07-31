import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../models/product_variant.dart';
import '../services/local_database.dart';

class ProductProvider extends ChangeNotifier {
  final LocalDatabaseService _databaseService = LocalDatabaseService.instance;
  List<Product> _products = [];
  List<ProductVariant> _variants = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  List<ProductVariant> get variants => _variants;
  bool get isLoading => _isLoading;

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();
    _products = await _databaseService.fetchProducts();
    if (_products.isNotEmpty) {
      _variants = await _databaseService.fetchVariantsForProduct(_products.first.id);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadVariants(String productId) async {
    _variants = await _databaseService.fetchVariantsForProduct(productId);
    notifyListeners();
  }
}
