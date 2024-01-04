
/// Reprezentuje stan zakupu w aplikacji w celu usunięcia reklam, np
/// [AdRemovalPurchase.notStarted()] lub [AdRemovalPurchase.active()].
class AdRemovalPurchase {
  /// Prezentacja tego produktu w sklepach.
  static const productId = 'remove_ads';

  /// To jest `true`, jeśli produkt `remove_ad` został zakupiony i zweryfikowany.
  /// Nie wyświetlaj reklam, jeśli tak.
  final bool active;

  /// Wartość „prawda” występuje, gdy zakup jest w toku.
  final bool pending;

  /// Jeśli wystąpił błąd przy zakupie, to pole będzie zawierać
  ///ten błąd.
  final Object? error;

  const AdRemovalPurchase.active() : this._(true, false, null);

  const AdRemovalPurchase.error(Object error) : this._(false, false, error);

  const AdRemovalPurchase.notStarted() : this._(false, false, null);

  const AdRemovalPurchase.pending() : this._(false, true, null);

  const AdRemovalPurchase._(this.active, this.pending, this.error);

  @override
  int get hashCode => Object.hash(active, pending, error);

  @override
  bool operator ==(Object other) =>
      other is AdRemovalPurchase &&
      other.active == active &&
      other.pending == pending &&
      other.error == error;
}
