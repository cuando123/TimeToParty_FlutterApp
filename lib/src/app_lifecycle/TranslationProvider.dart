import 'package:flutter/material.dart';
import 'translation_database.dart';
import 'dart:async';

class TranslationProvider extends ChangeNotifier {
  String _currentLanguage;
  Map<String, String> _cachedTranslations = {};
  Map<String, String> _cachedWords = {};
  TranslationProvider(this._currentLanguage);

  factory TranslationProvider.fromDeviceLanguage() {
    final String deviceLanguage = WidgetsBinding.instance.window.locale.toLanguageTag();
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

  Future<void> changeLanguage(String languageKey) async {
    _currentLanguage = languageKey;
    await loadTranslations();
    notifyListeners();
  }

  String getTranslationText(String key) {
    return _cachedTranslations[key] ?? '';
  }

  Stream<String> translationTextStream(String key) async* {
    yield* Stream.periodic(Duration.zero, (_) => key).asyncMap(getTranslationText);
  }

  Future<void> loadTranslations() async {
    _cachedTranslations = await _translationDatabase.getAllTranslationsForLanguage(_currentLanguage);
    notifyListeners();
  }

  Future<void> loadWords() async {
    _cachedWords = await _translationDatabase.fetchWordsByLanguage(_currentLanguage);
    notifyListeners();
  }

  String getWord(String key) {
    return _cachedWords[key] ?? '';
  }

}
