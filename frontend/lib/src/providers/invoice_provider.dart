import 'package:flutter/foundation.dart';

import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../services/local_database.dart';

class InvoiceProvider extends ChangeNotifier {
  final LocalDatabaseService _databaseService = LocalDatabaseService.instance;
  List<Invoice> _invoices = [];
  List<InvoiceItem> _invoiceItems = [];
  bool _isLoading = false;

  List<Invoice> get invoices => _invoices;
  List<InvoiceItem> get invoiceItems => _invoiceItems;
  bool get isLoading => _isLoading;

  Future<void> loadInvoices() async {
    _isLoading = true;
    notifyListeners();
    try {
      _invoices = await _databaseService.fetchInvoices();
    } catch (e, st) {
      // Log and recover so UI doesn't hang on perpetual loading
      if (kDebugMode) {
        print('Error loading invoices: $e');
        print(st);
      }
      _invoices = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadInvoiceItems(String invoiceId) async {
    try {
      _invoiceItems = await _databaseService.fetchInvoiceItems(invoiceId);
    } catch (e, st) {
      if (kDebugMode) {
        print('Error loading invoice items for $invoiceId: $e');
        print(st);
      }
      _invoiceItems = [];
    }
    notifyListeners();
  }

  Future<void> cancelInvoice(String invoiceId, String reason, bool restock, String userId) async {
    await _databaseService.cancelInvoice(invoiceId, reason, restock, userId);
    await loadInvoices();
  }

  Future<void> refundInvoice(String invoiceId, String reason, bool restock, String userId) async {
    await _databaseService.refundInvoice(invoiceId, reason, restock, userId);
    await loadInvoices();
  }
}
