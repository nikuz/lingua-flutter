import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:developer' as developer;
import 'package:flutter/painting.dart' as painting;
import 'package:lingua_flutter/helpers/db.dart';
import 'package:lingua_flutter/utils/db.dart';
import 'package:lingua_flutter/utils/files.dart';

Future<Map<String, dynamic>> translateControllerGetList(int from, int to) async {
  const String countColumnName = 'COUNT(id)';
  final List<dynamic> results = await dbBatchQuery([{
    'type': 'rawQuery',
    'query': 'SELECT id, word, pronunciation, translation, image, created_at, updated_at ' +
        'FROM dictionary ' +
        'ORDER BY created_at DESC ' +
        'LIMIT ? OFFSET ?;',
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

  final List<dynamic> results = await dbBatchQuery([{
    'type': 'rawQuery',
    'query': 'SELECT id, word, pronunciation, translation, image, created_at, updated_at ' +
        'FROM dictionary ' +
        'WHERE ' +
          'word LIKE \'$searchPattern\' ' +
          'OR translation LIKE \'$searchPattern\' ' +
        'ORDER BY ' +
          'CASE ' +
          'WHEN word LIKE \'$searchText\' THEN 1 ' +
          'WHEN translation LIKE \'$searchText\' THEN 1 ' +
          'WHEN word LIKE \'$searchPatternEnd\' THEN 2 ' +
          'WHEN translation LIKE \'$searchPatternEnd\' THEN 2 ' +
          'WHEN word LIKE \'$searchPatternStart\' THEN 3 ' +
          'WHEN translation LIKE \'$searchPatternStart\' THEN 3 ' +
          'ELSE 4 ' +
        'END, ' +
        'word ASC, ' +
        'created_at DESC ' +
      'LIMIT ? OFFSET ?;',
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

Future<Map<String, dynamic>> translateControllerGet(String word) async {
  final List<Map> dbResponse = await dbRawQuery(
    'SELECT * FROM dictionary WHERE word=?;',
    [word]
  );

  if (dbResponse != null && dbResponse.length > 0) {
    final Map<String, dynamic> item = dbResponse[0];
    return {
      ...item,
      'raw': jsonDecode(item['raw']),
    };
  } else {
    return null;
  }
}

Future<void> translateControllerSave(Map<String, dynamic> params) async {
  final Map<String, dynamic> alreadyExists = await translateControllerGet(params['word']);

  if (alreadyExists != null) {
    throw DBException({
      'error': 'already_exists',
      'message': 'Such translation already exists in local database',
    });
  }

  // populate db with initial data
  await dbRawQuery(
      'INSERT INTO dictionary (word, translation, raw, updated_at, version) ' +
      'VALUES(?, ?, ?, datetime("now"), ?);',
      [
        params['word'],
        params['translation'],
        params['raw'],
        params['version'],
      ]
  );

  // get db entry with row ID
  final Map<String, dynamic> newTranslationData = await translateControllerGet(params['word']);

  try {
    String dir = await getDocumentsPath();
    String fileId = getFileId(newTranslationData['id'], params['word']);

    // save image
    final RegExp imageReg = new RegExp(r'^data:image/(jpeg|png|jpg);base64,(.+)$');
    String imageUrl = params['image'];
    if (imageUrl.indexOf(imageReg) != -1) {
      RegExpMatch imageParts = imageReg.firstMatch(params['image']);
      Uint8List imageBytes = Base64Decoder().convert(imageParts.group(2));
      imageUrl = '/images/$fileId.${imageParts.group(1)}';

      File image = File('$dir/$imageUrl');
      image = await image.create(recursive: true);
      await image.writeAsBytes(imageBytes);
    }

    // save pronunciation
    final RegExp pronunciationReg = new RegExp(r'^data:audio/mpeg;base64,(.+)$');
    String pronunciationUrl = params['pronunciationURL'];
    if (pronunciationUrl.indexOf(pronunciationReg) != -1) {
      RegExpMatch pronunciationParts = pronunciationReg.firstMatch(params['pronunciationURL']);
      Uint8List pronunciationBytes = Base64Decoder().convert(pronunciationParts.group(1));
      pronunciationUrl = '/pronunciations/$fileId.mp3';

      File pronunciation = File('$dir/$pronunciationUrl');
      pronunciation = await pronunciation.create(recursive: true);
      await pronunciation.writeAsBytes(pronunciationBytes);
    }

    // update db
    await dbRawQuery(
        'UPDATE dictionary ' +
        'SET image=?, pronunciation=?, updated_at=datetime("now") ' +
        'WHERE id=${newTranslationData['id']};',
        [
          imageUrl,
          pronunciationUrl,
        ]
    );
  } catch (e) {
    developer.log(e);
    await dbRawDelete('DELETE FROM dictionary WHERE id=?;', [newTranslationData['id']]);
  }
}

Future<void> translateControllerUpdate(Map<String, dynamic> params) async {
  final Map<String, dynamic> translationData = await translateControllerGet(params['word']);

  if (translationData == null) {
    throw DBException({
      'error': 'not_exists',
      'message': 'Such translation not exists in local database',
    });
  }

  String imageUrl;

  if (params['image'] != null && params['image'] != '') {
    String dir = await getDocumentsPath();
    File image = File('$dir/${params['image']}');
    if (image.existsSync()) {
      image.deleteSync();
    }
    painting.imageCache.clear();

    String fileId = getFileId(translationData['id'], params['word']);
    final RegExp imageReg = new RegExp(r'^data:image/(jpeg|png|jpg);base64,(.+)$');
    RegExpMatch imageParts = imageReg.firstMatch(params['image']);
    Uint8List imageBytes = Base64Decoder().convert(imageParts.group(2));
    imageUrl = '/images/$fileId.${imageParts.group(1)}';

    image = File('$dir/$imageUrl');
    await image.writeAsBytes(imageBytes);
  }

  String imageTransaction = '';
  if (imageUrl != null) {
    imageTransaction = ', image=\'$imageUrl\'';
  }

  // update db
  await dbRawQuery(
      'UPDATE dictionary ' +
      'SET translation=?, updated_at=datetime("now") $imageTransaction' +
      'WHERE id=${translationData['id']};',
      [params['translation']]
  );
}

Future<Map<String, dynamic>> translateControllerRemoveItem(int id) async {
  final List<dynamic> dbResponse = await dbRawQuery(
      'SELECT * FROM dictionary WHERE id=?;',
      [id]
  );

  if (dbResponse != null && dbResponse.length > 0) {
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

    final int count = await dbRawDelete('DELETE FROM dictionary WHERE id=?;', [id]);

    return { 'success': count == 1 };
  } else {
    throw DBException({
      'error': 'remove_error_exists',
      'message': 'Can\'t delete translation',
    });
  }
}
