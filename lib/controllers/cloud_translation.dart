import 'dart:convert';
import 'package:jmespath/jmespath.dart' as jmespath;
import 'package:lingua_flutter/providers/api.dart';
import 'package:lingua_flutter/controllers/parsing_schemas.dart';
import 'package:lingua_flutter/controllers/parsing_schemas.dart' as parsing_schemas_controller;
import 'package:lingua_flutter/controllers/local_translation.dart' as local_translate_controller;
import 'package:lingua_flutter/utils/json.dart';
import 'package:lingua_flutter/utils/string.dart';
import 'package:lingua_flutter/utils/types.dart';
import 'package:lingua_flutter/models/translation.dart';
import 'package:lingua_flutter/models/error.dart';
import 'package:lingua_flutter/models/language.dart';

Future<TranslationContainer> translate({
  required String word,
  required Language translateFrom,
  required Language translateTo,
  bool? forceCurrentSchemaDownload,
}) async {
  final encodedWord = removeSlashFromString(word);

  // if "forceCurrentSchemaDownload" set to true, then local retrieving and parsing has already failed,
  // so we want to refresh the locally stored "current" parsing schema and translate this word from scratch
  if (forceCurrentSchemaDownload == null) {
    final existingTranslation = await local_translate_controller.get(encodedWord);
    if (existingTranslation != null) {
      final schemaVersion = existingTranslation.schemaVersion;
      StoredParsingSchema? storedParsingSchema;
      if (schemaVersion != null) {
        storedParsingSchema = await parsing_schemas_controller.get(schemaVersion);
      }

      if (existingTranslation.raw != null && storedParsingSchema != null) {
        try {
          return TranslationContainer.fromRaw(
            id: existingTranslation.id,
            word: word,
            pronunciation: existingTranslation.pronunciation,
            image: existingTranslation.image,
            raw: existingTranslation.raw!,
            schema: storedParsingSchema.schema,
            schemaVersion: storedParsingSchema.version,
            translateFrom: existingTranslation.translateFrom,
            translateTo: existingTranslation.translateTo,
            createdAt: existingTranslation.createdAt,
            updatedAt: existingTranslation.updatedAt,
          );
        } catch (e) {
          //
        }
      }
    }
  }

  StoredParsingSchema? storedParsingSchema = await parsing_schemas_controller.get(
    'current',
    forceUpdate: forceCurrentSchemaDownload == true,
  );

  if (storedParsingSchema == null) {
    throw const CustomError(
      code: 404,
      message: 'Can\'t retrieve "current" parsing schema',
    );
  }

  ParsingSchema? parsingSchema = storedParsingSchema.schema;

  List<dynamic>? translationResult;
  String? pronunciationResult;

  List<String> results = await Future.wait([
    // fetch raw translation
    apiPost(
        url: parsingSchema.translation.fields.url,
        params: {
          parsingSchema.translation.fields.parameter: parsingSchema.translation.fields.body
              .replaceAll('{marker}', parsingSchema.translation.fields.marker)
              .replaceAll('{word}', encodedWord)
              .replaceAll('{sourceLanguage}', translateFrom.id)
              .replaceAll('{targetLanguage}', translateTo.id)
        }
    ),
    // fetch raw pronunciation
    apiPost(
        url: parsingSchema.pronunciation.fields.url,
        params: {
          parsingSchema.pronunciation.fields.parameter: parsingSchema.pronunciation.fields.body
              .replaceAll('{marker}', parsingSchema.pronunciation.fields.marker)
              .replaceAll('{word}', encodedWord)
              .replaceAll('{sourceLanguage}', translateFrom.id)
        }
    )
  ]);

  String translationRaw = results[0];
  translationResult = _retrieveTranslationRawData(translationRaw, parsingSchema.translation.fields.marker);

  String pronunciationRaw = results[1];
  final pronunciationRawData = _retrieveTranslationRawData(pronunciationRaw, parsingSchema.pronunciation.fields.marker);
  if (pronunciationRawData != null) {
    String? base64Value = getDynamicString(jmespath.search(parsingSchema.pronunciation.data.value, pronunciationRawData));
    if (base64Value != null) {
      pronunciationResult = parsingSchema.pronunciation.fields.base64Prefix + base64Value;
    }
  }

  if (translationResult == null || pronunciationResult == null) {
    if (forceCurrentSchemaDownload == null) {
      return translate(
        word: word,
        translateFrom: translateFrom,
        translateTo: translateTo,
        forceCurrentSchemaDownload: true,
      );
    } else {
      throw const CustomError(
        code: 500,
        message: 'Can\'t parse translation response with "current" schema',
      );
    }
  }

  try {
    return TranslationContainer.fromRaw(
      word: word,
      pronunciation: pronunciationResult,
      raw: translationResult,
      schema: parsingSchema,
      schemaVersion: storedParsingSchema.version,
      translateFrom: translateFrom,
      translateTo: translateTo,
    );
  } catch (error) {
    if (forceCurrentSchemaDownload == null) {
      return translate(
        word: word,
        translateFrom: translateFrom,
        translateTo: translateTo,
        forceCurrentSchemaDownload: true,
      );
    } else {
      rethrow;
    }
  }
}

List<dynamic>? _retrieveTranslationRawData(String rawData, String marker) {
  // retrieve individual lines from translate response
  final rawStrings = rawData.split('\n');

  // find the line with translation marker, decode it,
  // then find inner JSON data string and decode it also
  // the inner decoded JSON is our translation data
  for (var item in rawStrings) {
    if (item.contains(marker)) {
      final responseJson = jsonDecode(item);
      List<String> dataStrings = findAllJsonStrings(responseJson);
      if (dataStrings.isNotEmpty) {
        return jsonDecode(dataStrings[0]);
      }
      break;
    }
  }

  return null;
}