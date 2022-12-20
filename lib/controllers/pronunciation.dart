import 'package:jmespath/jmespath.dart' as jmespath;
import 'package:lingua_flutter/providers/api.dart';
import 'package:lingua_flutter/models/parsing_schema/stored_schema.dart';
import 'package:lingua_flutter/models/language.dart';
import 'package:lingua_flutter/utils/string.dart';
import 'package:lingua_flutter/utils/types.dart';
import 'package:lingua_flutter/controllers/cloud_translation.dart' as cloud_translate_controller;

Future<String?> retrieve({
  required ParsingSchema schema,
  required String word,
  required Language language,
}) async {
  final encodedWord = removeSlashFromString(word);
  String? pronunciationResult;

  final pronunciationRaw = await apiPost(
    url: schema.pronunciation.fields.url,
    params: {
      schema.pronunciation.fields.parameter: schema.pronunciation.fields.body
          .replaceAll('{marker}', schema.pronunciation.fields.marker)
          .replaceAll('{word}', encodedWord)
          .replaceAll('{sourceLanguage}', language.id)
    },
  );

  final pronunciationRawData = cloud_translate_controller.retrieveResponseRawData(
    pronunciationRaw,
    schema.pronunciation.fields.marker,
  );
  if (pronunciationRawData != null) {
    String? base64Value = getDynamicString(jmespath.search(schema.pronunciation.data.value, pronunciationRawData));
    if (base64Value != null) {
      pronunciationResult = schema.pronunciation.fields.base64Prefix + base64Value;
    }
  }

  return pronunciationResult;
}