import 'package:flutter/foundation.dart' as fnd;
import 'package:uuid/uuid.dart';

import '../models/category.dart' as app_model;
import '../services/local_database.dart';

class CategoryProvider extends fnd.ChangeNotifier {
  final LocalDatabaseService _db = LocalDatabaseService.instance;
  final _uuid = const Uuid();

  List<app_model.Category> _incomeCategories = [];
  List<app_model.Category> _expenseCategories = [];
  bool _isLoading = false;

  List<app_model.Category> get incomeCategories => _incomeCategories;
  List<app_model.Category> get expenseCategories => _expenseCategories;
  bool get isLoading => _isLoading;

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();
    final incomeRows = await _db.fetchCategoriesByType('income');
    final expenseRows = await _db.fetchCategoriesByType('expense');
    _incomeCategories = incomeRows.map((r) => app_model.Category.fromMap(r)).toList();
    _expenseCategories = expenseRows.map((r) => app_model.Category.fromMap(r)).toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCategory({required String name, required String type, String? userId}) async {
    final cat = app_model.Category(id: _uuid.v4(), name: name, type: type, createdAt: DateTime.now(), userId: userId);
    await _db.insertCategory(cat.toMap());
    await loadCategories();
  }

  Future<void> updateCategory({required String id, required String name, String? userId}) async {
    final values = {'name': name, 'created_at': DateTime.now().toIso8601String()};
    await _db.updateCategory(id, values, userId: userId);
    await loadCategories();
  }

  Future<void> deleteCategory({required String id, String? userId}) async {
    await _db.deleteCategory(id, userId: userId);
    await loadCategories();
  }
}
