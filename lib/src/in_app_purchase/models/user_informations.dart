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

  static UserInformations fromJson(Map<String, dynamic> json) {
    return UserInformations()
      ..userID = json['userID'] as String?
      ..purchaseStatus = json['purchaseStatus'] as String?
      ..orderID = json['purchaseID'] as String?
      ..createdUserDate = json['createdUserDate'] != null ? DateTime.parse(json['createdUserDate'] as String) : null
      ..purchaseDate = json['purchaseDate'] != null ? DateTime.parse(json['purchaseDate'] as String) : null
      ..productID = json['productID'] as String?
      ..finalSpendTimeOnGame = json['finalSpendTimeOnGame'] as int?
      ..lastOneSpendTimeOnGame = json['lastOneSpendTimeOnGame'] as int?
      ..lastHowManyFieldReached = json['lastHowManyFieldReached'] as int? ?? 0
      ..howManyTimesFinishedGame = json['howManyTimesFinishedGame'] as int?
      ..howManyTimesRunApp = json['howManyTimesRunApp'] as int?
      ..howManyTimesRunInstertitialAd = json['howManyTimesRunInstertitialAd'] as int?;
  }
}
