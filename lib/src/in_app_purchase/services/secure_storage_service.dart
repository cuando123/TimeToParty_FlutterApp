import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final _storage = FlutterSecureStorage();
  static const _transactionTokenKey = 'transaction_token';

  // Metoda do zapisywania tokena transakcji
  Future<void> saveTransactionToken(String token) async {
    await _storage.write(key: _transactionTokenKey, value: token);
  }

  // Metoda do odczytywania tokena transakcji
  Future<String?> getTransactionToken() async {
    return await _storage.read(key: _transactionTokenKey);
  }
  /*
  SecureStorageService secureStorageService = SecureStorageService();

  Future<String?> _printSecure() async {
    String? token = await secureStorageService.getTransactionToken();
    return token;
  }'*/
}
