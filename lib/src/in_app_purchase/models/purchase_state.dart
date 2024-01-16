class PurchaseState {
  static final PurchaseState _instance = PurchaseState._internal();

  factory PurchaseState() {
    return _instance;
  }

  PurchaseState._internal();

  bool isPurchased = false;
}