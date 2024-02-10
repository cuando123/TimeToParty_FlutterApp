import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionHelper {
  static const String _hexString = "67356939266b337328307073";

  static String get hexString => _hexString;

  static encrypt.Key generateKeyFromHexString() {
    var bytesFromHex = hex.decode(_hexString);
    var digest = sha512.convert(bytesFromHex);
    Uint8List keyBytes = Uint8List.fromList(digest.bytes.sublist(0, 32));
    return encrypt.Key(keyBytes);
  }

  static final iv = encrypt.IV.fromLength(16); // Generuje losowy IV

  static String? encryptText(String? text) {
    if (text == null || text.isEmpty) {
      return '';
    }
    try {
      final key = generateKeyFromHexString();
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));
      final encrypted = encrypter.encrypt(text, iv: iv);
      return '${iv.base64}:${encrypted.base64}';
    } catch (e) {
      return "Encryption error: $e";
    }
  }

  static String? decryptText(String? encryptedTextWithIv) {
    if (encryptedTextWithIv == null || encryptedTextWithIv.isEmpty) {
      return '';
    }

    final parts = encryptedTextWithIv.split(':');
    if (parts.length != 2) {
      return '';
    }

    try {
      final iv = encrypt.IV.fromBase64(parts[0]);
      final encryptedText = parts[1];
      final key = generateKeyFromHexString();
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      final decrypted = encrypter.decrypt(encrypt.Encrypted.fromBase64(encryptedText), iv: iv);
      return decrypted;
    } catch (e) {
      return "Decryption error: $e";
    }
  }
}
