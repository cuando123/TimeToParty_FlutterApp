class Account {
  String? uid;
  int? bank;

  // Konstruktor z argumentami
  Account({this.uid, this.bank});

  // Konwersja obiektu Account na format JSON
  Map<String, dynamic> toJson() => {
    'uid': uid,
    'bank': bank,
  };

  // Konstruktor tworzący obiekt Account na podstawie snapshot
  Account.fromSnapshot(snapshot)
      : uid = snapshot.data()['uid'] as String?, // Rzutowanie na String?
        bank = snapshot.data()['bank'] as int?;  // Rzutowanie na int?
}
