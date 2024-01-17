import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pointycastle/pointycastle.dart';

import '../models/purchase_state.dart';

class IAPService extends ChangeNotifier{
  // cd. https://pub.dev/packages/in_app_purchase/example
  // and: https://www.youtube.com/watch?v=w7oqVDGMMJU
  late String uid;

  bool _isPurchased = false;
  bool get isPurchased => _isPurchased;

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription; //inicjalizacja i subskrypcja strumienia aktualizacji zakupow
  bool _isAvailable = false;
  final List<ProductDetails> _products = [];
  IAPService(InAppPurchase instance);

  late Function purchaseCompleteCallback;

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  void onPurchaseComplete(Function callback) {
    // rejestracja callbacku
    purchaseCompleteCallback = callback;
  }
  Future<void> setPurchased(bool value) async {
    _isPurchased = value;
    var purchaseState = PurchaseState();
    purchaseState.isPurchased = true; // Ustawienie stanu zakupu
    notifyListeners();

    // tu będzie do przestawienia flaga w firebase
    // await buy();???? // jeszce nie wiem czy tu wywolac?
  }

  void _deliverProduct(PurchaseDetails purchaseDetails){ //convert to product list?
    if (purchaseDetails.productID == "com.frydoapps.timetoparty.fullversion"){
      // on tutaj updejtuje pozniej do firebase service... itd np:

    }
    if (purchaseCompleteCallback != null) {
      purchaseCompleteCallback();
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
          bool isValid = await _verifyPurchase(purchaseDetails);
          if (isValid) {
            _deliverProduct(purchaseDetails);
            print("Zakup zweryfikowany i dostarczony");
          } else {
            // Obsługa nieudanej weryfikacji
            print("Weryfikacja zakupu nieudana");
          }
          break;
        case PurchaseStatus.error:
        // Obsługa błędów zakupu
          print("Błąd zakupu: ${purchaseDetails.error}");
          break;
        case PurchaseStatus.pending:
        // Obsługa zakupów oczekujących
          print("Zakup oczekujący");
          break;
        default:
        // Obsługa innych stanów zakupu
          print("Nieobsłużony status zakupu: ${purchaseDetails.status}");
          break;
      }

      if (purchaseDetails.pendingCompletePurchase) {
        // Ukończenie zakupu
        await InAppPurchase.instance.completePurchase(purchaseDetails);
        print("Zakup oznaczony jako kompletny");
      }
    });
  }


  RSAPublicKey parsePublicKey(String base64PublicKey) {
    Uint8List publicKeyDER = base64.decode(base64PublicKey);
    ASN1Parser parser = ASN1Parser(publicKeyDER);

    ASN1Sequence topLevelSeq = parser.nextObject() as ASN1Sequence;
    ASN1Sequence publicKeySeq = topLevelSeq.elements?[1] as ASN1Sequence;

    ASN1Integer modulusAsn1 = publicKeySeq.elements?[0] as ASN1Integer;
    ASN1Integer exponentAsn1 = publicKeySeq.elements?[1] as ASN1Integer;

    BigInt modulus = modulusAsn1.integer!;
    BigInt exponent = exponentAsn1.integer!;

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