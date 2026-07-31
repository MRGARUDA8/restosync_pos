import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/invoice.dart';
import '../utils/constants.dart';

class CloudSyncService {
  CloudSyncService._();
  static final CloudSyncService instance = CloudSyncService._();

  Future<bool> syncInvoice(Invoice invoice) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/sync/invoices'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(invoice.toMap()),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> forceSync() async {
    try {
      final response = await http.get(Uri.parse('${AppConstants.apiBaseUrl}/sync/status'));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
