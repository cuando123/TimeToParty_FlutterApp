import 'package:shared_preferences/shared_preferences.dart';
import 'shared_encryption_helper.dart'; // Załóżmy, że ścieżka do EncryptionHelper jest poprawna

class SharedPreferencesHelper {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _instance async => _prefs ??= await SharedPreferences.getInstance();

  static Future<void> init() async {
    _prefs = await _instance;
  }

  // Zapisywanie String
  static Future<void> setString(String key, String? value) async {
    final prefs = await _instance;
    if (value != null) {
      final encryptedValue = EncryptionHelper.encryptText(value);
      await prefs.setString(key, encryptedValue);
    } else {
      await prefs.remove(key); // Usuwamy klucz, jeśli wartość jest nullem
    }
  }

  // Odczytywanie String
  static Future<String?> getString(String key) async {
    final prefs = await _instance;
    final encryptedValue = prefs.getString(key);
    return encryptedValue != null ? EncryptionHelper.decryptText(encryptedValue) : null;
  }

  // Zapisywanie bool
  static Future<void> setBool(String key, bool value) async {
    final stringValue = value.toString();
    await setString(key, stringValue);
  }

  // Odczytywanie bool
  static Future<bool?> getBool(String key) async {
    final stringValue = await getString(key);
    return stringValue != null ? stringValue.toLowerCase() == 'true' : null;
  }

  // Zapisywanie int
  static Future<void> setInt(String key, int value) async {
    final stringValue = value.toString();
    await setString(key, stringValue);
  }

  // Odczytywanie int
  static Future<int?> getInt(String key) async {
    final stringValue = await getString(key);
    return stringValue != null ? int.tryParse(stringValue) : null;
  }

  // Przykład zastosowania dla jednej z metod
  static Future<void> savePurchaseState(bool isPurchased) async {
    await setBool('isPurchased', isPurchased);
  }

  static Future<bool> getPurchaseState() async {
    return await getBool('isPurchased') ?? false;
  }


  // Zapisywanie danych
  static Future<void> setUserID(String? value) async {
    final stringValue = value ?? '';
    await setString('userID', stringValue);
  }

  static Future<void> setPurchaseStatus(String? value) async {
    final stringValue = value ?? '';
    await setString('purchaseStatus', stringValue);
  }

  static Future<void> setPurchaseID(String? value) async {
    final stringValue = value ?? '';
    await setString('purchaseID', stringValue);
  }

  static Future<void> setCreatedUserDate(String? value) async {
    final stringValue = value ?? '';
    await setString('createdUserDate', stringValue);
  }

  static Future<void> setPurchaseDate(String? value) async {
    final stringValue = value ?? '';
    await setString('purchaseDate', stringValue);
  }

  static Future<void> setProductID(String? value) async {
    final stringValue = value ?? '';
    await setString('productID', stringValue);
  }

  static Future<void> setFinalSpendTimeOnGame(int? newValue) async {
    final intValue = newValue ?? 0;
    await setInt('finalSpendTimeOnGame', intValue);
  }

  static Future<void> setLastOneSpendTimeOnGame(int? value) async {
    final intValue = value ?? 0;
    await setInt('lastOneSpendTimeOnGame', intValue);
  }

  static Future<void> setLastHowManyFieldReached(String value) async {
    await setString('lastHowManyFieldReached', value);
  }

  static Future<void> setHowManyTimesFinishedGame() async {
    final int? currentValue = await getInt('howManyTimesFinishedGame');
    final incrementedValue = (currentValue ?? 0) + 1;
    await setInt('howManyTimesFinishedGame', incrementedValue);
  }

  static Future<void> setHowManyTimesRunApp() async {
    final int? currentValue = await getInt('howManyTimesRunApp');
    final incrementedValue = (currentValue ?? 0) + 1;
    await setInt('howManyTimesRunApp', incrementedValue);
  }

  static Future<void> setHowManyTimesRunInterstitialAd() async {
    final int? currentValue = await getInt('howManyTimesRunInterstitialAd');
    final incrementedValue = (currentValue ?? 0) + 1;
    await setInt('howManyTimesRunInterstitialAd', incrementedValue);
  }

  static Future<void> setLastPlayDate(String? value) async {
    final stringValue = value ?? '';
    await setString('lastPlayDate', stringValue);
  }

  static Future<void> setLastNotificationClicked(String? value) async {
    final stringValue = value ?? '';
    await setString('lastNotificationClicked', stringValue);
  }
  // Odczytywanie danych
  static String? getUserID() {
    final encryptedValue = _prefs?.getString('userID');
    return encryptedValue != null ? EncryptionHelper.decryptText(encryptedValue) : null;
  }

  static String? getPurchaseStatus() {
    final encryptedValue = _prefs?.getString('purchaseStatus');
    return encryptedValue != null ? EncryptionHelper.decryptText(encryptedValue) : null;
  }

  static String? getPurchaseID() {
    final encryptedValue = _prefs?.getString('purchaseID');
    return encryptedValue != null ? EncryptionHelper.decryptText(encryptedValue) : null;
  }

  static String? getCreatedUserDate() {
    final encryptedValue = _prefs?.getString('createdUserDate');
    return encryptedValue != null ? EncryptionHelper.decryptText(encryptedValue) : null;
  }

  static String? getPurchaseDate() {
    final encryptedValue = _prefs?.getString('purchaseDate');
    return encryptedValue != null ? EncryptionHelper.decryptText(encryptedValue) : null;
  }

  static String? getProductID() {
    final encryptedValue = _prefs?.getString('productID');
    return encryptedValue != null ? EncryptionHelper.decryptText(encryptedValue) : null;
  }

  static int? getFinalSpendTimeOnGame() {
    return _prefs?.getInt('finalSpendTimeOnGame');
  }

  static int? getLastOneSpendTimeOnGame() {
    return _prefs?.getInt('lastOneSpendTimeOnGame');
  }

  static String? getLastHowManyFieldReached() {
    final encryptedValue = _prefs?.getString('lastHowManyFieldReached');
    return encryptedValue != null ? EncryptionHelper.decryptText(encryptedValue) : null;
  }

  static int? getHowManyTimesFinishedGame() {
    return _prefs?.getInt('howManyTimesFinishedGame');
  }

  static int? getHowManyTimesRunApp() {
    return _prefs?.getInt('howManyTimesRunApp');
  }

  static int? getHowManyTimesRunInterstitialAd() {
    return _prefs?.getInt('howManyTimesRunInterstitialAd');
  }

  static String? getLastPlayDate() {
    final encryptedValue = _prefs?.getString('lastPlayDate');
    return encryptedValue != null ? EncryptionHelper.decryptText(encryptedValue) : null;
  }

  static String? getLastNotificationClicked() {
    final encryptedValue = _prefs?.getString('lastNotificationClicked');
    return encryptedValue != null ? EncryptionHelper.decryptText(encryptedValue) : null;
  }
}
