import 'package:flutter/foundation.dart';

import '../models/product.dart';
import 'package:uuid/uuid.dart';
import '../models/product_variant.dart';
import '../services/local_database.dart';
import '../models/audit_log.dart';

class ProductProvider extends ChangeNotifier {
  final LocalDatabaseService _databaseService = LocalDatabaseService.instance;
  List<Product> _products = [];
  List<ProductVariant> _variants = [];
  bool _isLoading = false;
  List<Map<String, Object?>> _productCategories = [];

  List<Product> get products => _products;
  List<ProductVariant> get variants => _variants;
  bool get isLoading => _isLoading;
  List<Map<String, Object?>> get productCategories => _productCategories;

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();
    _products = await _databaseService.fetchProducts();
    _productCategories = await _databaseService.fetchProductCategories();
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

  Future<void> addCategory(String name, {String userId = 'system'}) async {
    final id = const Uuid().v4();
    await _databaseService.insertProductCategory(id, name);

    // Audit log
    await _databaseService.insertAuditLog(AuditLog(
      id: const Uuid().v4(),
      userId: userId,
      action: 'Product Category Created $id',
      reason: name,
      timestamp: DateTime.now(),
    ));

    // Enqueue sync for backend
    await _databaseService.enqueueSync({'id': id, 'name': name}, 'product_category_create');

    await loadProducts();
  }

  Future<void> addProduct(String name, String category, double price, {Map<String,double>? sizes, String imagePath = '', String userId = 'system'}) async {
    final pid = const Uuid().v4();
    final product = Product(
      id: pid,
      name: name,
      category: category,
      imagePath: imagePath,
      unitType: 'Pc',
      purchasePrice: 0,
      sellingPrice: price,
      isActive: true,
      lowStockLimit: 0,
      taxRate: 5,
    );
    await _databaseService.insertProduct(product);

    final variantsInserted = <Map<String, dynamic>>[];
    if (sizes != null && sizes.isNotEmpty) {
      for (final entry in sizes.entries) {
        final vid = const Uuid().v4();
        final variant = ProductVariant(id: vid, productId: pid, sizeName: entry.key, price: entry.value, weightVolume: 0, isAvailable: true);
        await _databaseService.insertProductVariant(variant);
        variantsInserted.add({'id': vid, 'size_name': entry.key, 'price': entry.value});
      }
    } else {
      final vid = const Uuid().v4();
      final variant = ProductVariant(id: vid, productId: pid, sizeName: 'Standard', price: price, weightVolume: 0, isAvailable: true);
      await _databaseService.insertProductVariant(variant);
      variantsInserted.add({'id': vid, 'size_name': 'Standard', 'price': price});
    }

    // Audit log
    await _databaseService.insertAuditLog(AuditLog(
      id: const Uuid().v4(),
      userId: userId,
      action: 'Product Created $pid',
      reason: name,
      timestamp: DateTime.now(),
    ));

    // Enqueue sync payload for backend
    final payload = {
      'product': product.toMap(),
      'variants': variantsInserted,
    };
    await _databaseService.enqueueSync(payload, 'product_create');

    await loadProducts();
  }
}
