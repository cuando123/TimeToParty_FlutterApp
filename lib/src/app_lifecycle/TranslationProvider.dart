import 'package:flutter/material.dart';
import 'translation_database.dart';

class TranslationProvider extends ChangeNotifier {
  String _currentLanguage;

  TranslationProvider(this._currentLanguage);

  factory TranslationProvider.fromDeviceLanguage() {
    final String? deviceLanguage = WidgetsBinding.instance?.window.locale.toLanguageTag();
    String currentLanguage;
    switch (deviceLanguage) {
      case 'en-EN':
        currentLanguage = 'EN_en';
        break;
      case 'de-DE':
        currentLanguage = 'DE_de';
        break;
      case 'it-IT':
        currentLanguage = 'IT_it';
        break;
      case 'es-ES':
        currentLanguage = 'ES_es';
        break;
      case 'pl-PL':
        currentLanguage = 'PL_pl';
        break;
      case 'fr-FR':
        currentLanguage = 'FR_fr';
        break;
      default:
        currentLanguage = 'EN_en'; // Domyślnie angielski
        break;
    }
    return TranslationProvider(currentLanguage);
  }

  final TranslationDatabase _translationDatabase = TranslationDatabase();

  String get currentLanguage => _currentLanguage;

  void changeLanguage(String languageKey) {
    _currentLanguage = languageKey;
    notifyListeners();
  }

  Future<String> getTranslationText(String key) async {
    return await _translationDatabase.getTranslationText(key, _currentLanguage);
  }
}
