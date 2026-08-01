import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/expense.dart';
import '../services/local_database.dart';
import '../services/sync_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final LocalDatabaseService _databaseService = LocalDatabaseService.instance;
  final _uuid = const Uuid();
  List<Expense> _expenses = [];
  bool _isLoading = false;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;

  Future<void> loadExpenses() async {
    _isLoading = true;
    notifyListeners();
    _expenses = await _databaseService.fetchExpenses();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addExpense({
    required String name,
    required String category,
    required double amount,
    required DateTime date,
    required String notes,
    required String userId,
  }) async {
    final expense = Expense(
      id: _uuid.v4(),
      name: name,
      category: category,
      amount: amount,
      date: date,
      notes: notes,
      userId: userId,
    );
    await _databaseService.insertExpense(expense);
    await loadExpenses();
    // Trigger a background sync attempt
    try {
      await SyncService.instance.syncPending();
    } catch (_) {}
  }
}
