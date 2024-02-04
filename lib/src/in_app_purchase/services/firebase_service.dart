import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:game_template/src/in_app_purchase/models/shared_preferences_helper.dart';
import 'package:intl/intl.dart';

class FirebaseService extends ChangeNotifier {
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  bool isConnected;
//TO_DO skonfigurowac reguly dla zapisu/odczytu danych z firebase

  FirebaseService({this.isConnected = false}) {
    if (!isConnected) {
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
    }
    print("FirebaseService instance hashCode: $hashCode");
  }

  void updateConnectionStatusIfConnected() {
    //print('Logika połączenia (np. ponowna autentykacja, odświeżenie danych)');
    _auth ??= FirebaseAuth.instance;
    _firestore ??= FirebaseFirestore.instance;
    signInAnonymouslyAndSaveUID();
    refreshCurrentUser();
    //print('Firebase: Zalogowane UID: ${currentUser?.uid}');
    notifyListeners();
  }

  User? get currentUser {
    return _auth?.currentUser;
  }

  Future<void> refreshCurrentUser() async {
    try {
      await _auth?.currentUser?.reload();
      print('FirebaseService - refreshCurrentUser done');
      notifyListeners();
    } catch (e) {
      //print("Błąd podczas odświeżania danych użytkownika: $e");
    }
  }

  Future<void> signInAnonymouslyAndSaveUID() async {
    if (isConnected) {
      print("FirebaseService - Próba logowania w trybie offline - nieudana.");
      return;
    }

    User? user = _auth?.currentUser;

    if (user == null) {
      await SharedPreferencesHelper.setUserID(user?.uid);
      try {
        UserCredential? userCredential = await _auth?.signInAnonymously();
        user = userCredential?.user;
        print("FirebaseService - Zalogowano anonimowo jako użytkownik o UID: ${user?.uid}");
      } catch (e) {
        print("FirebaseService - Błąd podczas logowania anonimowego: $e");
        return;
      }
    } else {
      await SharedPreferencesHelper.setUserID(user.uid);
      print("FirebaseService - Użytkownik jest już zalogowany z UID: ${SharedPreferencesHelper.getUserID()}");
    }

    if (user != null) {
      DocumentSnapshot userDoc = await (_firestore?.collection('users').doc(user.uid).get() as Future<DocumentSnapshot<Object?>>);
      if (!userDoc.exists) {
        await SharedPreferencesHelper.setUserID(user.uid);
        await SharedPreferencesHelper.setPurchaseStatus("free");
        await SharedPreferencesHelper.setCreatedUserDate(DateFormat('yyyy-MM-dd – HH:mm').format(DateTime.now()));
        Map<String, dynamic> toJson() => {
          'userID': SharedPreferencesHelper.getUserID(),
          'purchaseStatus': SharedPreferencesHelper.getPurchaseStatus(),
          'createdUserDate': SharedPreferencesHelper.getCreatedUserDate(),
        };
        await _firestore?.collection('users').doc(user.uid).set(toJson()); //toJson stąd
        print('FirebaseService - UID zapisany w Firestore');
      } else {
        print('FirebaseService -Dokument użytkownika już istnieje w Firestore');
      }

    }
  }

  Future<void> updateUserInformations(String? userId, String fieldName, dynamic value) async {
    try {
      await _firestore?.collection('users').doc(userId).update({fieldName: value});
      print('FirebaseService - updateSpecificField Pole $fieldName użytkownika $userId zaktualizowane w Firebase');
    } catch (e) {
      print('FirebaseService - Błąd podczas aktualizacji pola $fieldName użytkownika: $e');
    }
  }

// Tutaj można dodać inne metody związane z Firebase.
}
