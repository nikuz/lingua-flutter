import 'dart:convert';
import 'package:lingua_flutter/controllers/request/request.dart' as request_controller;
import 'package:lingua_flutter/controllers/request/request.dart' show Options;
import 'package:lingua_flutter/controllers/dictionary/dictionary.dart' as dictionary_controller;
import 'package:lingua_flutter/controllers/error_logger/error_logger.dart';
import 'package:lingua_flutter/models/translation_container/translation_container.dart';
import 'package:lingua_flutter/utils/crypto.dart';
import 'package:lingua_flutter/app_config.dart' as config;

Future<void> saveWord(TranslationContainer translation) async {
  try {
    final response = await request_controller.post(
      url: '${config.getApiUrl()}/api/dictionary',
      options: Options(
        contentType: 'application/json',
      ),
      data: {
        'signature': encrypt(jsonEncode({
          'word': translation.word,
          'translation': translation.translation,
        })),
        'word': translation.word,
        'translation': translation.translation,
        'translate_from': jsonEncode(translation.translateFrom),
        'translate_to': jsonEncode(translation.translateTo),
        'image': translation.image,
        'pronunciation_from': translation.pronunciationFrom,
        'pronunciation_to': translation.pronunciationTo,
        'schema_version': translation.schemaVersion,
        'raw': translation.raw,
      },
    );

    if (response.data != null) {
      final translationId = translation.id;
      final cloudId = int.parse(response.data);

      if (translationId != null) {
        await dictionary_controller.updateCloudId(translationId, cloudId);
      }
    }
  } catch (err, stack) {
    recordError(err, stack, information: [
      translation,
    ]);
  }
}

Future<void> updateWord(TranslationContainer translation) async {
  if (translation.cloudId == null) {
    return;
  }

  try {
    await request_controller.put(
      url: '${config.getApiUrl()}/api/dictionary',
      options: Options(
        contentType: 'application/json',
      ),
      data: {
        'signature': encrypt(jsonEncode({
          'word': translation.word,
          'translation': translation.translation,
        })),
        'id': translation.cloudId,
        'word': translation.word,
        'translation': translation.translation,
        'image': translation.image,
        'pronunciation_to': translation.pronunciationTo,
        'schema_version': translation.schemaVersion,
      },
    );
  } catch (err, stack) {
    recordError(err, stack, information: [
      translation,
    ]);
  }
}
