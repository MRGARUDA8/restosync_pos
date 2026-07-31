import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/audit_log.dart';
import '../models/customer.dart';
import '../models/expense.dart';
import '../models/ingredient.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../models/product.dart';
import '../models/product_variant.dart';
import '../models/recipe.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class LocalDatabaseService {
  LocalDatabaseService._();
  static final LocalDatabaseService instance = LocalDatabaseService._();
  Database? _database;
  final _uuid = const Uuid();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final dbPath = join(directory.path, AppConstants.databaseFileName);
    return openDatabase(dbPath, version: 1, onCreate: _createSchema);
  }

  Future<void> _createSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        role TEXT NOT NULL,
        pin TEXT NOT NULL,
        permissions TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        image_path TEXT NOT NULL,
        unit_type TEXT NOT NULL,
        purchase_price REAL NOT NULL,
        selling_price REAL NOT NULL,
        is_active INTEGER NOT NULL,
        low_stock_limit INTEGER NOT NULL,
        tax_rate REAL NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE product_variants (
        id TEXT PRIMARY KEY,
        product_id TEXT NOT NULL,
        size_name TEXT NOT NULL,
        price REAL NOT NULL,
        weight_volume REAL NOT NULL,
        is_available INTEGER NOT NULL,
        FOREIGN KEY(product_id) REFERENCES products(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE ingredients (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        current_stock REAL NOT NULL,
        unit TEXT NOT NULL,
        cost_per_unit REAL NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE recipes (
        id TEXT PRIMARY KEY,
        variant_id TEXT NOT NULL,
        ingredient_id TEXT NOT NULL,
        quantity_required REAL NOT NULL,
        FOREIGN KEY(variant_id) REFERENCES product_variants(id),
        FOREIGN KEY(ingredient_id) REFERENCES ingredients(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE invoices (
        id TEXT PRIMARY KEY,
        invoice_number TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        customer_id TEXT,
        subtotal REAL NOT NULL,
        tax REAL NOT NULL,
        discount REAL NOT NULL,
        grand_total REAL NOT NULL,
        payment_method TEXT NOT NULL,
        order_type TEXT NOT NULL,
        status TEXT NOT NULL,
        user_id TEXT NOT NULL,
        delivery_address TEXT,
        delivery_fee TEXT,
        rider_name TEXT,
        delivery_status TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE invoice_items (
        id TEXT PRIMARY KEY,
        invoice_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        variant_id TEXT,
        quantity REAL NOT NULL,
        unit_price REAL NOT NULL,
        total_price REAL NOT NULL,
        unit TEXT NOT NULL,
        FOREIGN KEY(invoice_id) REFERENCES invoices(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        user_id TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        mobile TEXT NOT NULL,
        total_orders INTEGER NOT NULL,
        total_spent REAL NOT NULL,
        loyalty_points INTEGER NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE audit_logs (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        action TEXT NOT NULL,
        reason TEXT,
        timestamp TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE sync_queue (
        id TEXT PRIMARY KEY,
        payload TEXT NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL
      );
    ''');

    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    final users = [
      User(id: _uuid.v4(), name: 'Admin', role: UserRole.admin, pin: '1234', permissions: ['all']),
      User(id: _uuid.v4(), name: 'Manager', role: UserRole.manager, pin: '4321', permissions: ['inventory', 'reports', 'expenses']),
      User(id: _uuid.v4(), name: 'Cashier', role: UserRole.cashier, pin: '1111', permissions: ['billing', 'customers']),
      User(id: _uuid.v4(), name: 'Kitchen', role: UserRole.kitchen, pin: '2222', permissions: ['kds']),
    ];

    for (final user in users) {
      await db.insert('users', user.toMap());
    }

    final products = [
      Product(
        id: _uuid.v4(),
        name: 'Margherita Pizza',
        category: 'Pizza',
        imagePath: '',
        unitType: 'Pc',
        purchasePrice: 90,
        sellingPrice: 149,
        isActive: true,
        lowStockLimit: 10,
        taxRate: 5,
      ),
      Product(
        id: _uuid.v4(),
        name: 'Paneer Tikka Pizza',
        category: 'Pizza',
        imagePath: '',
        unitType: 'Pc',
        purchasePrice: 120,
        sellingPrice: 249,
        isActive: true,
        lowStockLimit: 8,
        taxRate: 5,
      ),
    ];

    for (final product in products) {
      await db.insert('products', product.toMap());
    }

    final variants = <ProductVariant>[];
    for (final product in products) {
      variants.addAll([
        ProductVariant(
          id: _uuid.v4(),
          productId: product.id,
          sizeName: 'Regular',
          price: product.sellingPrice,
          weightVolume: 0,
          isAvailable: true,
        ),
        ProductVariant(
          id: _uuid.v4(),
          productId: product.id,
          sizeName: 'Medium',
          price: product.sellingPrice + 100,
          weightVolume: 0,
          isAvailable: true,
        ),
        ProductVariant(
          id: _uuid.v4(),
          productId: product.id,
          sizeName: 'Large',
          price: product.sellingPrice + 200,
          weightVolume: 0,
          isAvailable: true,
        ),
      ]);
    }

    for (final variant in variants) {
      await db.insert('product_variants', variant.toMap());
    }

    final ingredients = [
      Ingredient(id: _uuid.v4(), name: 'Cheese', currentStock: 25.0, unit: 'kg', costPerUnit: 400),
      Ingredient(id: _uuid.v4(), name: 'Dough', currentStock: 50.0, unit: 'kg', costPerUnit: 25),
      Ingredient(id: _uuid.v4(), name: 'Sauce', currentStock: 20.0, unit: 'kg', costPerUnit: 80),
    ];

    for (final ingredient in ingredients) {
      await db.insert('ingredients', ingredient.toMap());
    }

    final recipes = variants.where((variant) => variant.sizeName == 'Regular').map((variant) {
      return Recipe(
        id: _uuid.v4(),
        variantId: variant.id,
        ingredientId: ingredients[0].id,
        quantityRequired: 0.08,
      );
    }).toList();
    for (final recipe in recipes) {
      await db.insert('recipes', recipe.toMap());
    }
  }

  Future<String> generateInvoiceNumber() async {
    final db = await database;
    final result = await db.rawQuery('SELECT invoice_number FROM invoices ORDER BY timestamp DESC LIMIT 1');
    if (result.isEmpty) {
      return 'INV-0001';
    }
    final last = result.first['invoice_number'] as String;
    final numeric = int.tryParse(last.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return 'INV-${(numeric + 1).toString().padLeft(4, '0')}';
  }

  Future<List<Product>> fetchProducts() async {
    final db = await database;
    final rows = await db.query('products', orderBy: 'name ASC');
    return rows.map((row) => Product.fromMap(row)).toList();
  }

  Future<List<ProductVariant>> fetchVariantsForProduct(String productId) async {
    final db = await database;
    final rows = await db.query('product_variants', where: 'product_id = ?', whereArgs: [productId]);
    return rows.map((row) => ProductVariant.fromMap(row)).toList();
  }

  Future<List<Ingredient>> fetchIngredients() async {
    final db = await database;
    final rows = await db.query('ingredients', orderBy: 'name ASC');
    return rows.map((row) => Ingredient.fromMap(row)).toList();
  }

  Future<List<Expense>> fetchExpenses() async {
    final db = await database;
    final rows = await db.query('expenses', orderBy: 'date DESC');
    return rows.map((row) => Expense.fromMap(row)).toList();
  }

  Future<List<Customer>> fetchCustomers() async {
    final db = await database;
    final rows = await db.query('customers', orderBy: 'name ASC');
    return rows.map((row) => Customer.fromMap(row)).toList();
  }

  Future<void> insertInvoice(Invoice invoice, List<InvoiceItem> items) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert('invoices', invoice.toMap());
      for (final item in items) {
        await txn.insert('invoice_items', item.toMap());
      }
      await _deductRecipeInventory(txn, items);
      if (invoice.customerId.isNotEmpty) {
        await _updateCustomerTotals(txn, invoice.customerId, invoice.grandTotal);
      }
      await txn.insert('audit_logs', AuditLog(
        id: _uuid.v4(),
        userId: invoice.userId,
        action: 'Bill Created ${invoice.invoiceNumber}',
        reason: 'POS sale completed',
        timestamp: DateTime.now(),
      ).toMap());
    });
  }

  Future<void> insertExpense(Expense expense) async {
    final db = await database;
    await db.insert('expenses', expense.toMap());
  }

  Future<void> _deductRecipeInventory(DatabaseExecutor db, List<InvoiceItem> items) async {
    for (final item in items) {
      final recipeRows = await db.query('recipes', where: 'variant_id = ?', whereArgs: [item.variantId]);
      for (final recipeRow in recipeRows) {
        final recipe = Recipe.fromMap(recipeRow);
        final ingredientRows = await db.query('ingredients', where: 'id = ?', whereArgs: [recipe.ingredientId]);
        if (ingredientRows.isEmpty) continue;
        final ingredient = Ingredient.fromMap(ingredientRows.first);
        final newStock = ingredient.currentStock - recipe.quantityRequired * item.quantity;
        await db.update('ingredients', {'current_stock': newStock}, where: 'id = ?', whereArgs: [ingredient.id]);
      }
    }
  }

  Future<void> _restoreRecipeInventory(DatabaseExecutor db, List<InvoiceItem> items) async {
    for (final item in items) {
      final recipeRows = await db.query('recipes', where: 'variant_id = ?', whereArgs: [item.variantId]);
      for (final recipeRow in recipeRows) {
        final recipe = Recipe.fromMap(recipeRow);
        final ingredientRows = await db.query('ingredients', where: 'id = ?', whereArgs: [recipe.ingredientId]);
        if (ingredientRows.isEmpty) continue;
        final ingredient = Ingredient.fromMap(ingredientRows.first);
        final restoredStock = ingredient.currentStock + recipe.quantityRequired * item.quantity;
        await db.update('ingredients', {'current_stock': restoredStock}, where: 'id = ?', whereArgs: [ingredient.id]);
      }
    }
  }

  Future<void> _updateCustomerTotals(DatabaseExecutor db, String customerId, double amount) async {
    final rows = await db.query('customers', where: 'id = ?', whereArgs: [customerId]);
    if (rows.isEmpty) return;
    final customer = Customer.fromMap(rows.first);
    await db.update(
      'customers',
      {
        'total_orders': customer.totalOrders + 1,
        'total_spent': customer.totalSpent + amount,
        'loyalty_points': customer.loyaltyPoints + (amount ~/ 100).toInt(),
      },
      where: 'id = ?',
      whereArgs: [customerId],
    );
  }

  Future<List<Invoice>> fetchInvoices() async {
    final db = await database;
    final rows = await db.query('invoices', orderBy: 'timestamp DESC');
    return rows.map((row) => Invoice.fromMap(row)).toList();
  }

  Future<List<InvoiceItem>> fetchInvoiceItems(String invoiceId) async {
    final db = await database;
    final rows = await db.query('invoice_items', where: 'invoice_id = ?', whereArgs: [invoiceId]);
    return rows.map((row) => InvoiceItem.fromMap(row)).toList();
  }

  Future<void> updateInvoiceStatus(String invoiceId, String status) async {
    final db = await database;
    await db.update('invoices', {'status': status}, where: 'id = ?', whereArgs: [invoiceId]);
  }

  Future<void> refundInvoice(String invoiceId, String reason, bool restock, String userId) async {
    final db = await database;
    final invoiceRows = await db.query('invoices', where: 'id = ?', whereArgs: [invoiceId]);
    if (invoiceRows.isEmpty) return;
    final invoice = Invoice.fromMap(invoiceRows.first);
    final items = await fetchInvoiceItems(invoiceId);
    await db.transaction((txn) async {
      await txn.update('invoices', {'status': InvoiceStatus.refunded.name}, where: 'id = ?', whereArgs: [invoiceId]);
      if (restock) {
        await _restoreRecipeInventory(txn, items);
      }
      await txn.insert('audit_logs', AuditLog(
        id: _uuid.v4(),
        userId: userId,
        action: 'Bill Refunded ${invoice.invoiceNumber}',
        reason: reason,
        timestamp: DateTime.now(),
      ).toMap());
    });
  }

  Future<void> cancelInvoice(String invoiceId, String reason, bool restock, String userId) async {
    final db = await database;
    final invoiceRows = await db.query('invoices', where: 'id = ?', whereArgs: [invoiceId]);
    if (invoiceRows.isEmpty) return;
    final items = await fetchInvoiceItems(invoiceId);
    await db.transaction((txn) async {
      await txn.update('invoices', {'status': InvoiceStatus.cancelled.name}, where: 'id = ?', whereArgs: [invoiceId]);
      if (restock) {
        await _restoreRecipeInventory(txn, items);
      }
      await txn.insert('audit_logs', AuditLog(
        id: _uuid.v4(),
        userId: userId,
        action: 'Bill Cancelled ${invoiceRows.first['invoice_number']}',
        reason: reason,
        timestamp: DateTime.now(),
      ).toMap());
    });
  }

  Future<void> insertAuditLog(AuditLog log) async {
    final db = await database;
    await db.insert('audit_logs', log.toMap());
  }

  Future<void> updateIngredientStock(String ingredientId, double newStock) async {
    final db = await database;
    await db.update('ingredients', {'current_stock': newStock}, where: 'id = ?', whereArgs: [ingredientId]);
  }

  Future<List<Map<String, Object?>>> queryDashboardMetrics() async {
    final db = await database;
    final totalSales = Sqflite.firstIntValue(await db.rawQuery('SELECT SUM(grand_total) FROM invoices WHERE status = ?', ['completed'])) ?? 0;
    final totalExpenses = Sqflite.firstIntValue(await db.rawQuery('SELECT SUM(amount) FROM expenses')) ?? 0;
    return [
      {'totalSales': totalSales, 'totalExpenses': totalExpenses},
    ];
  }
}
