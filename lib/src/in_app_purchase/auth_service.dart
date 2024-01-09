import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthService extends ChangeNotifier{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Future<User?> getOrCreateUser() async {
    if (currentUser == null){
     // await _firebaseAuth.signInAnonymously();
      //TO_DO dodac chcck czy jest internet
    }
    return currentUser;
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


  }