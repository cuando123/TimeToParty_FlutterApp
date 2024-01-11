import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_lifecycle/TranslationProvider.dart';

import '../style/snack_bar.dart';
import 'services/firebase_service.dart';

/// Allows buying in-app. ,Facade of `package:in_app_purchase`.
class InAppPurchaseController extends ChangeNotifier {
  static final Logger _log = Logger('InAppPurchases');
  late final TranslationProvider translationProvider;
  //final FirebaseService _firebaseService = FirebaseService();

  bool _isPurchased = false;

  InAppPurchaseController(InAppPurchase instance, TranslationProvider translationProvider);

  bool get isPurchased => _isPurchased;

  Future<void> setPurchased(bool value) async {
    _isPurchased = value;
    var purchaseState = PurchaseState();
    purchaseState.isPurchased = true; // Ustawienie stanu zakupu
    await translationProvider.loadWords();
    notifyListeners();

    if (value) {
      // Zapisz stan zakupu w pamięci lokalnej
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isPurchased', value);

      // Zaloguj użytkownika w Firebase
      // await _firebaseService.signInAnonymouslyAndSaveUID();
      // await buy();
    }
  }
/*
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  InAppPurchase inAppPurchaseInstance;

  //AdRemovalPurchase _adRemoval = const AdRemovalPurchase.notStarted();

  /// Tworzy nowy kontroler [InAppPurchaseController] z wstrzykniętym
  /// Instancja [InAppPurchase].
  ///
  /// Przykładowe użycie:
  ///
  /// var kontroler = InAppPurchaseController(InAppPurchase.instance);
  InAppPurchaseController(this.inAppPurchaseInstance, this.translationProvider);


  /// The current state of the ad removal purchase.
  //AdRemovalPurchase get adRemoval => _adRemoval;

  /// Uruchamia interfejs platformy umożliwiający dokonywanie zakupów w aplikacji.
  /// Obecnie jedynym obsługiwanym zakupem w aplikacji jest usuwanie reklam.
  /// Aby obsłużyć więcej, dodaj dodatkowe klasy podobne do [AdRemovalPurchase]
  /// i zmodyfikuj tę metodę.


  Future<void> buy() async {
    if (!await inAppPurchaseInstance.isAvailable()) {
      _reportError('InAppPurchase.instance not available');
      return;
    }

    _adRemoval = const AdRemovalPurchase.pending();
    notifyListeners();

    _log.info('Zapytanie do sklepu za pomocą queryProductDetails()');
    final response = await inAppPurchaseInstance.queryProductDetails({AdRemovalPurchase.productId});

    if (response.error != null) {
      _reportError('Podczas dokonywania zakupu wystąpił błąd: '
          '${response.error}');
      return;
    }

    if (response.productDetails.length != 1) {
      _log.info(
        'Produkty w odpowiedzi: '
            '${response.productDetails.map((e) => '${e.id}: ${e.title}, ').join()}',
      );
      _reportError('Podczas dokonywania zakupu wystąpił błąd: '
          'product ${AdRemovalPurchase.productId} nie istnieje?');
      return;
    }
    final productDetails = response.productDetails.single;

    _log.info('Dokonanie zakupu');
    final purchaseParam = PurchaseParam(productDetails: productDetails);
    try {
      final success = await inAppPurchaseInstance.buyNonConsumable(purchaseParam: purchaseParam);
      _log.info('buyNonConsumable() żądanie zostało wysłane pomyślnie: $success');
      // The result of the purchase will be reported in the purchaseStream,
      // which is handled in [_listenToPurchaseUpdated].
    } catch (e) {
      _log.severe('Problem z wywołaniem inAppPurchaseInstance.buyNonConsumable(): '
          '$e');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  /// Prosi platformę bazową o wyświetlenie listy zakupów, które już miały miejsce
  /// wykonane (na przykład w poprzedniej sesji gry).
  Future<void> restorePurchases() async {
    if (!await inAppPurchaseInstance.isAvailable()) {
      _reportError('InAppPurchase.instancja niedostępna');
      return;
    }

    try {
      await inAppPurchaseInstance.restorePurchases();
    } catch (e) {
      _log.severe('Nie można przywrócić zakupów w aplikacji: $e');
    }
    _log.info('Przywrócono zakupy w aplikacji');
  }

  /// Subscribes to the [inAppPurchaseInstance.purchaseStream].
  /// Metoda subscribe(): Słucha strumienia zakupów i aktualizuje stan w zależności od zmian.
  void subscribe() {
    _subscription?.cancel();
    _subscription = inAppPurchaseInstance.purchaseStream.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription?.cancel();
    }, onError: (dynamic error) {
      _log.severe('Wystąpił błąd w strumieniu zakupów: $error');
    });
  }

  /// _listenToPurchaseUpdated(): Obsługuje aktualizacje zakupów.
  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchaseDetails in purchaseDetailsList) {
      _log.info(() => 'New PurchaseDetails instance received: '
          'productID=${purchaseDetails.productID}, '
          'status=${purchaseDetails.status}, '
          'purchaseID=${purchaseDetails.purchaseID}, '
          'error=${purchaseDetails.error}, '
          'pendingCompletePurchase=${purchaseDetails.pendingCompletePurchase}');

      if (purchaseDetails.productID != AdRemovalPurchase.productId) {
        _log.severe("Obsługa produktu o identyfikatorze"
            "'${purchaseDetails.productID}' nie jest zaimplementowana.");
        _adRemoval = const AdRemovalPurchase.notStarted();
        notifyListeners();
        continue;
      }

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          _adRemoval = const AdRemovalPurchase.pending();
          notifyListeners();
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            _adRemoval = const AdRemovalPurchase.active();
            setPurchased(true);
            if (purchaseDetails.status == PurchaseStatus.purchased) {
              showSnackBar('Dziękuję za Twoje wsparcie!');
            }
            notifyListeners();
          } else {
            _log.severe('Weryfikacja zakupu nie powiodła się: $purchaseDetails');
            _adRemoval = AdRemovalPurchase.error(StateError('Nie udało się zweryfikować zakupu'));
            notifyListeners();
          }
          break;
        case PurchaseStatus.error:
          _log.severe('Błąd przy zakupie: ${purchaseDetails.error}');
          _adRemoval = AdRemovalPurchase.error(purchaseDetails.error!);
          notifyListeners();
          break;
        case PurchaseStatus.canceled:
          _adRemoval = const AdRemovalPurchase.notStarted();
          notifyListeners();
          break;
      }

      if (purchaseDetails.pendingCompletePurchase) {
        // Confirm purchase back to the store.
        await inAppPurchaseInstance.completePurchase(purchaseDetails);
      }
    }
  }

  void _reportError(String message) {
    _log.severe(message);
    showSnackBar(message);
    _adRemoval = AdRemovalPurchase.error(message);
    notifyListeners();
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    _log.info('Verifying purchase: ${purchaseDetails.verificationData}');
    //TO_DO: verify the purchase.
    // See the info in [purchaseDetails.verificationData] to learn more.
    // There's also a codelab that explains purchase verification
    // on the backend:
    // https://codelabs.developers.google.com/codelabs/flutter-in-app-purchases#9
    return true;
  }
*/
/*
  void savePurchaseData(String userId, String purchaseDetails) {
    FirebaseFirestore.instance.collection('purchases').add({
      'user_id': userId,
      'details': purchaseDetails,
      // Możesz dodać więcej szczegółów związanych z zakupem
    });
  }
*/


}

class PurchaseState {
  static final PurchaseState _instance = PurchaseState._internal();

  factory PurchaseState() {
    return _instance;
  }

  PurchaseState._internal();

  bool isPurchased = false;
}


/*Consumer<InAppPurchaseController>(
builder: (context, purchaseController, child) {
if (purchaseController.isPurchased) {
return PremiumContent(); // Zawartość dla użytkowników, którzy dokonali zakupu
} else {
return FreeContent(); // Zawartość dla użytkowników bez zakupu
}
},
)*/
