import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LangProvider with ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  set locale(Locale locale) {
    if (AppLocalizations.supportedLocales.contains(locale)) {
      _locale = locale;
      notifyListeners();
    }
  }
}
