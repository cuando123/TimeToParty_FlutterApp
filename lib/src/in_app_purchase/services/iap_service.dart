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

  late TranslationProvider translationProvider;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription; //inicjalizacja i subskrypcja strumienia aktualizacji zakupow
  bool _subscriptionInitialized = false;
  bool _isAvailable = false;
  final List<ProductDetails> _products = [];
  IAPService(InAppPurchase instance, this.translationProvider);

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

  void setPurchased(bool value, PurchaseDetails purchaseDetails) {
    _isPurchased = value;
    var purchaseState = PurchaseState(); // Ustawienie stanu zakupu w klasie tamtej do translations providera only
    purchaseState.isPurchased = true;
    notifyListeners();
    if (_purchaseStatusMessage != "PurchaseRestored" && _purchaseStatusMessage != '') {
      setPurchaseStatusMessage("PurchaseSuccess");
    }
    isLoading = false;
    translationProvider.loadWords();
    if (purchaseDetails.productID == "timetoparty.fullversion.test"){
      FirebaseFirestore.instance.collection('purchases').add({
      //  'user_id': userId,
      //  'details': purchaseDetails,
        // Możesz dodać więcej szczegółów związanych z zakupem
      });
    //oraz wywolanie callbacku np do wyswietlenia alertdialoga
  }
  }

  void initializePurchaseStream() {
    print("wywolanie subskrypcji");
    if (!_subscriptionInitialized) {
      final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
      _subscription = purchaseUpdated.listen((purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      }, onError: (error) {
        print ("error z initialize purchase stream $error");
      });
      _subscriptionInitialized = true;
    }
    print("koniec wywolanie subskrypcji");
  }


// Inicjalizacja informacji o sklepie i dostępnych produktach.
  Future<void> initStoreInfo(List<String> productIds) async {
    try {
      _isAvailable = await _inAppPurchase.isAvailable();
      if (!_isAvailable) {
        print("Skelp nie jest dostepny");
        return;
      }
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds.toSet());
      if (response.error != null) {
        print('Inicjalizacja sklepu: blad ${response.error}');
        return;
      }
      // Dodanie pobranych szczegółów produktu do listy _products
      _products.addAll(response.productDetails);
    } finally {
    }
  }

  // Funkcja do przywracania zakupów
  Future<bool> restorePurchases() async {
    isLoading = true;
    bool restoreSuccessful = false;
    bool isTimeout = false;
    print("Poczatel wywolania restorePurchases");
    try {
      await _inAppPurchase.restorePurchases();
      if (_inAppPurchase.restorePurchases() != null){
        restoreSuccessful = true;
      }
      // Tworzenie timera
      var timer = Timer(Duration(seconds: 30), () {
        if (!restoreSuccessful) {
          print("Timeout - BillingResponse.timeout");
          isTimeout = true;
        }
      });

      // Czekanie na zaktualizowanie stanu przez istniejącą subskrypcję
      while (!restoreSuccessful && !isTimeout) {
        await Future.delayed(Duration(milliseconds: 500));
      }

      // Anulowanie timera
      timer.cancel();

    } catch (e) {
      print("Błąd przy przywracaniu zakupów: $e");
      setPurchaseStatusMessage(e.toString());
    } finally {
      isLoading = false;
      if (isTimeout){
        setPurchaseStatusMessage("BillingResponse.timeout");
      }
      if (restoreSuccessful){
        setPurchaseStatusMessage("PurchaseRestored");
      }
      print("Koniec procesu przywracania zakupów");
    }
    print("koniec wywolania restorePurchases");
    return restoreSuccessful;
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

  Set<String> processedPurchases = {};

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((purchaseDetails) async {
      String? purchaseID = purchaseDetails.purchaseID;
      print("processedpurchases: $processedPurchases" );
      if (purchaseID != null && !processedPurchases.contains(purchaseID)) {
        processedPurchases.add(purchaseID); // Dodaj identyfikator zakupu do zbioru
        print("purchaseDetails: ${purchaseDetails.status}");
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
      }});
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