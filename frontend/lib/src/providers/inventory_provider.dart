import 'package:flutter/foundation.dart';

import '../models/ingredient.dart';
import '../services/local_database.dart';

class InventoryProvider extends ChangeNotifier {
  final LocalDatabaseService _databaseService = LocalDatabaseService.instance;
  List<Ingredient> _ingredients = [];
  bool _isLoading = false;

  List<Ingredient> get ingredients => _ingredients;
  bool get isLoading => _isLoading;

  Future<void> loadInventory() async {
    _isLoading = true;
    notifyListeners();
    _ingredients = await _databaseService.fetchIngredients();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> adjustStock(String ingredientId, double newStock) async {
    await _databaseService.updateIngredientStock(ingredientId, newStock);
    await loadInventory();
  }
}
