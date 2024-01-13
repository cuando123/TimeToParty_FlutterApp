class UserInformations {
  String? userID;
  bool? isPurchased;
  String? purchaseID;
  DateTime? createdUserDate;
  DateTime? purchaseDate;
  String? productID;
  String? amount;
  String? currency;

  UserInformations();

  Map<String, dynamic> toJson() => {
    'userID': userID,
    'isPurchased': isPurchased,
    'purchaseID': purchaseID,
    'createdUserDate': createdUserDate,
    'purchaseDate': purchaseDate,
    'productID': productID,
    'amount': amount,
    'currency': currency
  };

}