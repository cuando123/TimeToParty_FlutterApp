import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionHelper {
  static const String _hexString = "67356939266b337328307073"; // Stała używana do generowania klucza

  // Publiczna metoda do uzyskiwania _hexString
  static String get hexString => _hexString;

  // Metoda generująca klucz z wewnętrznego _hexString
  static encrypt.Key generateKeyFromHexString() {
    var bytesFromHex = hex.decode(_hexString); // Dekoduje _hexString do bajtów
    var digest = sha512.convert(bytesFromHex); // Stosuje SHA-512 do bajtów
    Uint8List keyBytes = Uint8List.fromList(digest.bytes.sublist(0, 32)); // Bierze pierwsze 32 bajty skrótu
    return encrypt.Key(keyBytes); // Tworzy klucz
  }

  static final iv = encrypt.IV.fromLength(16); // Generuje losowy IV

  // Metoda do szyfrowania tekstu
  static String encryptText(String text) {
    final key = generateKeyFromHexString(); // Wykorzystuje wewnętrzny _hexString do generowania klucza
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encrypt(text, iv: iv);
    return '${iv.base64}:${encrypted.base64}'; // Zwraca zaszyfrowany tekst z IV
  }

  // Metoda do deszyfrowania tekstu
  static String decryptText(String encryptedTextWithIv) {
    final parts = encryptedTextWithIv.split(':'); // Dzieli zaszyfrowany tekst na IV i sam tekst
    final iv = encrypt.IV.fromBase64(parts[0]); // Odtwarza IV
    final encryptedText = parts[1]; // Otrzymuje zaszyfrowany tekst
    final key = generateKeyFromHexString(); // Ponownie używa wewnętrznego _hexString do generowania klucza
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final decrypted = encrypter.decrypt(encrypt.Encrypted.fromBase64(encryptedText), iv: iv);
    return decrypted; // Zwraca odszyfrowany tekst
  }
}
