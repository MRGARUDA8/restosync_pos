import 'package:flutter/foundation.dart';

import '../services/local_database.dart';

class ReceiptSettingsProvider extends ChangeNotifier {
  Map<String, String> _settings = {};
  bool _isLoading = false;

  Map<String, String> get settings => _settings;
  bool get isLoading => _isLoading;

  ReceiptSettingsProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();
    final map = await LocalDatabaseService.instance.fetchReceiptSettings();
    _settings = map;
    _isLoading = false;
    notifyListeners();
  }

  String getString(String key, {String def = ''}) {
    return _settings[key] ?? def;
  }

  bool getBool(String key, {bool def = false}) {
    final v = _settings[key];
    if (v == null) return def;
    return v.toLowerCase() == 'true';
  }

  Future<void> setString(String key, String value) async {
    _settings[key] = value;
    notifyListeners();
    await LocalDatabaseService.instance.upsertReceiptSetting(key, value);
  }

  Future<void> setBool(String key, bool value) async {
    _settings[key] = value ? 'true' : 'false';
    notifyListeners();
    await LocalDatabaseService.instance.upsertReceiptSetting(key, value ? 'true' : 'false');
  }

  Future<void> saveBulk(Map<String, String> changed) async {
    for (final entry in changed.entries) {
      _settings[entry.key] = entry.value;
    }
    notifyListeners();
    for (final entry in changed.entries) {
      await LocalDatabaseService.instance.upsertReceiptSetting(entry.key, entry.value);
    }
  }
}
