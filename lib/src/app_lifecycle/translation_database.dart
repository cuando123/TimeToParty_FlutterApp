import 'dart:io';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:game_template/src/in_app_purchase/models/shared_encryption_helper.dart';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class TranslationDatabase {
  String generateKeyFromHexString(String hexString) {
    var bytesFromHex = hex.decode(hexString);
    var digest = sha512.convert(bytesFromHex);
    return digest.toString().substring(0, 64);
  }

  Future<Database> initDatabase() async {
    var dbName = "db_awesome.db.enctempold";
    var dbPath = join(await getDatabasesPath(), dbName);

    ByteData data = await rootBundle.load("assets/time_to_party_assets/$dbName");
    List<int> bytes =
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(dbPath).writeAsBytes(bytes, flush: true);
    final key = generateKeyFromHexString(EncryptionHelper.hexString);
    print("DB KEY: $key");
    return openDatabase(dbPath, password: key);
  }

  Future<Map<String, String>> getAllTranslationsForLanguage(String language) async {
    Database database = await initDatabase();

    final queryResult = await database.rawQuery(
        'SELECT key, string_value FROM Menu_translations WHERE language = ?', [language]);

    final translationsMap = <String, String>{};
    for (final row in queryResult) {
      translationsMap[row['key'] as String] = row['string_value'] as String;
    }
    return translationsMap;
  }

  Future<Map<String, String>> fetchWordsByLanguage(String language, bool isPurchased) async {
    Database database = await initDatabase();

    final maps = await database.query(
      'Cards',
      columns: ['Key', 'words'],
      where: isPurchased ? 'language = ?' : 'language = ? AND IsPurchased = "No"',
      whereArgs: [language],
    );

    Map<String, String> wordsMap = {};
    for (final row in maps) {
      wordsMap[row['Key'] as String] = row['words'] as String;
    }

    return wordsMap;
  }
}