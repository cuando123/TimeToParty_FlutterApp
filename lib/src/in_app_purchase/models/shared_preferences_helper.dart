import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _instance async => _prefs ??= await SharedPreferences.getInstance();

  // Metoda inicjalizująca
  static Future<void> init() async {
    _prefs = await _instance;
  }

  static Future<void> savePurchaseState(bool isPurchased) async {
    final prefs = await _instance;
    await prefs.setBool('isPurchased', isPurchased);
  }

  static Future<bool> getPurchaseState() async {
    final prefs = await _instance;
    return prefs.getBool('isPurchased') ?? false;
  }

  // Zapisywanie danych
  static Future<void> setUserID(String? value) async => await _prefs?.setString('userID', value ?? '');
  static Future<void> setPurchaseStatus(String? value) async => await _prefs?.setString('purchaseStatus', value ?? '');
  static Future<void> setPurchaseID(String? value) async => await _prefs?.setString('purchaseID', value ?? '');
  static Future<void> setCreatedUserDate(String? value) async => await _prefs?.setString('createdUserDate', value ?? '');
  static Future<void> setPurchaseDate(String? value) async => await _prefs?.setString('purchaseDate', value ?? '');
  static Future<void> setProductID(String? value) async => await _prefs?.setString('productID', value ?? '');
  static Future<void> setFinalSpendTimeOnGame(int? newValue) async {
    int currentValue = _prefs?.getInt('finalSpendTimeOnGame') ?? 0;
    int updatedValue = newValue == 0 ? currentValue : currentValue + (newValue ?? 0);
    await _prefs?.setInt('finalSpendTimeOnGame', updatedValue);
  }
  static Future<void> setLastOneSpendTimeOnGame(int? value) async => await _prefs?.setInt('lastOneSpendTimeOnGame', value ?? 0);
  static Future<void> setLastHowManyFieldReached(String value) async => await _prefs?.setString('lastHowManyFieldReached', value);
  static Future<void> setHowManyTimesFinishedGame() async {
    final SharedPreferences prefs = await _instance;
    int currentValue = prefs.getInt('howManyTimesFinishedGame') ?? 0;
    await prefs.setInt('howManyTimesFinishedGame', currentValue + 1);
  }
  static Future<void> setHowManyTimesRunApp() async {
    final SharedPreferences prefs = await _instance;
    int currentValue = prefs.getInt('howManyTimesRunApp') ?? 0; // Odczytaj obecną wartość
    await prefs.setInt('howManyTimesRunApp', currentValue + 1); // Inkrementuj o 1 i zapisz z powrotem
  }
  static Future<void> setHowManyTimesRunInterstitialAd() async {
    final SharedPreferences prefs = await _instance;
    int currentValue = prefs.getInt('howManyTimesRunInterstitialAd') ?? 0; // Odczytaj obecną wartość
    await prefs.setInt('howManyTimesRunInterstitialAd', currentValue + 1); // Inkrementuj o 1 i zapisz z powrotem
  }
  static Future<void> setLastPlayDate(String? value) async => await _prefs?.setString('lastPlayDate', value ?? '');
  static Future<void> setLastNotificationClicked(String? value) async => await _prefs?.setString('lastNotificationClicked', value ?? '');

  // Odczytywanie danych
  static String? getUserID() => _prefs?.getString('userID');
  static String? getPurchaseStatus() => _prefs?.getString('purchaseStatus');
  static String? getPurchaseID() => _prefs?.getString('purchaseID');
  static String? getCreatedUserDate() => _prefs?.getString('createdUserDate');
  static String? getPurchaseDate() => _prefs?.getString('purchaseDate');
  static String? getProductID() => _prefs?.getString('productID');
  static int? getFinalSpendTimeOnGame() => _prefs?.getInt('finalSpendTimeOnGame');
  static int? getLastOneSpendTimeOnGame() => _prefs?.getInt('lastOneSpendTimeOnGame');
  static String? getLastHowManyFieldReached() => _prefs?.getString('lastHowManyFieldReached');
  static int? getHowManyTimesFinishedGame() => _prefs?.getInt('howManyTimesFinishedGame');
  static int? getHowManyTimesRunApp() => _prefs?.getInt('howManyTimesRunApp');
  static int? getHowManyTimesRunInterstitialAd() => _prefs?.getInt('howManyTimesRunInterstitialAd');
  static String? getLastPlayDate() => _prefs?.getString('lastPlayDate');
  static String? getLastNotificationClicked() => _prefs?.getString('lastNotificationClicked');
}
