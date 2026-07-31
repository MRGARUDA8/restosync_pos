import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  ThemeMode _themeMode = ThemeMode.dark;

  int get selectedIndex => _selectedIndex;
  ThemeMode get themeMode => _themeMode;

  set selectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
