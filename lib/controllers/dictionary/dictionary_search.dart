import 'dart:convert';
import 'package:lingua_flutter/models/translation_list.dart';
import 'package:lingua_flutter/models/translation.dart';
import 'package:lingua_flutter/models/language.dart';
import 'package:lingua_flutter/providers/db.dart';
import 'package:lingua_flutter/utils/string.dart';

Future<TranslationList> search(String searchText, int from, int to) async {
  searchText = removeQuotesFromString(removeSlashFromString(searchText));
  final searchPattern = '%$searchText%';
  final searchPatternStart = '%$searchText';
  final searchPatternEnd = '$searchText%';
  const countColumnName = 'COUNT(id)';

  final List<dynamic> results = await DBProvider().batchQuery([
    BatchQueryRequest(
      type: 'rawQuery',
      query: '''
        SELECT id, word, pronunciationFrom, pronunciationTo, translation, image, translate_from, translate_to, created_at, updated_at
        FROM dictionary
        WHERE
          word LIKE '$searchPattern'
          OR translation LIKE '$searchPattern'
        ORDER BY
          CASE 
          WHEN word LIKE '$searchText' THEN 1
          WHEN translation LIKE '$searchText' THEN 1
          WHEN word LIKE '$searchPatternEnd' THEN 2
          WHEN translation LIKE '$searchPatternEnd' THEN 2
          WHEN word LIKE '$searchPatternStart' THEN 3
          WHEN translation LIKE '$searchPatternStart' THEN 3
          ELSE 4
        END,
        word ASC,
        created_at DESC
        LIMIT ? OFFSET ?;
      ''',
      arguments: [to - from, from],
    ),
    BatchQueryRequest(
      type: 'rawQuery',
      query: '''
        SELECT $countColumnName FROM dictionary
        WHERE
          word LIKE '$searchPattern'
          OR translation LIKE '$searchPattern'
      ''',
    )
  ]);

  return TranslationList(
    from: from,
    to: to,
    totalAmount: results[1][0][countColumnName],
    translations: results[0].map<TranslationContainer>((rawTranslation) => (
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