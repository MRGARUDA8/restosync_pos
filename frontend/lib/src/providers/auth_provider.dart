import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/user.dart';
import '../services/local_database.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool get isLoggedIn => _user != null;
  User? get user => _user;

  final _uuid = const Uuid();

  Future<void> initialize() async {
    // On web, skip DB initialization (handled by AppShell). Keep user logged out by default.
    if (kIsWeb) return;

    final db = await LocalDatabaseService.instance.database;
    final rows = await db.query('users', limit: 1);
    if (rows.isNotEmpty) {
      _user = User.fromMap(rows.first);
      notifyListeners();
    }
  }

  Future<bool> login(String name, String pin) async {
    // Quick web fallback using seeded test users so Chrome preview works.
    if (kIsWeb) {
      final normalized = name.trim();
      final p = pin.trim();
      final seeded = _seededWebUsers();
      User? match;
      for (final u in seeded) {
        if (u.name == normalized && u.pin == p) {
          match = u;
          break;
        }
      }
      if (match != null) {
        _user = match;
        notifyListeners();
        return true;
      }
      return false;
    }

    final db = await LocalDatabaseService.instance.database;
    final rows = await db.query('users', where: 'name = ? AND pin = ?', whereArgs: [name, pin]);
    if (rows.isNotEmpty) {
      _user = User.fromMap(rows.first);
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _user = null;
    notifyListeners();
  }

  bool hasPermission(String permission) {
    return _user?.permissions.contains(permission) ?? false || _user?.role == UserRole.admin;
  }

  List<User> _seededWebUsers() {
    return [
      User(id: _uuid.v4(), name: 'Admin', role: UserRole.admin, pin: '1234', permissions: ['all']),
      User(id: _uuid.v4(), name: 'Manager', role: UserRole.manager, pin: '4321', permissions: ['inventory', 'reports', 'expenses']),
      User(id: _uuid.v4(), name: 'Cashier', role: UserRole.cashier, pin: '1111', permissions: ['billing', 'customers']),
      User(id: _uuid.v4(), name: 'Kitchen', role: UserRole.kitchen, pin: '2222', permissions: ['kds']),
    ];
  }
}
