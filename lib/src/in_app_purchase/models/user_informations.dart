class UserInformations {
  static final UserInformations _instance = UserInformations._internal();

  UserInformations._internal();

  factory UserInformations() {
    return _instance;
  }

  String? userID;
  String? purchaseStatus; //purchased, restored, free, cracked
  String? purchaseID;
  String? createdUserDate;
  String? purchaseDate;
  String? productID;
  int? finalSpendTimeOnGame; //spędzony czas w grze/aplikacji zanim ktoś opuści grę - pobierane z firebase i inkrementowane
  int? lastOneSpendTimeOnGame; // Czas spędzony w grze podczas ostatniej sesji - od zera zawsze
  String lastHowManyFieldReached = ''; //licznik pól - jak daleko drużyny zaszły w grze - to musi być za każdym razem nowe dawane, jestem w stanie zapisac tylko ostatni stan
  int? howManyTimesFinishedGame; //jak wiele razy użytkownik doszedł do końca gry, i czy w ogóle - pobierane z firebase i inkrementowane
  int? howManyTimesRunApp; //jak wiele razy aplikacja została uruchomiona przez danego użytkownika - pobierane z firebase i inkrementowane
  int? howManyTimesRunInstertitialAd; //jak wiele razy odpaliła się reklama instertial - pobierane z firebase i inkrementowane
  String? lastPlayDate;
  String? lastNotificationClicked;

  Map<String, dynamic> toJson() => {
    'userID': userID,
    'purchaseStatus': purchaseStatus,
    'purchaseID': purchaseID,
    'createdUserDate': createdUserDate,
    'purchaseDate': purchaseDate,
    'productID': productID,
    'finalSpendTimeOnGame': finalSpendTimeOnGame,
    'lastOneSpendTimeOnGame': lastOneSpendTimeOnGame,
    'lastHowManyFieldReached': lastHowManyFieldReached,
    'howManyTimesFinishedGame': howManyTimesFinishedGame,
    'howManyTimesRunApp': howManyTimesRunApp,
    'howManyTimesRunInstertitialAd': howManyTimesRunInstertitialAd,
    'lastPlayDate': lastPlayDate,
    'lastNotificationClicked': lastNotificationClicked,
  };

  static UserInformations fromJson(Map<String, dynamic> json) {
    return UserInformations()
      ..userID = json['userID'] as String?
      ..purchaseStatus = json['purchaseStatus'] as String?
      ..purchaseID = json['purchaseID'] as String?
      ..createdUserDate = json['createdUserDate'] as String?
      ..purchaseDate = json['purchaseDate']as String?
      ..productID = json['productID'] as String?
      ..finalSpendTimeOnGame = json['finalSpendTimeOnGame'] as int?
      ..lastOneSpendTimeOnGame = json['lastOneSpendTimeOnGame'] as int?
      ..lastHowManyFieldReached = json['lastHowManyFieldReached'] as String
      ..howManyTimesFinishedGame = json['howManyTimesFinishedGame'] as int?
      ..howManyTimesRunApp = json['howManyTimesRunApp'] as int?
      ..howManyTimesRunInstertitialAd = json['howManyTimesRunInstertitialAd'] as int?
      ..lastPlayDate = json['lastPlayDate'] as String?
      ..lastNotificationClicked = json['lastNotificationClicked'] as String?;
  }
}
