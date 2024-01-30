class UserInformations {
  static final UserInformations _instance = UserInformations._internal();

  UserInformations._internal();

  factory UserInformations() {
    return _instance;
  }

  String? userID;
  String? purchaseStatus; //purchased, restored, free, cracked
  String? orderID;
  DateTime? createdUserDate;
  DateTime? purchaseDate;
  String? productID;
  int? finalSpendTimeOnGame; //spędzony czas w grze/aplikacji zanim ktoś opuści grę - pobierane z firebase i inkrementowane
  int? lastOneSpendTimeOnGame; // Czas spędzony w grze podczas ostatniej sesji - od zera zawsze
  int lastHowManyFieldReached = 0; //licznik pól - jak daleko drużyny zaszły w grze - to musi być za każdym razem nowe dawane, jestem w stanie zapisac tylko ostatni stan
  int? howManyTimesFinishedGame; //jak wiele razy użytkownik doszedł do końca gry, i czy w ogóle - pobierane z firebase i inkrementowane
  int? howManyTimesRunApp; //jak wiele razy aplikacja została uruchomiona przez danego użytkownika - pobierane z firebase i inkrementowane
  int? howManyTimesRunInstertitialAd; //jak wiele razy odpaliła się reklama instertial - pobierane z firebase i inkrementowane

  Map<String, dynamic> toJson() => {
    'userID': userID,
    'purchaseStatus': purchaseStatus,
    'purchaseID': orderID,
    'createdUserDate': createdUserDate?.toIso8601String(),
    'purchaseDate': purchaseDate?.toIso8601String(),
    'productID': productID,
    'finalSpendTimeOnGame': finalSpendTimeOnGame,
    'lastOneSpendTimeOnGame': lastOneSpendTimeOnGame,
    'lastHowManyFieldReached': lastHowManyFieldReached,
    'howManyTimesFinishedGame': howManyTimesFinishedGame,
    'howManyTimesRunApp': howManyTimesRunApp,
    'howManyTimesRunInstertitialAd': howManyTimesRunInstertitialAd,
  };
}
