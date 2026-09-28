import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationProvider extends ChangeNotifier {
  static const String _localeKey = 'app_language_code';
  Locale _locale = const Locale('uz');

  Locale get locale => _locale;

  LocalizationProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_localeKey);
      if (code != null && ['uz', 'ru', 'en'].contains(code)) {
        _locale = Locale(code);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setLocale(Locale newLocale) async {
    if (!['uz', 'ru', 'en'].contains(newLocale.languageCode)) return;
    _locale = newLocale;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, newLocale.languageCode);
    } catch (_) {}
  }

  String getLanguageName(String code) {
    switch (code) {
      case 'uz':
        return 'O‘zbek tili';
      case 'ru':
        return 'Русский';
      case 'en':
        return 'English';
      default:
        return 'O‘zbek tili';
    }
  }
}
