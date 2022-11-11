import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:developer' as developer;
import 'package:flutter/painting.dart' as painting;
import 'package:lingua_flutter/providers/db.dart';
import 'package:lingua_flutter/utils/files.dart';
import 'package:lingua_flutter/utils/regexp.dart';

Future<Map<String, dynamic>> translateControllerGetList(int from, int to) async {
  const String countColumnName = 'COUNT(id)';
  final List<dynamic> results = await DBProvider().batchQuery([{
    'type': 'rawQuery',
    'query': '''
      SELECT id, word, pronunciation, translation, image, created_at, updated_at
      FROM dictionary
      ORDER BY created_at DESC
      LIMIT ? OFFSET ?;
    ''',
    'arguments': [to - from, from],
  }, {
    'type': 'rawQuery',
    'query': 'SELECT $countColumnName FROM dictionary',
    'arguments': [],
  }]);

  return {
    'from': from,
    'to': to,
    'totalAmount': results[1][0][countColumnName],
    'translations': results[0],
  };
}

Future<Map<String, dynamic>> translateControllerSearch(String searchText, int from, int to) async {
  final String searchPattern = '%$searchText%';
  final String searchPatternStart = '%$searchText';
  final String searchPatternEnd = '$searchText%';
  const String countColumnName = 'COUNT(id)';

  final List<dynamic> results = await DBProvider().batchQuery([{
    'type': 'rawQuery',
    'query': '''
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
    'arguments': [to - from, from],
  }, {
    'type': 'rawQuery',
    'query': 'SELECT $countColumnName FROM dictionary',
    'arguments': [],
  }]);

  return {
    'from': from,
    'to': to,
    'totalAmount': results[1][0][countColumnName],
    'translations': results[0],
  };
}

Future<Map<String, dynamic>?> translateControllerGet(String? word) async {
  final List<Map> dbResponse = await DBProvider().rawQuery(
    'SELECT * FROM dictionary WHERE word=?;',
    [word]
  );

  if (dbResponse.length > 0) {
    final Map<String, dynamic> item = dbResponse[0] as Map<String, dynamic>;
    return {
      ...item,
      'raw': jsonDecode(item['raw']),
    };
  } else {
    return null;
  }
}

Future<void> translateControllerSave(Map<String, dynamic> params) async {
  final Map<String, dynamic>? alreadyExists = await translateControllerGet(params['word']);

  if (alreadyExists != null) {
    throw DBException({
      'error': 'already_exists',
      'message': 'Such translation already exists in local database',
    });
  }

  // populate db with initial data
  await DBProvider().rawQuery('''
      INSERT INTO dictionary (word, translation, raw, updated_at, version)
      VALUES(?, ?, ?, datetime("now"), ?);
      ''',
      [
        params['word'],
        params['translation'],
        params['raw'],
        params['version'],
      ]
  );

  // get db entry with row ID
  final Map<String, dynamic>? newTranslationData = await translateControllerGet(params['word']);

  try {
    String dir = await getDocumentsPath();
    String fileId = getFileId(newTranslationData?['id'], params['word']);

    // save image
    String imageUrl = params['image'];
    RegExpMatch? imageParts = base64ImageReg.firstMatch(params['image']);
    String? extension = imageParts?.group(1);
    String? imageValue = imageParts?.group(2);

    if (imageParts != null && extension is String && imageValue is String) {
      Uint8List imageBytes = Base64Decoder().convert(imageValue);
      imageUrl = '/images/$fileId.$extension';

      File image = File('$dir/$imageUrl');
      image = await image.create(recursive: true);
      await image.writeAsBytes(imageBytes);
    }

    // save pronunciation
    final RegExp pronunciationReg = new RegExp(r'^data:audio/mpeg;base64,(.+)$');
    String pronunciationUrl = params['pronunciationURL'];
    RegExpMatch? pronunciationParts = pronunciationReg.firstMatch(params['pronunciationURL']);
    String? pronunciationValue = pronunciationParts?.group(1);

    if (pronunciationParts != null && pronunciationValue is String) {
      Uint8List pronunciationBytes = Base64Decoder().convert(pronunciationValue);
      pronunciationUrl = '/pronunciations/$fileId.mp3';

      File pronunciation = File('$dir/$pronunciationUrl');
      pronunciation = await pronunciation.create(recursive: true);
      await pronunciation.writeAsBytes(pronunciationBytes);
    }

    // update db
    await DBProvider().rawQuery('''
        UPDATE dictionary 
        SET image=?, pronunciation=?, updated_at=datetime("now") 
        WHERE id=${newTranslationData?['id']};
        ''',
        [
          imageUrl,
          pronunciationUrl,
        ]
    );
  } catch (e) {
    developer.log(e.toString());
    await DBProvider().rawDelete('DELETE FROM dictionary WHERE id=?;', [newTranslationData?['id']]);
  }
}

Future<void> translateControllerUpdate(Map<String, dynamic> params) async {
  final Map<String, dynamic>? translationData = await translateControllerGet(params['word']);

  if (translationData == null) {
    throw DBException({
      'error': 'not_exists',
      'message': 'Such translation not exists in local database',
    });
  }

  String? imageUrl;

  if (params['image'] != null && params['image'] != '') {
    String dir = await getDocumentsPath();
    File image = File('$dir/${params['image']}');
    if (image.existsSync()) {
      image.deleteSync();
    }
    painting.imageCache.clear();

    String fileId = getFileId(translationData['id'], params['word']);
    RegExpMatch? imageParts = base64ImageReg.firstMatch(params['image']);
    String? extension = imageParts?.group(1);
    String? value = imageParts?.group(2);

    if (imageParts != null && extension is String && value is String) {
      Uint8List imageBytes = Base64Decoder().convert(value);
      imageUrl = '/images/$fileId.$extension';

      image = File('$dir/$imageUrl');
      await image.writeAsBytes(imageBytes);
    }
  }

  String imageTransaction = '';
  if (imageUrl is String) {
    imageTransaction = ', image=\'$imageUrl\'';
  }

  // update db
  await DBProvider().rawQuery('''
      UPDATE dictionary 
      SET translation=?, updated_at=datetime("now") $imageTransaction
      WHERE id=${translationData['id']};
      ''',
      [params['translation']]
  );
}

Future<void> translateControllerRemoveItem(int id) async {
  final List<dynamic> dbResponse = await DBProvider().rawQuery(
      'SELECT * FROM dictionary WHERE id=?;',
      [id]
  );

  if (dbResponse.length > 0) {
    final Map<String, dynamic> item = dbResponse[0];
    String dir = await getDocumentsPath();
    final image = File('$dir/${item['image']}');
    if (image.existsSync()) {
      image.deleteSync();
    }
    final pronunciation = File('$dir/${item['pronunciation']}');
    if (pronunciation.existsSync()) {
      pronunciation.deleteSync();
    }

    await DBProvider().rawDelete('DELETE FROM dictionary WHERE id=?;', [id]);
  } else {
    throw DBException({
      'error': 'remove_error_exists',
      'message': 'Can\'t delete translation',
    });
  }
}
