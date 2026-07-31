import 'package:flutter/foundation.dart';

import '../services/local_database.dart';

class ReportProvider extends ChangeNotifier {
  final LocalDatabaseService _databaseService = LocalDatabaseService.instance;
  double _totalSales = 0;
  double _totalExpenses = 0;

  double get totalSales => _totalSales;
  double get totalExpenses => _totalExpenses;

  Future<void> loadDashboardMetrics() async {
    final rows = await _databaseService.queryDashboardMetrics();
    if (rows.isNotEmpty) {
      _totalSales = (rows.first['totalSales'] as num).toDouble();
      _totalExpenses = (rows.first['totalExpenses'] as num).toDouble();
    }
    notifyListeners();
  }
}
