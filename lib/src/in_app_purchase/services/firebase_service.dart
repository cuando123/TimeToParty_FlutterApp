import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class FirebaseService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signInAnonymouslyAndSaveUID() async {
    User? user = _auth.currentUser;

    // Sprawdzamy, czy użytkownik jest już zalogowany
    if (user == null) {
      try {
        // Uwierzytelnianie użytkownika anonimowo
        UserCredential userCredential = await _auth.signInAnonymously();
        user = userCredential.user;
        print("Zalogowano anonimowo jako użytkownik o UID: ${user?.uid}");
      } catch (e) {
        print("Błąd podczas logowania anonimowego: $e");
        return;
      }
    } else {
      print("Użytkownik jest już zalogowany z UID: ${user.uid}");
    }

    if (user != null) {
      // Sprawdzamy, czy dokument już istnieje
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        // Jeśli dokument nie istnieje, tworzymy nowy dokument
        await _firestore.collection('users').doc(user.uid).set({
          'createdAt': FieldValue.serverTimestamp(), // Zapisujemy timestamp serwera
        });
        print('UID zapisany w Firestore');
      } else {
        print('Dokument użytkownika już istnieje w Firestore');
      }
    }
  }

  Future<void> initializeAccount() async {
    // Uzyskaj referencję do dokumentu użytkownika
    DocumentReference document = FirebaseFirestore.instance.collection('users').doc(currentUser?.uid);

    // Pobierz dokument i sprawdź, czy istnieje
    DocumentSnapshot documentSnapshot = await document.get();
    if (!documentSnapshot.exists) {
      // Jeśli dokument nie istnieje, ustaw początkową wartość 'bank'
      await document.set({"bank": 3});
    }
  }
/*
  setAccountType({uid, type}){
    FirebaseFirestore.instance.collection("users").doc(uid).update({
      type true
      next free question date time now

    }
END NA 5h filmu
    )
  }
  */
  //TO_DO funkcje ktore beda robily rozne rzeczy w firebase po zakupie

  //example:
  /*
  increaseDecision({uid,quantity}) {
    FirebaseFirestore.instance.collection("users").doc(uid).update({
      'bank': FieldValue.increment(quantity),
      'nextFreeQuestion': DateTime.now(),
    });
  }*/
}

class UserInFirebase {
  bool? isPurchased;
  String? purchaseID;
  DateTime? createdDate;
  String? productID;
  String? amount;
  String? currency;

  UserInFirebase();
}