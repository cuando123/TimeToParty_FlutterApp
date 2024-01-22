import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../models/purchase_state.dart';

class IAPService extends ChangeNotifier{
  // cd. https://pub.dev/packages/in_app_purchase/example
  // and: https://www.youtube.com/watch?v=w7oqVDGMMJU
  late String uid;
  late String billingResponsesErrors;

  bool _isPurchased = false;
  bool get isPurchased => _isPurchased;

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription; //inicjalizacja i subskrypcja strumienia aktualizacji zakupow
  bool _isAvailable = false;
  final List<ProductDetails> _products = [];
  IAPService(InAppPurchase instance);

  late Function purchaseCompleteCallback;
  late Function purchaseErrorsCallback;

  static const platform = MethodChannel('com.frydoapps.timetoparty/billing');


  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  Future<String> invokeMethodPlatform() async {
    try {
      final String result = await platform.invokeMethod('getPurchases') as String;
      return result; // Zwraca wynik, jeśli wszystko przebiegnie pomyślnie
    } catch (e) {
      // Obsługa błędów
      return 'Error: $e'; // Zwraca komunikat o błędzie
    }
  }

  void onPurchaseComplete(Function callback) {
    // rejestracja callbacku
    purchaseCompleteCallback = callback;
  }
  void onPurchaseErrorsComplete(Function callback) {
    // rejestracja callbacku
    purchaseErrorsCallback = callback;
  }
  void setPurchased(bool value, PurchaseDetails purchaseDetails) {
    _isPurchased = value;
    var purchaseState = PurchaseState(); // Ustawienie stanu zakupu w klasie tamtej do translations providera only
    purchaseState.isPurchased = true;
    notifyListeners();
    purchaseCompleteCallback.call();
    if (purchaseDetails.productID == "timetoparty.fullversion.test"){
      FirebaseFirestore.instance.collection('purchases').add({
      //  'user_id': userId,
      //  'details': purchaseDetails,
        // Możesz dodać więcej szczegółów związanych z zakupem
      });
    //oraz wywolanie callbacku np do wyswietlenia alertdialoga
  }
  }

  initializePurchaseStream() {
    // Inicjalizacja strumienia aktualizacji zakupów.
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onError: (error) {
      // Obsługa błędów.
    });
  }

// Inicjalizacja informacji o sklepie i dostępnych produktach.
  Future<void> initStoreInfo(List<String> productIds) async {
    _isAvailable = await _inAppPurchase.isAvailable();
    if (!_isAvailable) {
      // Sklep nie jest dostępny.
      return;
    }
    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds.toSet());
    if (response.error != null) {
      // Obsługa błędów związanych z pobieraniem szczegółów produktu.
      return;
    }
    // Dodanie pobranych szczegółów produktu do listy _products
    _products.addAll(response.productDetails);
  }


  // Funkcja do przywracania zakupów
  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
      _inAppPurchase.purchaseStream.listen((purchaseDetailsList) {
        for (var purchaseDetails in purchaseDetailsList) {
          if (purchaseDetails.status == PurchaseStatus.purchased ||
              purchaseDetails.status == PurchaseStatus.restored) {
            bool isValid = _verifyPurchase(purchaseDetails);
            if (isValid) {
              print("Zakup zweryfikowany i przywrócony");
              setPurchased(true, purchaseDetails);
            } else {
              print("Weryfikacja zakupu nieudana");
              billingResponsesErrors = purchaseDetails.error?.message ?? 'Błąd weryfikacji';
              purchaseErrorsCallback.call();
            }
          }
        }
      });
    } catch (e) {
      print("Błąd przy przywracaniu zakupów: $e");
      billingResponsesErrors = e.toString();
      purchaseErrorsCallback.call();
    }
  }

//czekaj na dokonczenie transakcji
  Future<bool> waitForPurchaseCompletion(PurchaseDetails purchaseDetails, Duration timeout) async {
    final startTime = DateTime.now();
    while (DateTime.now().difference(startTime) < timeout) {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.error) {
        return _verifyPurchase(purchaseDetails);
      }
      // Czekaj przez krótki czas przed kolejnym sprawdzeniem
      await Future.delayed(Duration(seconds: 1));
      // Opcjonalnie: odśwież informacje o zakupie
    }
    // Jeśli czas minął, a status nie zmienił się na 'purchased' lub 'error'
    print("Timeout - status zakupu nie został potwierdzony");
    return false;
  }

  // Funkcja do obsługi aktualizacji zakupów.
  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((purchaseDetails) async {
      switch (purchaseDetails.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
        // Weryfikacja zakupu przed dostarczeniem produktu
          bool isValid = _verifyPurchase(purchaseDetails);
          if (isValid) {
            print("Zakup zweryfikowany i dostarczony");
            setPurchased(true, purchaseDetails);
          } else {
            // Obsługa nieudanej weryfikacji
            print("Weryfikacja zakupu nieudana");
            billingResponsesErrors = purchaseDetails.error!.message;
            purchaseErrorsCallback.call();
          }
          break;
        case PurchaseStatus.error:
        // Obsługa błędów zakupu - karta zawsze odrzuca
          print("Błąd zakupu: ${purchaseDetails.error?.message}");
          billingResponsesErrors = purchaseDetails.error!.message;
          purchaseErrorsCallback.call();
          break;
        case PurchaseStatus.pending:
          print("Zakup oczekujący, oczekiwanie na potwierdzenie...");
          bool isCompleted = await waitForPurchaseCompletion(purchaseDetails, Duration(minutes: 5));
          if (isCompleted) {
            try {
              // Ukończenie zakupu
              await InAppPurchase.instance.completePurchase(purchaseDetails);
              bool isValid = _verifyPurchase(purchaseDetails);

              if (isValid) {
                print("Zakup zweryfikowany i dostarczony");
                setPurchased(true, purchaseDetails);
              } else {
                print("Weryfikacja zakupu nieudana");
                billingResponsesErrors = purchaseDetails.error!.message;
                purchaseErrorsCallback.call();
              }
            } catch (e) {
              print("Błąd podczas finalizowania zakupu: $e");
              billingResponsesErrors = purchaseDetails.error!.message;
              purchaseErrorsCallback.call();
            }
          } else {
            print("Zakup nie został zakończony w odpowiednim czasie");// tu chyba trzeba dorobic ręcznie tekst?
            billingResponsesErrors = purchaseDetails.status.toString();
            purchaseErrorsCallback.call();
          }
          break;
        default:
        // Obsługa innych stanów zakupu
          print("Nieobsłużony status zakupu: ${purchaseDetails.status}");
          billingResponsesErrors = purchaseDetails.status.toString();
          purchaseErrorsCallback.call();
          break;
      }
    });
  }

  bool _verifyPurchase(PurchaseDetails purchaseDetails) {
    // Pobranie i parsowanie danych zakupu
    var localVerificationData = json.decode(purchaseDetails.verificationData.localVerificationData);
    print("localVerificationData JSON: $localVerificationData");

    String? localPurchaseToken = localVerificationData['purchaseToken'] as String;
    if (localPurchaseToken == null) {
      print("Brak purchaseToken w danych lokalnych.");
      return false;
    }

    String serverPurchaseToken = purchaseDetails.verificationData.serverVerificationData;
    if (serverPurchaseToken.isEmpty) {
      print("Brak purchaseToken w danych serwerowych.");
      return false;
    }

    // Porównanie całych tokenów zakupu
    if (localPurchaseToken == serverPurchaseToken) {
      print ("Tokeny są zgodne!");
      return true;
    } else {
      print("Tokeny zakupu nie są zgodne.");
      return false;
    }
  }

  void buyProduct(List<String> productIds) {
    for (String productId in productIds) {
      final productDetails = _products.firstWhere(
            (product) => product.id == productId,
      );

      if (productDetails != null) {
        final PurchaseParam purchaseParam = PurchaseParam(
          productDetails: productDetails,
        );
        _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        // Obsługa sytuacji, gdy nie znaleziono szczegółów produktu
        print("Nie znaleziono szczegółów produktu dla ID: $productId");
      }
    }
  }

  // Zwalnianie zasobów.
  void dispose() {
    _subscription.cancel();
  }
}