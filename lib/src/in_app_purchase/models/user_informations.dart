class UserInformations {
  String? userID;
  String? purchaseStatus; //purchased, restored, free, cracked
  String? orderID;
  DateTime? createdUserDate;
  DateTime? purchaseDate;
  String? productID;
  int? finalSpendTimeOnGame; //spędzony czas w grze/aplikacji zanim ktoś opuści grę
  int? howManyFieldReached; //licznik pól - jak daleko drużyny zaszły w grze - czy się znudziły?
  int? howManyTimesFinishedGame; //jak wiele drużyn tak naprawdę doszło do samego końca gry?
  int? howManyTimesRunApp; //jak wiele razy aplikacja została uruchomiona przez danego użytkownika
  int? howManyTimesRunInstertitialAd; //jak wiele razy odpaliła się reklama instertial

  UserInformations();

  Map<String, dynamic> toJson() => {
    'userID': userID,
    'purchaseStatus': purchaseStatus,
    'purchaseID': orderID,
    'createdUserDate': createdUserDate?.toIso8601String(),
    'purchaseDate': purchaseDate?.toIso8601String(),
    'productID': productID,
    'finalSpendTimeOnGame': finalSpendTimeOnGame,
    'howManyFieldReached': howManyFieldReached,
    'howManyTimesFinishedGame': howManyTimesFinishedGame,
    'howManyTimesRunApp': howManyTimesRunApp,
    'howManyTimesRunInstertitialAd': howManyTimesRunInstertitialAd,
  };
}
