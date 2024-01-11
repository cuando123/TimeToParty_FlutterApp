import 'package:game_template/src/in_app_purchase/services/firebase_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class IAPService {
  String uid;
  IAPService(this.uid);

  void listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList){


    purchaseDetailsList.forEach((purchaseDetails) async {
      if(purchaseDetails.status == PurchaseStatus.purchased || purchaseDetails.status == PurchaseStatus.restored){
        _handleSuccessfulPurchase(purchaseDetails);
      }
      if(purchaseDetails.status == PurchaseStatus.error){
        print(purchaseDetails.error!);
      }
      if(purchaseDetails.pendingCompletePurchase){ // ukonczony kompletny zakup
        await InAppPurchase.instance.completePurchase(purchaseDetails);
        print("Pruchase marked complete");
      }
    });
  }
  //+ z tego co on mowil nie da sie robic in app purchase z poziomu device z kompa, trzeba sie zalogowac na konto testowe normalnie na urzadzeniu i wtedy - tak bylo w apple Id a co z playstore?
  //Apple - Sandbox
  //dodatkowo chyba trzeba chwiliwo przystopowac z ogladaniem...
  //trzeba zrobic polaczenie z firebase i na razie te rzeczy ktore wiem o co chodzi, uprzadokowac to co juz jest z in app purchase oraz reklamami i firebase, pozniej przejdziemy do restore, szyfrowania i dalje
  // ale trzeba skupic sie na razie na tych rzeczach, bo jest tego duzo
  // trzeba rozkminic o co chodzi tutaj z tymi poprzednimi funkcjami, zrobic refactor i uporzadkowac to wszystko wraz z komentarzami odnosnie iap, firebase itd - tu trzeba wykorzystac changeNotifierProvidery i klase ktora to oganrie
  void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails){
    if (purchaseDetails.productID == "decisions_yt_5"){
    // on tutaj updejtuje pozniej do firebase service... itd np:
     // FirebaseService().increaseDecision(uid: uid, quantity: 5); - wywolanie funkcji firebasowej ktora zwieksza liczbe w firebase po zakupie, i na tej podstawie apka pobiera liczbe i updejtuje w apce - on mial na tej zasadzie mechanim
    } //itd... wszystkie rodzaje produktow tu dodajemy aby potem updejtowac dane rzeczy fajne np. increase decisons o 5
  }
}