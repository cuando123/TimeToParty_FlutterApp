import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../app_lifecycle/TranslationProvider.dart';
import '../models/purchase_state.dart';

class IAPService extends ChangeNotifier{
  // cd. https://pub.dev/packages/in_app_purchase/example
  // and: https://www.youtube.com/watch?v=w7oqVDGMMJU
  late String uid;
  String _purchaseStatusMessage = '';
  String get purchaseStatusMessage => _purchaseStatusMessage;

  bool _isPurchased = false;
  bool get isPurchased => _isPurchased;
  late bool _isLoading = false;
  bool get isLoading => _isLoading;


  late final TranslationProvider translationProvider;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription; //inicjalizacja i subskrypcja strumienia aktualizacji zakupow
  bool _subscriptionInitialized = false;
  bool _isAvailable = false;
  final List<ProductDetails> _products = [];
  IAPService(InAppPurchase instance);

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  void setPurchaseStatusMessage(String message) {
    _purchaseStatusMessage = message;
    notifyListeners();
  }

  void resetPurchaseStatusMessage() {
    setPurchaseStatusMessage('');
  }

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners(); // informuje obserwatorów o zmianie
  }

  Future<void> setPurchased(bool value, PurchaseDetails purchaseDetails) async {
    _isPurchased = value;
    var purchaseState = PurchaseState(); // Ustawienie stanu zakupu w klasie tamtej do translations providera only
    purchaseState.isPurchased = true;
    notifyListeners();
    setPurchaseStatusMessage("PurchaseSuccess");
    isLoading = false;
    await translationProvider.loadWords();
    if (purchaseDetails.productID == "timetoparty.fullversion.test"){
      await FirebaseFirestore.instance.collection('purchases').add({
      //  'user_id': userId,
      //  'details': purchaseDetails,
        // Możesz dodać więcej szczegółów związanych z zakupem
      });
    //oraz wywolanie callbacku np do wyswietlenia alertdialoga
  }
  }

  initializePurchaseStream() {
    if (!_subscriptionInitialized) {
      final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
      _subscription = purchaseUpdated.listen((purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      }, onError: (error) {
        print ("error z initialize purchase stream $error");
      });
      _subscriptionInitialized = true;
    }
  }


// Inicjalizacja informacji o sklepie i dostępnych produktach.
  Future<void> initStoreInfo(List<String> productIds) async {
    try {
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
    } finally {
    }
  }

  // Funkcja do przywracania zakupów
  Future<void> restorePurchases() async {
    isLoading = true;
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
              setPurchaseStatusMessage("PurchaseRestored");
            } else {
              print("Weryfikacja zakupu nieudana");
              setPurchaseStatusMessage(purchaseDetails.error?.message ?? 'Błąd weryfikacji');
            }
          }
        }
      });
    } catch (e) {
      print("Błąd przy przywracaniu zakupów: $e");
      setPurchaseStatusMessage(e.toString());
    } finally {
      isLoading = false; // Kończy ładowanie
    }
  }

//czekaj na dokonczenie transakcji
  Future<bool> waitForPurchaseCompletion(PurchaseDetails purchaseDetails, Duration timeout) async {
    final startTime = DateTime.now();
    try {
      while (DateTime.now().difference(startTime) < timeout) {
        if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.error) {
          return _verifyPurchase(purchaseDetails);
        }
        // Czekaj przez krótki czas przed kolejnym sprawdzeniem
        await Future.delayed(Duration(seconds: 1));
      }
      print("Timeout - status zakupu nie został potwierdzony");
      return false;
    } finally {
      print("completion DONE");
    }
  }


  // Funkcja do obsługi aktualizacji zakupów.
  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((purchaseDetails) async {
      print("_listenToPurchaseUpdated true");
      isLoading = true;
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
            setPurchaseStatusMessage(purchaseDetails.error!.message);
            isLoading = false;
          }
          break;
        case PurchaseStatus.error:
          print("Błąd zakupu: ${purchaseDetails.error?.message}");
          setPurchaseStatusMessage(purchaseDetails.error!.message);
          isLoading = false;
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
                break;
              } else {
                print("Weryfikacja zakupu nieudana");
                setPurchaseStatusMessage(purchaseDetails.error!.message);
                isLoading = false;
              }
            } catch (e) {
              print("Błąd podczas finalizowania zakupu: $e");
              setPurchaseStatusMessage(purchaseDetails.error!.message);
              isLoading = false;
            }
          } else {
            print("Zakup nie został zakończony w odpowiednim czasie");// tu chyba trzeba dorobic ręcznie tekst?
            setPurchaseStatusMessage(purchaseDetails.status.toString());
            isLoading = false;
          }
          break;
        default:
          print("Nieobsłużony status zakupu: ${purchaseDetails.status}");
          setPurchaseStatusMessage(purchaseDetails.status.toString());
          isLoading = false;
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
    print("buyProduct true");
    isLoading = true; // Rozpoczyna ładowanie
    try {
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
          print("Nie znaleziono szczegółów produktu dla ID: $productId");
          isLoading = false; // Kończy ładowanie jeśli nie znaleziono produktu
        }
      }
    } catch (e) {
      print ("error $e");
      isLoading = false; // Kończy ładowanie w przypadku błędu
    }
  }


  // Zwalnianie zasobów.
  void dispose() {
    _subscription.cancel();
  }
}