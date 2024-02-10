import 'dart:async';
import 'package:flutter/material.dart';
import 'package:game_template/src/in_app_purchase/models/shared_preferences_helper.dart';
import '../in_app_purchase/models/purchase_state.dart';
import 'translation_database.dart';

class TranslationProvider extends ChangeNotifier {
  String _currentLanguage;
  Map<String, String> _cachedTranslations = {};
  Map<String, String> _cachedWords = {};
  TranslationProvider._privateConstructor(this._currentLanguage);

  static Future<TranslationProvider> create() async {
    String? savedLanguage = await SharedPreferencesHelper.getLanguageFromDevice();
    String currentLanguage = savedLanguage ?? 'EN_en';
    if (savedLanguage != null && savedLanguage.isNotEmpty) {
      currentLanguage = savedLanguage;
    } else {
      final String deviceLanguage = WidgetsBinding.instance.window.locale.toLanguageTag();
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
          currentLanguage = 'EN_en';
          break;
      }
      await SharedPreferencesHelper.setLanguageFromDevice(currentLanguage);
    }
    final provider = TranslationProvider._privateConstructor(currentLanguage);
    await provider.loadTranslations();
    await provider.loadWords();
    return provider;
  }

  final TranslationDatabase _translationDatabase = TranslationDatabase();

  String get currentLanguage => _currentLanguage;

  Future<void> changeLanguage(String languageKey) async {
    _currentLanguage = languageKey;
    await SharedPreferencesHelper.setLanguageFromDevice(languageKey);
    await loadTranslations();
    await loadWords();
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
    var purchaseState = PurchaseState(); //bierzemy purchase state aby pobierac więcej słów z bazy tutaj
    _cachedWords = await _translationDatabase.fetchWordsByLanguage(_currentLanguage, purchaseState.isPurchased);
    notifyListeners();
  }

  String getWord(String key) {
    return _cachedWords[key] ?? '';
  }

  String getLanguagePrefix() {
    return _currentLanguage.split('_').first;
  }

}
