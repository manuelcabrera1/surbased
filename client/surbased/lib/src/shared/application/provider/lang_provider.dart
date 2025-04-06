import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LangProvider with ChangeNotifier {
  Locale _locale = const Locale('en');
  final _prefs = SharedPreferences.getInstance();

  LangProvider() {
    _loadSavedLanguage();
  }

  Locale get locale => _locale;

  void _loadSavedLanguage() async {
    final prefs = await _prefs;
    final savedLang = prefs.getString('language');
    if (savedLang != null) {
      _locale = Locale(savedLang);
      notifyListeners();
    }
  }

  set locale(Locale locale) {
    if (AppLocalizations.supportedLocales.contains(locale)) {
      _locale = locale;
      _saveLanguage(locale.languageCode);
      notifyListeners();
    }
  }

  Future<void> _saveLanguage(String languageCode) async {
    final prefs = await _prefs;
    await prefs.setString('language', languageCode);
  }
}
