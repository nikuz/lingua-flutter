import 'dart:convert';
import 'package:lingua_flutter/models/translation_container/translation_container.dart';
import 'package:lingua_flutter/models/language/language.dart';
import 'package:lingua_flutter/controllers/database/database.dart';
import 'package:lingua_flutter/utils/json.dart';

import './constants.dart';

Future<TranslationContainer?> get(String word, String translateFrom, String translateTo) async {
  final dbResponse = await DBProvider().rawQuery(
    'SELECT * FROM ${DictionaryControllerConstants.databaseTableName} WHERE word=? AND translate_from_code=? AND translate_to_code=?;',
    [word, translateFrom, translateTo],
  );

  if (dbResponse.isEmpty) {
    return null;
  }

  final item = dbResponse[0];
  final rawData = await jsonDecodeIsolate(item['raw']);

  return TranslationContainer(
    id: item['id'],
    cloudId: item['cloudId'],
    word: word,
    translation: item['translation'],
    pronunciationFrom: item['pronunciationFrom'],
    pronunciationTo: item['pronunciationTo'],
    image: item['image'],
    raw: rawData,
    schemaVersion: item['schema_version'],
    translateFrom: Language.fromJson(jsonDecode(item['translate_from'])),
    translateTo: Language.fromJson(jsonDecode(item['translate_to'])),
    createdAt: item['created_at'],
    updatedAt: item['updated_at'],
  );
}