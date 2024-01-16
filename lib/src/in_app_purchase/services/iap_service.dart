import 'package:flutter/cupertino.dart';
import 'package:game_template/src/in_app_purchase/services/firebase_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../app_lifecycle/TranslationProvider.dart';
import '../models/purchase_state.dart';


class IAPService extends ChangeNotifier{
  late String uid;

  bool _isPurchased = false;
  bool get isPurchased => _isPurchased;

  IAPService(InAppPurchase instance, TranslationProvider translationProvider);

  Future<void> setPurchased(bool value) async {
    _isPurchased = value;
    var purchaseState = PurchaseState();
    purchaseState.isPurchased = true; // Ustawienie stanu zakupu
    notifyListeners();

    // tu będzie do przestawienia flaga w firebase
    // await buy();
  }

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
  void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails){
    if (purchaseDetails.productID == "decisions_yt_5"){
    // on tutaj updejtuje pozniej do firebase service... itd np:
     // FirebaseService().increaseDecision(uid: uid, quantity: 5); - wywolanie funkcji firebasowej ktora zwieksza liczbe w firebase po zakupie, i na tej podstawie apka pobiera liczbe i updejtuje w apce - on mial na tej zasadzie mechanim
    }
  }
}