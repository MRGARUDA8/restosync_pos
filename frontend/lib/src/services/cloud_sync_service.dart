import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/invoice.dart';
import '../utils/constants.dart';

class CloudSyncService {
  CloudSyncService._();
  static final CloudSyncService instance = CloudSyncService._();

  Future<bool> syncInvoice(Invoice invoice) async {
    // Retry a few times to allow the Render free-tier instance to wake up
    const maxRetries = 4;
    var attempt = 0;
    while (attempt < maxRetries) {
      try {
        final response = await http.post(
          Uri.parse('${AppConstants.apiBaseUrl}/sync/invoices'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(invoice.toMap()),
        );
        if (response.statusCode == 200) return true;
        // if not 200, treat as failure and retry
      } catch (_) {
        // ignore and retry after delay
      }
      attempt += 1;
      await Future.delayed(Duration(seconds: 2 * attempt));
    }
    return false;
  }

  Future<bool> forceSync() async {
    const maxRetries = 4;
    var attempt = 0;
    while (attempt < maxRetries) {
      try {
        final response = await http.get(Uri.parse('${AppConstants.apiBaseUrl}/sync/status'));
        if (response.statusCode == 200) return true;
      } catch (_) {}
      attempt += 1;
      await Future.delayed(Duration(seconds: 2 * attempt));
    }
    return false;
  }
}
