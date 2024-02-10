import 'package:shared_preferences/shared_preferences.dart';
import 'shared_encryption_helper.dart';

class SharedPreferencesHelper {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _instance async => _prefs ??= await SharedPreferences.getInstance();

  static Future<void> init() async {
    _prefs = await _instance;
  }

  // Zapisywanie String
  static Future<void> setString(String key, String? value) async {
    final prefs = await _instance;
    if (value != null && value.isNotEmpty) {
      // Sprawdź, czy wartość nie jest pusta
      final encryptedValue = EncryptionHelper.encryptText(value);
      await prefs.setString(key, encryptedValue!);
    } else {
      final encryptedValue = EncryptionHelper.encryptText(""); // Szyfruj pusty ciąg
      await prefs.setString(key, encryptedValue!);
    }
  }

  // Odczytywanie String
  static Future<String?> getString(String key) async {
    final prefs = await _instance;
    final encryptedValue = prefs.getString(key);
    // Upewnij się, że encryptedValue nie jest null przed próbą deszyfrowania
    if (encryptedValue == null || encryptedValue.isEmpty) {
      return '';
    }

    String? decryptedValue = EncryptionHelper.decryptText(encryptedValue);
    if (decryptedValue == null) {
     // print("Decryption returned null for key $key, indicating an error or empty input.");
    }
    return decryptedValue;
  }

  // Zapisywanie bool
  static Future<void> setBool(String key, bool value) async {
    final stringValue = value.toString();
    await setString(key, stringValue);
  }

  // Odczytywanie bool
  static Future<bool?> getBool(String key) async {
    final stringValue = await getString(key);
    // Upewnij się, że stringValue nie jest null przed próbą konwersji
    if (stringValue == null) {
      //print("No value found for key $key, returning null.");
      return null;
    }

    // Bezpiecznie konwertuj odczytaną wartość na bool
    return stringValue.toLowerCase() == 'true';
  }

  // Zapisywanie int
  static Future<void> setInt(String key, int value) async {
    final stringValue = value.toString();
    await setString(key, stringValue);
  }

  // Odczytywanie int
  static Future<int?> getInt(String key) async {
    final stringValue = await getString(key);
    if (stringValue == null) {
      print("No value found for key $key, returning null.");
      return null;
    }

    // Bezpiecznie próbuj konwertować odczytaną wartość na int
    final intValue = int.tryParse(stringValue);
    if (intValue == null) {
      //print("Could not convert value to int for key $key.");
      return null;
    }
    return intValue;
  }

  // Zapisywanie danych
  static Future<void> savePurchaseState(bool isPurchased) async {
    await setBool('isPurchased', isPurchased);
  }

  static Future<bool> getPurchaseState() async {
    return await getBool('isPurchased') ?? false;
  }

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
    final int? oldValue = await getInt('finalSpendTimeOnGame');
    final intValue = (oldValue ?? 0) + (newValue ?? 0);
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

  static Future<void> setFirebaseMessagingToken(String value) async {
    await setString('firebaseMessagingToken', value);
  }

  // Odczytywanie danych
  static Future<String?> getFirebaseMessagingToken() async {
    return await getString('firebaseMessagingToken');
  }

  static Future<String?> getUserID() async {
    return await getString('userID');
  }

  static Future<String?> getPurchaseStatus() async {
    return await getString('purchaseStatus');
  }

  static Future<String?> getPurchaseID() async {
    return await getString('purchaseID');
  }

  static Future<String?> getCreatedUserDate() async {
    return await getString('createdUserDate');
  }

  static Future<String?> getPurchaseDate() async {
    return await getString('purchaseDate');
  }

  static Future<String?> getProductID() async {
    return await getString('productID');
  }

  static Future<int?> getFinalSpendTimeOnGame() async {
    return getInt('finalSpendTimeOnGame');
  }

  static Future<int?> getLastOneSpendTimeOnGame() async {
    return getInt('lastOneSpendTimeOnGame');
  }

  static Future<String?> getLastHowManyFieldReached() async {
    return await getString('lastHowManyFieldReached');
  }

  static Future<int?> getHowManyTimesFinishedGame() async {
    return getInt('howManyTimesFinishedGame');
  }

  static Future<int?> getHowManyTimesRunApp() async {
    return getInt('howManyTimesRunApp');
  }

  static Future<int?> getHowManyTimesRunInterstitialAd() async {
    return getInt('howManyTimesRunInterstitialAd');
  }

  static Future<String?> getLastPlayDate() async {
    return await getString('lastPlayDate');
  }

  static Future<String?> getLastNotificationClicked() async {
    return await getString('lastNotificationClicked');
  }
}
