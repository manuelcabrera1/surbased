import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilityProvider extends ChangeNotifier {
  String _textSize = 'medium';
  final _prefs = SharedPreferences.getInstance();

  AccessibilityProvider() {
    _loadSavedTextSize();
  }

  String get textSize => _textSize;

  void _loadSavedTextSize() async {
    final prefs = await _prefs;
    final savedTextSize = prefs.getString('text_size');
    if (savedTextSize != null) {
      _textSize = savedTextSize;
      notifyListeners();
    }
  }

  set textSize(String value) {
    _textSize = value;
    _saveTextSize(value);
    notifyListeners();
  }

  Future<void> _saveTextSize(String value) async {
    final prefs = await _prefs;
    await prefs.setString('text_size', value);
  }
} 