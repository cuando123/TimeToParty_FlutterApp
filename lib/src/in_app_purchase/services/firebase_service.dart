import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

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
      print('Logika połączenia (np. ponowna autentykacja, odświeżenie danych)');
      _auth ??= FirebaseAuth.instance;
      _firestore ??= FirebaseFirestore.instance; //ponowne polaczenie i autentkacja gdy internet sie pojawi
      signInAnonymouslyAndSaveUID();//ponowne zalogowanie i zapis uid
      refreshCurrentUser(); //odswiezenie stanu uzytkoniwka aby nie zwracac null gdy apka sie odpali w trybie offline
      print('Firebase: Zalogowane UID: ${currentUser?.uid}');
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
      print("Błąd podczas odświeżania danych użytkownika: $e");
    }
  }

  Future<void> signInAnonymouslyAndSaveUID() async {
    if (isConnected) {
      // Logika, gdy aplikacja jest w trybie offline
      print("Próba logowania w trybie offline - nieudana.");
      return;
    }

    User? user = _auth?.currentUser;

    if (user == null) {
      try {
        UserCredential? userCredential = await _auth?.signInAnonymously();
        user = userCredential?.user;
        print("Zalogowano anonimowo jako użytkownik o UID: ${user?.uid}");
      } catch (e) {
        print("Błąd podczas logowania anonimowego: $e");
        return;
      }
    } else {
      print("Użytkownik jest już zalogowany z UID: ${user.uid}");
    }

    if (user != null) {
      DocumentSnapshot userDoc = (await _firestore?.collection('users').doc(user.uid).get()) as DocumentSnapshot<Object?>;
      if (!userDoc.exists) {
        UserInformations newUser = UserInformations()
          ..userID = user.uid
          ..isPurchased = false
          ..createdUserDate = DateTime.now();

        await _firestore?.collection('users').doc(user.uid).set(newUser.toJson());
        print('UID zapisany w Firestore');
      } else {
        print('Dokument użytkownika już istnieje w Firestore');
      }
    }
  }

  Future<void> setPurchasedFlag() async {
    if (isConnected) {
      // Logika, gdy aplikacja jest w trybie offline
      print("Próba ustawienia flagi zakupu w trybie offline - nieudana.");
      return;
    }

    User? user = _auth?.currentUser;
    if (user == null) {
      print('Użytkownik nie jest zalogowany.');
      return;
    }

    try {
      DocumentReference userDocRef = _firestore?.collection('users').doc(user.uid) as DocumentReference<Object?>;
      await userDocRef.update({'isPurchased': true});
      print('Flaga isPurchased została ustawiona na true.');
    } catch (e) {
      print('Błąd podczas ustawiania flagi isPurchased: $e');
    }
  }

// Dodatkowe funkcje, które będą robiły różne rzeczy w Firebase po zakupie, mogą być tutaj zaimplementowane.
}
