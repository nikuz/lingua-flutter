import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart' as painting;
import 'package:lingua_flutter/models/translation_list.dart';
import 'package:lingua_flutter/models/translation.dart';
import 'package:lingua_flutter/models/error.dart';
import 'package:lingua_flutter/models/language.dart';
import 'package:lingua_flutter/models/parsing_schema/stored_schema.dart';
import 'package:lingua_flutter/providers/db.dart';
import 'package:lingua_flutter/utils/files.dart';
import 'package:lingua_flutter/utils/regexp.dart';
import 'package:lingua_flutter/utils/media_source.dart';

Future<void> init() async {
  await DBProvider().rawQuery('''
    CREATE TABLE IF NOT EXISTS dictionary (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      word VARCHAR NOT NULL COLLATE NOCASE,
      pronunciationFrom VARCHAR,
      pronunciationTo VARCHAR,
      translation VARCHAR COLLATE NOCASE,
      raw TEXT NOT NULL,
      image VARCHAR,
      translate_from VARCHAR NOT NULL,
      translate_to VARCHAR NOT NULL,
      schema_version VARCHAR NOT NULL,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      updated_at TEXT DEFAULT CURRENT_TIMESTAMP
    )
  ''');
}

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

Future<TranslationList> search(String searchText, int from, int to) async {
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

Future<TranslationContainer?> get(String? word) async {
  if (word == null) {
    return null;
  }

  final dbResponse = await DBProvider().rawQuery(
      'SELECT * FROM dictionary WHERE word=?;',
      [word]
  );

  if (dbResponse.isEmpty) {
    return null;
  }

  final item = dbResponse[0];

  return TranslationContainer(
    id: item['id'],
    word: word,
    translation: item['translation'],
    pronunciationFrom: item['pronunciationFrom'],
    pronunciationTo: item['pronunciationTo'],
    image: item['image'],
    raw: jsonDecode(item['raw']),
    schemaVersion: item['schema_version'],
    translateFrom: Language.fromJson(jsonDecode(item['translate_from'])),
    translateTo: Language.fromJson(jsonDecode(item['translate_to'])),
    createdAt: item['created_at'],
    updatedAt: item['updated_at'],
  );
}

Future<void> save(TranslationContainer translation) async {
  final TranslationContainer? alreadyExists = await get(translation.word);

  // update translation if it already exists
  // user can appear in this situation if their local parsing schema is corrupted
  // and new schema and translation were received
  if (alreadyExists != null) {
    return update(translation);
  }

  // populate db with initial data
  await DBProvider().rawQuery('''
      INSERT INTO dictionary (word, translation, raw, created_at, schema_version, translate_from, translate_to)
      VALUES(?, ?, ?, datetime("now"), ?, ?, ?);
      ''',
      [
        translation.word,
        translation.translation,
        jsonEncode(translation.raw),
        translation.schemaVersion,
        jsonEncode(translation.translateFrom.toJson()),
        jsonEncode(translation.translateTo.toJson()),
      ]
  );

  // get saved in DB translation entry with row ID
  final TranslationContainer? newTranslationData = await get(translation.word);
  final newTranslationId = newTranslationData?.id;

  if (newTranslationId != null) {
    try {
      String dir = await getDocumentsPath();
      String fileId = generateFileIdFromWord(newTranslationId, translation.word);

      // save image
      String? imageUrl = translation.image;
      RegExpMatch? imageParts;
      if (imageUrl != null) {
        imageParts = base64ImageReg.firstMatch(imageUrl);
        String? extension = imageParts?.group(1);
        String? imageValue = imageParts?.group(2);

        if (imageParts != null && extension != null && imageValue != null) {
          Uint8List imageBytes = const Base64Decoder().convert(imageValue);
          imageUrl = '/images/$fileId.$extension';

          File image = File('$dir$imageUrl');
          image = await image.create(recursive: true);
          await image.writeAsBytes(imageBytes);
        }
      }

      String? pronunciationFromFilePath;
      String? pronunciationToFilePath;
      if (translation.schema != null) {
        // save pronunciations
        pronunciationFromFilePath = await _savePronunciationFile(
          'from-$fileId',
          translation.schema!,
          translation.pronunciationFrom,
        );
        pronunciationToFilePath = await _savePronunciationFile(
          'to-$fileId',
          translation.schema!,
          translation.pronunciationTo,
        );
      }

      // update db
      await DBProvider().rawQuery('''
        UPDATE dictionary 
        SET image=?, pronunciationFrom=?, pronunciationTo=? 
        WHERE id=$newTranslationId;
        ''',
          [
            imageUrl,
            pronunciationFromFilePath,
            pronunciationToFilePath,
          ]
      );
    } catch (err) {
      await DBProvider().rawDelete('DELETE FROM dictionary WHERE id=?;', [newTranslationId]);
      rethrow;
    }
  } else {
    throw const CustomError(
      code: 500,
      message: 'Can\'t save translation ito DB',
    );
  }
}

Future<void> update(TranslationContainer translation) async {
  final TranslationContainer? translationData = await get(translation.word);
  final translationId = translationData?.id;

  if (translationData == null || translationId == null) {
    throw const CustomError(
      code: 404,
      message: 'Such translation does not exist in the local database',
    );
  }

  String fileId = generateFileIdFromWord(translationId, translation.word);

  String? imageUrl;

  if (translation.image != null) {
    final imageSourceType = MediaSource.getType(translation.image!);
    if (imageSourceType == MediaSourceType.base64) {
      String dir = await getDocumentsPath();
      File image = File('$dir${translation.image}');
      if (image.existsSync()) {
        image.deleteSync();
      }

      RegExpMatch? imageParts = base64ImageReg.firstMatch(translation.image!);
      String? extension = imageParts?.group(1);
      String? value = imageParts?.group(2);

      if (imageParts != null && extension is String && value is String) {
        Uint8List imageBytes = const Base64Decoder().convert(value);
        imageUrl = '/images/$fileId.$extension';

        image = File('$dir$imageUrl');
        await image.writeAsBytes(imageBytes);

        // remove image from low level flutter imageCache
        final key = FileImage(File('$dir$imageUrl'), scale: 1.0);
        if (painting.imageCache.containsKey(key)) {
          painting.imageCache.evict(key);
        }
      }
    }
  }

  String imageTransaction = '';
  if (imageUrl != null) {
    imageTransaction = ', image=\'$imageUrl\'';
  }

  String? pronunciationToFilePath;

  if (translation.pronunciationTo != null && translation.schema != null) {
    final pronunciationSourceType = MediaSource.getType(translation.pronunciationTo!);
    if (pronunciationSourceType == MediaSourceType.base64) {
      pronunciationToFilePath = await _savePronunciationFile(
        'to-$fileId',
        translation.schema!,
        translation.pronunciationTo,
      );
    }
  }

  String pronunciationToTransaction = '';
  if (pronunciationToFilePath != null) {
    pronunciationToTransaction = ', pronunciationTo=\'$pronunciationToFilePath\'';
  }

  // update db
  await DBProvider().rawQuery(
      '''
        UPDATE dictionary 
        SET translation=?, updated_at=datetime("now") $imageTransaction $pronunciationToTransaction
        WHERE id=$translationId;
      ''',
      [translation.translation]
  );
}

Future<void> removeItem(int id) async {
  final List<dynamic> dbResponse = await DBProvider().rawQuery(
      'SELECT * FROM dictionary WHERE id=?;',
      [id]
  );

  if (dbResponse.isEmpty) {
    throw const CustomError(
      code: 404,
      message: 'Such translation does not exist in the local database',
    );
  }

  final item = dbResponse[0];
  final dir = await getDocumentsPath();
  final image = File('$dir${item['image']}');
  if (image.existsSync()) {
    image.deleteSync();
  }
  final pronunciationFrom = File('$dir${item['pronunciationFrom']}');
  if (pronunciationFrom.existsSync()) {
    pronunciationFrom.deleteSync();
  }
  final pronunciationTo = File('$dir${item['pronunciationTo']}');
  if (pronunciationTo.existsSync()) {
    pronunciationTo.deleteSync();
  }

  await DBProvider().rawDelete('DELETE FROM dictionary WHERE id=?;', [id]);
}

Future<void> clearDatabase() async {
  await DBProvider().rawQuery('DROP TABLE IF EXISTS dictionary');

  String dir = await getDocumentsPath();
  final images = Directory('$dir/images');
  if (images.existsSync()) {
    images.deleteSync(recursive: true);
  }
  final pronunciations = Directory('$dir/pronunciations');
  if (pronunciations.existsSync()) {
    pronunciations.deleteSync(recursive: true);
  }

  await init();
}

Future<String?> _savePronunciationFile(
  String fileId,
  ParsingSchema schema,
  String? pronunciation,
) async {
  String? filePath;

  if (pronunciation != null) {
    String dir = await getDocumentsPath();
    final RegExp pronunciationReg = RegExp('${schema.pronunciation.fields.base64Prefix}(.+)');
    RegExpMatch? pronunciationParts;
    pronunciationParts = pronunciationReg.firstMatch(pronunciation);
    String? pronunciationValue = pronunciationParts?.group(1);

    if (pronunciationParts != null && pronunciationValue != null) {
      Uint8List pronunciationBytes = const Base64Decoder().convert(pronunciationValue);
      filePath = '/pronunciations/$fileId.mp3';

      File pronunciationFile = File('$dir/$filePath');
      pronunciationFile = await pronunciationFile.create(recursive: true);
      await pronunciationFile.writeAsBytes(pronunciationBytes);
    }
  }

  return filePath;
}