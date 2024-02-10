import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';

import '../../app_lifecycle/TranslationProvider.dart';
import '../models/purchase_state.dart';
import '../models/shared_preferences_helper.dart';
import 'firebase_service.dart';

class IAPService extends ChangeNotifier {
  // cd. https://pub.dev/packages/in_app_purchase/example
  // and: https://www.youtube.com/watch?v=w7oqVDGMMJU
  late String uid;
  String _purchaseStatusMessage = '';
  String get purchaseStatusMessage => _purchaseStatusMessage;

  bool _isPurchased = false;
  bool get isPurchased => _isPurchased;
  late bool _isLoading = false;
  bool get isLoading => _isLoading;
  final FirebaseService _firebaseService;
  late TranslationProvider translationProvider;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>>
      _subscription; //inicjalizacja i subskrypcja strumienia aktualizacji zakupow
  bool _subscriptionInitialized = false;
  bool _isAvailable = false;
  final List<ProductDetails> _products = [];
  IAPService(InAppPurchase instance, this.translationProvider, this._firebaseService) {
   // print("IAPService received FirebaseService instance hashCode: ${_firebaseService.hashCode}");
  }
  var purchaseState = PurchaseState();
  PurchaseDetails? _purchaseDetails;

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

  Future<void> setPurchased(bool isPurchased, bool isMainMenu) async {
    if (!isPurchased) {
      _isPurchased = false;
      purchaseState.isPurchased = false;
      notifyListeners();
      //setPurchaseStatusMessage("BillingResponse.itemNotOwned");
      await translationProvider.loadWords();
      await SharedPreferencesHelper.savePurchaseState(false);
    } else {
      if (!isMainMenu) {
        // w main menu sprawdzam w przypadku offline czy dac uzytkownikowi dostep na podstawie sharedPreferences
        if (_purchaseStatusMessage != "PurchaseRestored") {
          setPurchaseStatusMessage("PurchaseSuccess");
          await SharedPreferencesHelper.setPurchaseStatus("purchased");
          await _firebaseService.updateUserInformations(
              await SharedPreferencesHelper.getUserID(), 'purchaseStatus', "purchased");
         // print("zaladowalem purchased do firebase");
        } else {
          await SharedPreferencesHelper.setPurchaseStatus("restored");
          await _firebaseService.updateUserInformations(
              await SharedPreferencesHelper.getUserID(), 'purchaseStatus', "restored");
        }
        //jezeli nie jest main menu ustawiam im ID (np przy restore lub przy purchased)
        await SharedPreferencesHelper.setPurchaseID(_purchaseDetails?.purchaseID);
        await SharedPreferencesHelper.setProductID(_purchaseDetails?.productID);
        await _firebaseService.updateUserInformations(
            await SharedPreferencesHelper.getUserID(), 'purchaseID', _purchaseDetails?.purchaseID);
        await _firebaseService.updateUserInformations(
            await SharedPreferencesHelper.getUserID(), 'productID', _purchaseDetails?.productID);
        String? purchaseDate = await SharedPreferencesHelper.getPurchaseDate();
        if (purchaseDate != null)
          await _firebaseService.updateUserInformations(
              await SharedPreferencesHelper.getUserID(), 'purchaseDate', purchaseDate.toString());
        await SharedPreferencesHelper.setPurchaseDate(DateFormat('yyyy-MM-dd – HH:mm').format(DateTime.now()));
        await SharedPreferencesHelper.savePurchaseState(true); // to tez tylko raz powinno sie wykonac
      }
      // niezaleznie czy jest main menu czy tez nie ustawiam purchase state i ładuje slowa - jesli raz zaladuje do shared powinno dzialac ok
      _isPurchased = true;
      purchaseState.isPurchased = true; // Ustawienie stanu zakupu w klasie tamtej do translations providera only
      notifyListeners();
      isLoading = false;
      await translationProvider.loadWords();
    }
  }

  void initializePurchaseStream() {
    //print("wywolanie subskrypcji");
    if (!_subscriptionInitialized) {
      final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
      _subscription = purchaseUpdated.listen((purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      }, onError: (error) {
       // print("error z initialize purchase stream $error");
      });
      _subscriptionInitialized = true;
    }
    //print("koniec wywolanie subskrypcji");
  }

// Inicjalizacja informacji o sklepie i dostępnych produktach.
  Future<void> initStoreInfo(List<String> productIds) async {
    try {
      _isAvailable = await _inAppPurchase.isAvailable();
      if (!_isAvailable) {
       // print("Skelp nie jest dostepny");
        return;
      }
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds.toSet());
      if (response.error != null) {
      //  print('Inicjalizacja sklepu: blad ${response.error}');
        return;
      }
      // Dodanie pobranych szczegółów produktu do listy _products
      _products.addAll(response.productDetails);
    } finally {}
  }

  // Funkcja do przywracania zakupów
  Future<bool> restorePurchases() async {
    isLoading = true;
    bool restoreSuccessful = false;
    bool isTimeout = false;
    //print("Poczatel wywolania restorePurchases");
    try {
      await _inAppPurchase.restorePurchases();
      if (_inAppPurchase.restorePurchases() != null) {
        restoreSuccessful = true;
      }
      // Tworzenie timera
      var timer = Timer(Duration(seconds: 30), () {
        if (!restoreSuccessful) {
         //print("Timeout - BillingResponse.timeout");
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
     // print("Błąd przy przywracaniu zakupów: $e");
      setPurchaseStatusMessage(e.toString());
    } finally {
      isLoading = false;
      if (isTimeout) {
        setPurchaseStatusMessage("BillingResponse.timeout");
      }
      if (restoreSuccessful) {
        setPurchaseStatusMessage("PurchaseRestored");
        await SharedPreferencesHelper.setPurchaseID(_purchaseDetails?.purchaseID);
        await SharedPreferencesHelper.setPurchaseStatus("restored");

        await _firebaseService.updateUserInformations(
            await SharedPreferencesHelper.getUserID(), 'purchaseID', _purchaseDetails?.purchaseID);
        await _firebaseService.updateUserInformations(
            await SharedPreferencesHelper.getUserID(), 'purchaseStatus', "restored");
      }
      //print("Koniec procesu przywracania zakupów");
    }
    //print("koniec wywolania restorePurchases");

    return restoreSuccessful;
  }

//czekaj na dokonczenie transakcji
  Future<bool> waitForPurchaseCompletion(PurchaseDetails purchaseDetails, Duration timeout) async {
    final startTime = DateTime.now();
    try {
      while (DateTime.now().difference(startTime) < timeout) {
        if (purchaseDetails.status == PurchaseStatus.purchased || purchaseDetails.status == PurchaseStatus.error) {
          return _verifyPurchase(purchaseDetails);
        }
        // Czekaj przez krótki czas przed kolejnym sprawdzeniem
        await Future.delayed(Duration(seconds: 1));
      }
      //print("Timeout - status zakupu nie został potwierdzony");
      return false;
    } finally {
      //print("completion DONE");
    }
  }

  Set<String> processedPurchases = {};

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((purchaseDetails) async {
      String? purchaseID = purchaseDetails.purchaseID;
      //print("processedpurchases: $processedPurchases");
      if (purchaseID != null && !processedPurchases.contains(purchaseID)) {
        processedPurchases.add(purchaseID); // Dodaj identyfikator zakupu do zbioru
        //print("purchaseDetails: ${purchaseDetails.status}");
        //print("_listenToPurchaseUpdated true");
        isLoading = true;
        switch (purchaseDetails.status) {
          case PurchaseStatus.purchased:
          case PurchaseStatus.restored:
            // Weryfikacja zakupu przed dostarczeniem produktu
            bool isValid = _verifyPurchase(purchaseDetails);
            if (isValid) {
              //print("Zakup zweryfikowany i dostarczony");
              await setPurchased(true, false);
            } else {
              // Obsługa nieudanej weryfikacji
              //print("Weryfikacja zakupu nieudana");
              setPurchaseStatusMessage(purchaseDetails.error!.message);
              isLoading = false;
            }
            break;
          case PurchaseStatus.error:
            //print("Błąd zakupu: ${purchaseDetails.error?.message}");
            setPurchaseStatusMessage(purchaseDetails.error!.message);
            isLoading = false;
            break;
          case PurchaseStatus.pending:
            //print("Zakup oczekujący, oczekiwanie na potwierdzenie...");
            bool isCompleted = await waitForPurchaseCompletion(purchaseDetails, Duration(minutes: 5));
            if (isCompleted) {
              try {
                // Ukończenie zakupu
                await InAppPurchase.instance.completePurchase(purchaseDetails);
                bool isValid = _verifyPurchase(purchaseDetails);
                if (isValid) {
                  //print("Zakup zweryfikowany i dostarczony");
                  await setPurchased(true, false);
                  break;
                } else {
                  //print("Weryfikacja zakupu nieudana");
                  setPurchaseStatusMessage(purchaseDetails.error!.message);
                  isLoading = false;
                }
              } catch (e) {
                //print("Błąd podczas finalizowania zakupu: $e");
                setPurchaseStatusMessage(purchaseDetails.error!.message);
                isLoading = false;
              }
            } else {
              //print("Zakup nie został zakończony w odpowiednim czasie");
              setPurchaseStatusMessage(purchaseDetails.status.toString());
              isLoading = false;
            }
            break;
          default:
            //print("Nieobsłużony status zakupu: ${purchaseDetails.status}");
            setPurchaseStatusMessage(purchaseDetails.status.toString());
            isLoading = false;
            break;
        }
      }
    });
  }

  bool _verifyPurchase(PurchaseDetails purchaseDetails) {
    _purchaseDetails = purchaseDetails;
    // Pobranie i parsowanie danych zakupu
    var localVerificationData = json.decode(purchaseDetails.verificationData.localVerificationData);
    //print("localVerificationData JSON: $localVerificationData");

    String? localPurchaseToken = localVerificationData['purchaseToken'] as String;
    //print("localPurchaseToken: $localPurchaseToken");
    if (localPurchaseToken == null) {
      //print("Brak purchaseToken w danych lokalnych.");
      return false;
    }

    String serverPurchaseToken = purchaseDetails.verificationData.serverVerificationData;
    if (serverPurchaseToken.isEmpty) {
      //print("Brak purchaseToken w danych serwerowych.");
      return false;
    }

    // Porównanie całych tokenów zakupu
    if (localPurchaseToken == serverPurchaseToken) {
      // Zapisanie danych zakupu do modelu
      //print("Tokeny są zgodne!");
      return true;
    } else {
      //print("Tokeny zakupu nie są zgodne.");
      SharedPreferencesHelper.setPurchaseStatus("cracked");
      return false;
    }
  }

  void buyProduct(List<String> productIds) {
    //print("buyProduct true");
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
          //print("Nie znaleziono szczegółów produktu dla ID: $productId");
          isLoading = false; // Kończy ładowanie jeśli nie znaleziono produktu
        }
      }
    } catch (e) {
      //print("error $e");
      isLoading = false; // Kończy ładowanie w przypadku błędu
    }
  }

  // Zwalnianie zasobów.
  void dispose() {
    _subscription.cancel();
  }
/*
  Future<bool> verifyPurchaseOnline() async {
    bool isAvailable = await InAppPurchase.instance.isAvailable();
    if (!isAvailable) {
      print("Sklep nie jest dostępny");
      return false;
    }

    bool restoreSuccessful = false;
    try {
      await InAppPurchase.instance.restorePurchases();
      // Ustawienie timeout dla operacji przywracania
      final completer = Completer<bool>();
      var subscription = _inAppPurchase.purchaseStream.listen((purchaseDetailsList) {
        for (var purchase in purchaseDetailsList) {
          if (purchase.status == PurchaseStatus.restored || purchase.status == PurchaseStatus.purchased) {
            if (!_verifyPurchase(purchase)) {
              // Niepowodzenie weryfikacji jednego z zakupów
              completer.complete(false);
            }
          }
        }
        // Wszystkie zakupy zostały pomyślnie zweryfikowane
        restoreSuccessful = true;
        completer.complete(true);
      });

      // Czekanie na zakończenie operacji przywracania
      restoreSuccessful = await completer.future.timeout(Duration(seconds: 30), onTimeout: () {
        print("Timeout - operacja przywracania zakupów nie została zakończona w odpowiednim czasie");
        return false;
      });

      subscription.cancel();
      return restoreSuccessful;
    } catch (e) {
      print("Wystąpił błąd podczas weryfikacji zakupów online: $e");
      return false;
    }
  }
*/
}
