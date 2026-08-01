import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../api_constants.dart';
import 'local_database.dart';

class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();
  final LocalDatabaseService _db = LocalDatabaseService.instance;

  Future<void> syncPending() async {
    final pending = await _db.fetchPendingSyncEntries();
    for (final row in pending) {
      try {
        final id = row['id'] as String;
        final payloadStr = row['payload'] as String;
        // Try to parse payload if possible; otherwise send as-is
        dynamic payload;
        try {
          payload = jsonDecode(payloadStr);
        } catch (_) {
          payload = {'raw': payloadStr};
        }

        final type = row['type'] as String;
        String endpoint = ApiConstants.syncData;
        if (type == 'expense') endpoint = ApiConstants.expenses;

        final response = await http.post(Uri.parse(endpoint), headers: {'Content-Type': 'application/json'}, body: jsonEncode(payload));
        if (response.statusCode >= 200 && response.statusCode < 300) {
          await _db.updateSyncEntryStatus(id, 'synced');
        } else {
          await _db.updateSyncEntryStatus(id, 'failed');
        }
      } catch (e) {
        // If anything goes wrong, mark failed so it can be retried later
        try {
          final id = row['id'] as String;
          await _db.updateSyncEntryStatus(id, 'failed');
        } catch (_) {}
      }
    }
  }
}
