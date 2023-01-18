import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:lingua_flutter/models/translation_container/translation_container.dart';
import 'package:lingua_flutter/models/error/error.dart';
import 'package:lingua_flutter/controllers/database/database.dart';
import 'package:lingua_flutter/utils/files.dart';
import 'package:lingua_flutter/utils/regexp.dart';
import 'package:lingua_flutter/utils/json.dart';

import './dictionary_get.dart';
import './dictionary_update.dart';
import './dictionary_utils.dart';
import './constants.dart';

Future<void> save(TranslationContainer translation) async {
  final TranslationContainer? alreadyExists = await get(
    translation.word,
    translation.translateFrom.id,
    translation.translateTo.id,
  );

  // update translation if it already exists
  // user can appear in this situation if their local parsing schema is corrupted
  // and new schema and translation were received
  if (alreadyExists != null) {
    return update(translation);
  }

  // populate db with initial data
  await DBProvider().rawQuery(
    '''
    INSERT INTO ${DictionaryControllerConstants.databaseTableName} (
      word, 
      translation, 
      raw, 
      created_at, 
      schema_version, 
      translate_from, 
      translate_from_code, 
      translate_to,
      translate_to_code
    )
    VALUES(?, ?, ?, datetime("now"), ?, ?, ?, ?, ?);
    ''',
    [
      translation.word,
      translation.translation,
      await jsonEncodeIsolate(translation.raw),
      translation.schemaVersion,
      jsonEncode(translation.translateFrom.toJson()),
      translation.translateFrom.id,
      jsonEncode(translation.translateTo.toJson()),
      translation.translateTo.id,
    ],
  );

  // get saved in DB translation entry with row ID
  final TranslationContainer? newTranslationData = await get(
    translation.word,
    translation.translateFrom.id,
    translation.translateTo.id,
  );
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
        pronunciationFromFilePath = await savePronunciationFile(
          fileId: 'from-$fileId',
          schema: translation.schema!,
          pronunciation: translation.pronunciationFrom,
        );
        pronunciationToFilePath = await savePronunciationFile(
          fileId: 'to-$fileId',
          schema: translation.schema!,
          pronunciation: translation.pronunciationTo,
        );
      }

      // update db
      await DBProvider().rawQuery(
        '''
        UPDATE ${DictionaryControllerConstants.databaseTableName} 
        SET image=?, pronunciationFrom=?, pronunciationTo=? 
        WHERE id=$newTranslationId;
        ''',
        [
          imageUrl,
          pronunciationFromFilePath,
          pronunciationToFilePath,
        ],
      );
    } catch (err) {
      await DBProvider().rawDelete('DELETE FROM ${DictionaryControllerConstants.databaseTableName} WHERE id=?;', [newTranslationId]);
      rethrow;
    }
  } else {
    throw const CustomError(
      code: 500,
      message: 'Can\'t save translation ito DB',
    );
  }
}