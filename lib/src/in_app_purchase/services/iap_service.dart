import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart' as asn1lib;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pointycastle/pointycastle.dart';

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
  Future<void> setPurchased(bool value, PurchaseDetails purchaseDetails) async {
    _isPurchased = value;
    var purchaseState = PurchaseState(); // Ustawienie stanu zakupu w klasie tamtej
    purchaseState.isPurchased = true;
    notifyListeners();
    if (purchaseDetails.productID == "timetoparty.fullversion.test"){
      // tu będzie do przestawienia flaga w firebase i updejty
    //oraz wywolanie callbacku np do wyswietlenia alertdialoga
    if (purchaseCompleteCallback != null) {
      purchaseCompleteCallback();
    }
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
      print("Zakupy przywrócone");
    } catch (e) {
      print("Błąd przy przywracaniu zakupów: $e");
    }
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
            await setPurchased(true, purchaseDetails);
            purchaseCompleteCallback.call();
          } else {
            // Obsługa nieudanej weryfikacji
            print("Weryfikacja zakupu nieudana");
            purchaseCompleteCallback.call();
          }
          break;
        case PurchaseStatus.error:
        // Obsługa błędów zakupu - karta zawsze odrzuca
          print("Błąd zakupu: ${purchaseDetails.error?.message}");
          billingResponsesErrors = purchaseDetails.error!.message;
          purchaseErrorsCallback.call();
          break;
        case PurchaseStatus.pending:
        // Obsługa zakupów oczekujących
          print("Zakup oczekujący");
          //pododawac billingResponsesErrors = dane tutaj BillingResponses od danego problemu...
          purchaseCompleteCallback.call();
          break;
        default:
        // Obsługa innych stanów zakupu
          print("Nieobsłużony status zakupu: ${purchaseDetails.status}");
          purchaseCompleteCallback.call();
          break;
      }

      if (purchaseDetails.pendingCompletePurchase) {
        // Ukończenie zakupu
        await InAppPurchase.instance.completePurchase(purchaseDetails);
        print("Zakup oznaczony jako kompletny");
        purchaseCompleteCallback.call();
      }
    });
  }

  RSAPublicKey parsePublicKey(String base64PublicKey) {
    Uint8List publicKeyDER = base64.decode(base64PublicKey);
    asn1lib.ASN1Parser parser = asn1lib.ASN1Parser(publicKeyDER);

    asn1lib.ASN1Sequence topLevelSeq = parser.nextObject() as asn1lib.ASN1Sequence;

    // Pobieramy bit string, który zawiera właściwą sekwencję klucza
    asn1lib.ASN1BitString publicKeyBitString = topLevelSeq.elements![1] as asn1lib.ASN1BitString;

    // Parsujemy zawartość bit stringa, aby uzyskać sekwencję klucza
    asn1lib.ASN1Parser publicKeyParser = asn1lib.ASN1Parser(publicKeyBitString.contentBytes()!);
    asn1lib.ASN1Sequence publicKeySeq = publicKeyParser.nextObject() as asn1lib.ASN1Sequence;

    // Pobieramy wartości modułu i wykładnika z sekwencji klucza
    asn1lib.ASN1Integer modulusAsn1 = publicKeySeq.elements![0] as asn1lib.ASN1Integer;
    asn1lib.ASN1Integer exponentAsn1 = publicKeySeq.elements![1] as asn1lib.ASN1Integer;

    BigInt modulus = modulusAsn1.intValue! as BigInt;
    BigInt exponent = exponentAsn1.intValue! as BigInt;

    return RSAPublicKey(modulus, exponent);
  }

  bool _verifyPurchase(PurchaseDetails purchaseDetails) {
    String base64PublicKey  = 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAz+s/7/8sbjGmlmYpTYwv05NNOsrAJoKoUU/VyDN1yqYw5bq1oDhBM+VAhUQS5aztIDurMa28p8gwQkg36tJrn1GXnVnLCooKrc6qjQbaTaiIt8LuYlTjvP73mS5MW+mFmhj1IjPyxic7dHku4/7lc9LwiWAPR3T+HgpA9oScz/HmgDIM0KS2Zq7WznnxqMbB5c1Zs6fEr1LmJ3KwOHfHTlZH7q8ZEojQkcW1JwLSLhUSDnLAd/hXNjsK81TYgoV5x3lOv14II6l7frPGYG105qiwqOwIufeTaCy32FTW3zQr5hrTDho8UBSKuUu8phOuaZ46juqDbicjU8cemAGqmQIDAQAB';

    // Pobranie danych zakupu i podpisu
    Uint8List purchaseDataBytes = Uint8List.fromList(purchaseDetails.verificationData.source.codeUnits);

    // Konwersja publicKeyBytes do RSAPublicKey
    RSAPublicKey publicKey = parsePublicKey(base64PublicKey); // Implementacja konwersji binarnej do RSAPublicKey

    // Pobranie danych zakupu i podpisu
    Uint8List signatureBytes = base64.decode(purchaseDetails.verificationData.localVerificationData);

    try {
    // Inicjalizacja obiektu Signer
    Signer signer = Signer("SHA-256/RSA");
    signer.init(false, PublicKeyParameter<RSAPublicKey>(publicKey));

    // Utworzenie obiektu Signature
    RSASignature signature = RSASignature(signatureBytes);

    // Weryfikacja podpisu
    return signer.verifySignature(purchaseDataBytes, signature);
    } catch (e) {
    print("Weryfikacja zakupu nie powiodła się: $e");
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