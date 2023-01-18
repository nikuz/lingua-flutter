import 'package:jmespath/jmespath.dart' as jmespath;
import 'package:lingua_flutter/controllers/api/api.dart';
import 'package:lingua_flutter/models/parsing_schema/stored_schema.dart';
import 'package:lingua_flutter/models/language/language.dart';
import 'package:lingua_flutter/models/error/error.dart';
import 'package:lingua_flutter/utils/string.dart';
import 'package:lingua_flutter/utils/types.dart';
import 'package:lingua_flutter/controllers/cloud_translation/cloud_translation.dart' as cloud_translate_controller;

Future<String?> retrieve({
  required ParsingSchema schema,
  required String word,
  required Language language,
  CancelToken? cancelToken,
}) async {
  final encodedWord = removeQuotesFromString(removeSlashFromString(word));
  String? pronunciationResult;

  String? pronunciationRaw;

  try {
    final pronunciationResponse = await apiPost(
      url: schema.pronunciation.fields.url,
      options: Options(
        contentType: 'application/x-www-form-urlencoded;charset=UTF-8',
        responseType: ResponseType.plain,
        headers: {
          'accept-encoding': 'gzip, deflate',
        },
      ),
      cancelToken: cancelToken,
      data: {
        schema.pronunciation.fields.parameter: schema.pronunciation.fields.body
            .replaceAll('{marker}', schema.pronunciation.fields.marker)
            .replaceAll('{word}', encodedWord)
            .replaceAll('{sourceLanguage}', language.id)
      },
    );
    pronunciationRaw = pronunciationResponse.data;
  } catch (err) {
    throw CustomError(
      code: 500,
      message: 'Can\'t retrieve pronunciation using provided parsing schema',
      information: [
        err,
        word,
        language.toJson(),
        schema,
      ],
    );
  }

  if (pronunciationRaw != null) {
    final pronunciationRawData = await cloud_translate_controller.retrieveResponseRawData(
      pronunciationRaw,
      schema.pronunciation.fields.marker,
    );
    if (pronunciationRawData != null) {
      String? base64Value = getDynamicString(jmespath.search(schema.pronunciation.data.value, pronunciationRawData));
      if (base64Value != null) {
        pronunciationResult = schema.pronunciation.fields.base64Prefix + base64Value;
      }
    }
  }

  return pronunciationResult;
}