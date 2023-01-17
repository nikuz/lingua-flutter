import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart' as painting;
import 'package:lingua_flutter/models/translation.dart';
import 'package:lingua_flutter/models/error.dart';
import 'package:lingua_flutter/providers/db.dart';
import 'package:lingua_flutter/utils/files.dart';
import 'package:lingua_flutter/utils/regexp.dart';
import 'package:lingua_flutter/models/media_source.dart';

import './dictionary_get.dart';
import './dictionary_utils.dart';

Future<void> update(TranslationContainer translation) async {
  final TranslationContainer? translationData = await get(
    translation.word,
    translation.translateFrom.id,
    translation.translateTo.id,
  );
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
      pronunciationToFilePath = await savePronunciationFile(
        fileId: 'to-$fileId',
        schema: translation.schema!,
        pronunciation: translation.pronunciationTo,
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
      SET translation=?, updated_at=datetime("now"), schema_version=? $imageTransaction $pronunciationToTransaction
      WHERE id=$translationId;
    ''',
    [translation.translation, translation.schemaVersion],
  );
}