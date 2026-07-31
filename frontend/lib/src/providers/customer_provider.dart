import 'package:flutter/foundation.dart';

import '../models/customer.dart';
import '../services/local_database.dart';

class CustomerProvider extends ChangeNotifier {
  final LocalDatabaseService _databaseService = LocalDatabaseService.instance;
  List<Customer> _customers = [];
  bool _isLoading = false;

  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;

  Future<void> loadCustomers() async {
    _isLoading = true;
    notifyListeners();
    _customers = await _databaseService.fetchCustomers();
    _isLoading = false;
    notifyListeners();
  }
}
