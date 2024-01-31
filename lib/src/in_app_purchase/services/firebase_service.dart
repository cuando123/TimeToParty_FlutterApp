import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../../../main.dart';
import '../models/user_informations.dart';

class FirebaseService extends ChangeNotifier {
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  bool isConnected;

  FirebaseService({this.isConnected = false}) {
    if (!isConnected) {
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
    }
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
      userInfo
        .userID = user?.uid;
      try {
        UserCredential? userCredential = await _auth?.signInAnonymously();
        user = userCredential?.user;
        print("FirebaseService - Zalogowano anonimowo jako użytkownik o UID: ${user?.uid}");
      } catch (e) {
        print("FirebaseService - Błąd podczas logowania anonimowego: $e");
        return;
      }
    } else {
      userInfo
          .userID = user?.uid;
      print("FirebaseService - Użytkownik jest już zalogowany z UID: ${userInfo
          .userID}");
    }

    if (user != null) {
      DocumentSnapshot userDoc = await (_firestore?.collection('users').doc(user.uid).get() as Future<DocumentSnapshot<Object?>>);
      if (!userDoc.exists) {
        userInfo
          ..userID = user.uid
          ..purchaseStatus = "free"
          ..createdUserDate = DateFormat('yyyy-MM-dd – HH:mm').format(DateTime.now());
        await _firestore?.collection('users').doc(user.uid).set(userInfo.toJson());
        print('FirebaseService - UID zapisany w Firestore');
      } else {
        print('FirebaseService -Dokument użytkownika już istnieje w Firestore');
      }

      await loadCurrentUserInformations(); // Ładowanie informacji o aktualnym użytkowniku
    }
  }

  Future<void> loadCurrentUserInformations() async {
    User? user = _auth?.currentUser;
    if (user != null) {
      print('FirebaseService - loadCurrentUserInformations done: user: $user');
      userInfo = (await getUserInformations(user.uid))!;
      print('FirebaseService - loadCurrentUserInformations - getUserInformations: ${userInfo.createdUserDate}, ${userInfo.purchaseStatus}, ${userInfo.finalSpendTimeOnGame}, ${userInfo.howManyTimesFinishedGame}, ${userInfo.howManyTimesRunApp}, ${userInfo.howManyTimesRunInstertitialAd}, ${userInfo.lastHowManyFieldReached}, ${userInfo.lastOneSpendTimeOnGame},  ${userInfo.userID}, ${userInfo.purchaseDate}, ${userInfo.orderID}');
      notifyListeners();
    }
  }

  Future<UserInformations?> getUserInformations(String userId) async {
    try {
      DocumentSnapshot userDoc = await (_firestore?.collection('users').doc(userId).get() as Future<DocumentSnapshot<Object?>>);
      if (userDoc.exists) {
        return UserInformations.fromJson(userDoc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('FirebaseService - Błąd podczas pobierania informacji o użytkowniku: $e');
    }
    return null;
  }

  Future<void> updateUserInformations(UserInformations userInfo) async {
    try {
      await _firestore?.collection('users').doc(userInfo.userID).set(userInfo.toJson(), SetOptions(merge: true));
      print('FirebaseService - updateUserInformations Informacje o użytkowniku ${userInfo.userID} zaktualizowane w Firebase');
    } catch (e) {
      print('FirebaseService - Błąd podczas aktualizacji informacji użytkownika: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserData(String? userId) async { // to sie nie wykonalo nigdy ?
    if (userId == null) return null;

    try {
      DocumentSnapshot userDoc = await (_firestore?.collection('users').doc(userId).get() as Future<DocumentSnapshot<Object?>>);
      return userDoc.exists ? userDoc.data() as Map<String, dynamic>? : null;
    } catch (e) {
      print('FirebaseService - Błąd podczas pobierania danych użytkownika: $e');
      return null;
    }
  }

  Future<void> updateAndSaveUserSessionInfo() async {
    try {
      if (userInfo != null) {
        userInfo!.howManyTimesRunApp = (userInfo!.howManyTimesRunApp ?? 0) + 1;
        await updateUserInformations(userInfo!);
      }
    } catch (e) {
      //print("Błąd podczas aktualizacji liczby uruchomień aplikacji: $e");
    }
  }

  Future<void> updateHowManyTimesFinishedGame() async {
    try {
      if (userInfo != null) {
        userInfo!.howManyTimesFinishedGame = (userInfo!.howManyTimesFinishedGame ?? 0) + 1;
        print('FirebaseService - updateHowManyTimesFinishedGame: ${userInfo!.howManyTimesFinishedGame}');
        await updateUserInformations(userInfo!);
      }
    } catch (e) {
      print("FirebaseService - Błąd podczas aktualizacji liczby zakończeń gry: $e");
    }
  }

  Future<void> updateHowManyTimesRunInterstitialAd() async {
    try {
      if (userInfo != null) {
        userInfo!.howManyTimesRunInstertitialAd = (userInfo!.howManyTimesRunInstertitialAd ?? 0) + 1;
        print('FirebaseService - howManyTimesRunInstertitialAd: ${userInfo!.howManyTimesRunInstertitialAd}');
        await updateUserInformations(userInfo!);
      }
    } catch (e) {
      print("FirebaseService -Błąd podczas aktualizacji liczby wyświetleń reklam interstycjalnych: $e");
    }
  }

// Tutaj można dodać inne metody związane z Firebase.
}
