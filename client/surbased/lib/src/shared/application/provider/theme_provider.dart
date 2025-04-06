import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  final _prefs = SharedPreferences.getInstance();

  ThemeProvider() {
    _loadSavedTheme();
  }

  bool get isDarkMode => _isDarkMode;

  void _loadSavedTheme() async {
    final prefs = await _prefs;
    final savedTheme = prefs.getBool('dark_mode');
    if (savedTheme != null) {
      _isDarkMode = savedTheme;
      notifyListeners();
    }
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveTheme();
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    final prefs = await _prefs;
    await prefs.setBool('dark_mode', _isDarkMode);
  }
}
