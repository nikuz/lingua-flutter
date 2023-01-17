import 'dart:convert';
import 'package:lingua_flutter/models/translation_list.dart';
import 'package:lingua_flutter/models/translation.dart';
import 'package:lingua_flutter/models/language.dart';
import 'package:lingua_flutter/providers/db.dart';

Future<TranslationList> getList(int from, int to) async {
  const countColumnName = 'COUNT(id)';
  final results = await DBProvider().batchQuery([
    BatchQueryRequest(
      type: 'rawQuery',
      query: '''
        SELECT id, word, pronunciationFrom, pronunciationTo, translation, image, translate_from, translate_to, created_at, updated_at
        FROM dictionary
        ORDER BY created_at DESC
        LIMIT ? OFFSET ?;
      ''',
      arguments: [to - from, from],
    ),
    const BatchQueryRequest(
      type: 'rawQuery',
      query: 'SELECT $countColumnName FROM dictionary',
    )
  ]);

  return TranslationList(
    from: from,
    to: to,
    totalAmount: results[1][0][countColumnName],
    translations: results[0]?.map<TranslationContainer>((rawTranslation) => (
        TranslationContainer(
          id: rawTranslation['id'],
          word: rawTranslation['word'],
          translation: rawTranslation['translation'],
          pronunciationFrom: rawTranslation['pronunciationFrom'],
          pronunciationTo: rawTranslation['pronunciationTo'],
          image: rawTranslation['image'],
          translateFrom: Language.fromJson(jsonDecode(rawTranslation['translate_from'])),
          translateTo: Language.fromJson(jsonDecode(rawTranslation['translate_to'])),
          createdAt: rawTranslation['created_at'],
          updatedAt: rawTranslation['updated_at'],
        )
    )).toList(),
  );
}

Future<int> getListLength() async {
  const countColumnName = 'COUNT(id)';
  final results = await DBProvider().rawQuery('SELECT $countColumnName FROM dictionary');

  if (results.isEmpty) {
    return 0;
  }

  return results[0][countColumnName];
}