import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/painting.dart' as painting;
import 'package:lingua_flutter/models/translation_list.dart';
import 'package:lingua_flutter/models/translation.dart';
import 'package:lingua_flutter/models/error.dart';
import 'package:lingua_flutter/providers/db.dart';
import 'package:lingua_flutter/utils/files.dart';
import 'package:lingua_flutter/utils/regexp.dart';
import 'package:lingua_flutter/utils/media_source.dart';

Future<void> translateControllerInit() async {
  await DBProvider().rawQuery('''
    CREATE TABLE IF NOT EXISTS dictionary (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      word VARCHAR NOT NULL COLLATE NOCASE,
      pronunciation VARCHAR,
      translation VARCHAR COLLATE NOCASE,
      raw TEXT NOT NULL,
      image VARCHAR,
      schema_version INTEGER DEFAULT 1,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      updated_at TEXT DEFAULT CURRENT_TIMESTAMP
    )
  ''');
}

Future<TranslationList> translateControllerGetList(int from, int to) async {
  const countColumnName = 'COUNT(id)';
  final results = await DBProvider().batchQuery([
    BatchQueryRequest(
      type: 'rawQuery',
      query: '''
        SELECT id, word, pronunciation, translation, image, created_at, updated_at
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
    translations: results[0]?.map<Translation>((rawTranslation) => (
      Translation(
        id: rawTranslation['id'],
        word: rawTranslation['word'],
        translation: rawTranslation['translation'],
        pronunciation: rawTranslation['pronunciation'],
        image: rawTranslation['image'],
        raw: [], // raw data is not present in database response above
        createdAt: rawTranslation['created_at'],
        updatedAt: rawTranslation['updated_at'],
      )
    )).toList(),
  );
}

Future<TranslationList> translateControllerSearch(String searchText, int from, int to) async {
  final searchPattern = '%$searchText%';
  final searchPatternStart = '%$searchText';
  final searchPatternEnd = '$searchText%';
  const countColumnName = 'COUNT(id)';

  final List<dynamic> results = await DBProvider().batchQuery([
    BatchQueryRequest(
      type: 'rawQuery',
      query: '''
        SELECT id, word, pronunciation, translation, image, created_at, updated_at
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
    translations: results[0].map<Translation>((rawTranslation) => (
      Translation(
        id: rawTranslation['id'],
        word: rawTranslation['word'],
        translation: rawTranslation['translation'],
        pronunciation: rawTranslation['pronunciation'],
        image: rawTranslation['image'],
        raw: [], // raw data is not present in database response above
        createdAt: rawTranslation['created_at'],
        updatedAt: rawTranslation['updated_at'],
      )
    )).toList(),
  );
}

Future<Translation?> translateControllerGet(String? word) async {
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

  return Translation(
    id: item['id'],
    word: word,
    translation: item['translation'],
    pronunciation: item['pronunciation'],
    image: item['image'],
    raw: jsonDecode(item['raw']),
    createdAt: item['created_at'],
    updatedAt: item['updated_at'],
    schemaVersion: item['schema_version'],
  );
}

Future<void> translateControllerSave(Translation translation) async {
  final Translation? alreadyExists = await translateControllerGet(translation.word);

  if (alreadyExists != null) {
    throw const CustomError(
      code: 409,
      message: 'Such translation already exists in local database',
    );
  }

  // populate db with initial data
  await DBProvider().rawQuery('''
      INSERT INTO dictionary (word, translation, raw, created_at, schema_version)
      VALUES(?, ?, ?, datetime("now"), ?);
      ''',
      [
        translation.word,
        translation.translation,
        jsonEncode(translation.raw),
        translation.schemaVersion,
      ]
  );

  // get saved in DB translation entry with row ID
  final Translation? newTranslationData = await translateControllerGet(translation.word);
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

          File image = File('$dir/$imageUrl');
          image = await image.create(recursive: true);
          await image.writeAsBytes(imageBytes);
        }
      }

      String? pronunciationUrl;
      if (translation.schema != null) {
        // save pronunciation
        final RegExp pronunciationReg = RegExp('${translation.schema!.pronunciation.fields.base64Prefix}(.+)');
        pronunciationUrl = translation.pronunciation;
        RegExpMatch? pronunciationParts;
        if (pronunciationUrl != null) {
          pronunciationParts = pronunciationReg.firstMatch(pronunciationUrl);
          String? pronunciationValue = pronunciationParts?.group(1);

          if (pronunciationParts != null && pronunciationValue != null) {
            Uint8List pronunciationBytes = const Base64Decoder().convert(pronunciationValue);
            pronunciationUrl = '/pronunciations/$fileId.mp3';

            File pronunciation = File('$dir/$pronunciationUrl');
            pronunciation = await pronunciation.create(recursive: true);
            await pronunciation.writeAsBytes(pronunciationBytes);
          }
        }
      }

      // update db
      await DBProvider().rawQuery('''
        UPDATE dictionary 
        SET image=?, pronunciation=? 
        WHERE id=$newTranslationId;
        ''',
          [
            imageUrl,
            pronunciationUrl,
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

Future<void> translateControllerUpdate(Translation translation) async {
  final Translation? translationData = await translateControllerGet(translation.word);
  final translationId = translationData?.id;

  if (translationData == null || translationId == null) {
    throw const CustomError(
      code: 404,
      message: 'Such translation does not exist in the local database',
    );
  }

  String? imageUrl;

  if (translation.image != null) {
    final imageSourceType = MediaSource.getType(translation.image!);
    if (imageSourceType == MediaSourceType.base64) {
      String dir = await getDocumentsPath();
      File image = File('$dir/${translation.image}');
      if (image.existsSync()) {
        image.deleteSync();
      }
      painting.imageCache.clear();

      String fileId = generateFileIdFromWord(translationId, translation.word);
      RegExpMatch? imageParts = base64ImageReg.firstMatch(translation.image!);
      String? extension = imageParts?.group(1);
      String? value = imageParts?.group(2);

      if (imageParts != null && extension is String && value is String) {
        Uint8List imageBytes = const Base64Decoder().convert(value);
        imageUrl = '/images/$fileId.$extension';

        image = File('$dir/$imageUrl');
        await image.writeAsBytes(imageBytes);
      }
    }
  }

  String imageTransaction = '';
  if (imageUrl is String) {
    imageTransaction = ', image=\'$imageUrl\'';
  }

  // update db
  await DBProvider().rawQuery(
      '''
        UPDATE dictionary 
        SET translation=?, updated_at=datetime("now") $imageTransaction
        WHERE id=$translationId;
      ''',
      [translation.translation]
  );
}

Future<void> translateControllerRemoveItem(int id) async {
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
  final image = File('$dir/${item['image']}');
  if (image.existsSync()) {
    image.deleteSync();
  }
  final pronunciation = File('$dir/${item['pronunciation']}');
  if (pronunciation.existsSync()) {
    pronunciation.deleteSync();
  }

  await DBProvider().rawDelete('DELETE FROM dictionary WHERE id=?;', [id]);
}
