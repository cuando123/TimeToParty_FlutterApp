import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../../../main.dart';
import '../models/user_informations.dart';

class FirebaseService extends ChangeNotifier {
  //ogolnie wszedzie znaki zapytania bo inicjalizacja w tybie offline - same nulle sa
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  bool isConnected;

  FirebaseService({this.isConnected = false}) {
    if (!isConnected) {
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
    }
  }

  // Aktualizacja stanu połączenia
  void updateConnectionStatusIfConnected() {
      //print('Logika połączenia (np. ponowna autentykacja, odświeżenie danych)');
      _auth ??= FirebaseAuth.instance;
      _firestore ??= FirebaseFirestore.instance; //ponowne polaczenie i autentkacja gdy internet sie pojawi
      signInAnonymouslyAndSaveUID();//ponowne zalogowanie i zapis uid
      refreshCurrentUser(); //odswiezenie stanu uzytkoniwka aby nie zwracac null gdy apka sie odpali w trybie offline
     // print('Firebase: Zalogowane UID: ${currentUser?.uid}');
    notifyListeners();
  }

  User? get currentUser {
    return _auth?.currentUser;
  }

  Future<void> refreshCurrentUser() async {
    try {
      // Wymuszenie odświeżenia stanu użytkownika
      await _auth?.currentUser?.reload();
      notifyListeners(); // Poinformowanie o zmianie stanu
    } catch (e) {
     // print("Błąd podczas odświeżania danych użytkownika: $e");
    }
  }

  Future<void> signInAnonymouslyAndSaveUID() async {
    if (isConnected) {
      // Logika, gdy aplikacja jest w trybie offline
     // print("Próba logowania w trybie offline - nieudana.");
      return;
    }

    User? user = _auth?.currentUser;

    if (user == null) {
      try {
        UserCredential? userCredential = await _auth?.signInAnonymously();
        user = userCredential?.user;
       // print("Zalogowano anonimowo jako użytkownik o UID: ${user?.uid}");
      } catch (e) {
       // print("Błąd podczas logowania anonimowego: $e");
        return;
      }
    } else {
     // print("Użytkownik jest już zalogowany z UID: ${user.uid}");
    }

    if (user != null) {
      DocumentSnapshot userDoc = (await _firestore?.collection('users').doc(user.uid).get()) as DocumentSnapshot<Object?>;
      if (!userDoc.exists) {
        UserInformations newUser = UserInformations()
          ..userID = user.uid
          ..purchaseStatus = "free"
          ..createdUserDate = DateTime.now();

        await _firestore?.collection('users').doc(user.uid).set(newUser.toJson());
       // print('UID zapisany w Firestore');
      } else {
       // print('Dokument użytkownika już istnieje w Firestore');
      }
    }
  }

  Future<void> updateUserInformations(UserInformations userInfo) async {
    try {
      await _firestore?.collection('users').doc(userInfo.userID).set(userInfo.toJson(), SetOptions(merge: true));
      print('Informacje o użytkowniku zaktualizowane w Firebase');
    } catch (e) {
      print('Błąd podczas aktualizacji informacji użytkownika: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserData(String? userId) async {
    if (userId == null) return null;

    try {
      DocumentSnapshot userDoc = (await _firestore?.collection('users').doc(userId).get()) as DocumentSnapshot<Object?>;
      return userDoc.exists ? userDoc.data() as Map<String, dynamic>? : null;
    } catch (e) {
      print('Błąd podczas pobierania danych użytkownika: $e');
      return null;
    }
  }

// Zakładając, że masz metodę w FirebaseService, która pobiera dane użytkownika:
  Future<void> updateAndSaveUserSessionInfo() async {
    try {
      var userData = await getUserData(userInfo.userID);
      if (userData != null) {
        userInfo.howManyTimesRunApp = (userData['howManyTimesRunApp'] as int?) ?? 0;
      } else {
        userInfo.howManyTimesRunApp = 0;
      }

      userInfo.howManyTimesRunApp = (userInfo.howManyTimesRunApp ?? 0) + 1; //inkrementacja z warunkiem null?

      await updateUserInformations(userInfo);
    } catch (e) {
      print("Błąd podczas aktualizacji liczby uruchomień aplikacji: $e");
    }
  }

  Future<void> updateHowManyTimesFinishedGame() async {
    try {
      var userData = await getUserData(userInfo.userID);
      if (userData != null) {
        userInfo.howManyTimesFinishedGame = (userData['howManyTimesFinishedGame'] as int?) ?? 0;
      } else {
        userInfo.howManyTimesFinishedGame = 0;
      }

      userInfo.howManyTimesFinishedGame = (userInfo.howManyTimesFinishedGame ?? 0) + 1;

      await updateUserInformations(userInfo);
    } catch (e) {
      print("Błąd podczas aktualizacji liczby zakończeń gry: $e");
    }
  }

  Future<void> updateHowManyTimesRunInterstitialAd() async {
    try {
      var userData = await getUserData(userInfo.userID);
      if (userData != null) {
        userInfo.howManyTimesRunInstertitialAd = (userData['howManyTimesRunInstertitialAd'] as int?) ?? 0;
      } else {
        userInfo.howManyTimesRunInstertitialAd = 0;
      }

      userInfo.howManyTimesRunInstertitialAd = (userInfo.howManyTimesRunInstertitialAd ?? 0) + 1;

      await updateUserInformations(userInfo);
    } catch (e) {
      print("Błąd podczas aktualizacji liczby wyświetleń reklam interstycjalnych: $e");
    }
  }
// Dodatkowe funkcje, które będą robiły różne rzeczy w Firebase po zakupie, mogą być tutaj zaimplementowane.
}
