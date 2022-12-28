import 'dart:convert';
import 'package:lingua_flutter/providers/api.dart';
import 'package:lingua_flutter/controllers/parsing_schemas.dart' as parsing_schemas_controller;
import 'package:lingua_flutter/controllers/local_translation.dart' as local_translate_controller;
import 'package:lingua_flutter/utils/json.dart';
import 'package:lingua_flutter/utils/string.dart';
import 'package:lingua_flutter/models/parsing_schema/stored_schema.dart';
import 'package:lingua_flutter/models/translation.dart';
import 'package:lingua_flutter/models/error.dart';
import 'package:lingua_flutter/models/language.dart';

Future<TranslationContainer> translate({
  required String word,
  required Language translateFrom,
  required Language translateTo,
  bool? forceCurrentSchemaDownload,
}) async {
  final encodedWord = removeQuotesFromString(removeSlashFromString(word));

  // if "forceCurrentSchemaDownload" set to true, then local retrieving and parsing has already failed,
  // so we want to refresh the locally stored "current" parsing schema and translate this word from scratch
  if (forceCurrentSchemaDownload == null) {
    final existingTranslation = await local_translate_controller.get(
      encodedWord,
      translateFrom.id,
      translateTo.id,
    );
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
            translation: existingTranslation.translation,
            pronunciationFrom: existingTranslation.pronunciationFrom,
            pronunciationTo: existingTranslation.pronunciationTo,
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
          // don't throw error here, but instead allow script to proceed into cloud translation phase if local translation failed
        }
      }
    }
  }

  StoredParsingSchema? currentParsingSchema = await parsing_schemas_controller.get(
    'current',
    forceUpdate: forceCurrentSchemaDownload == true,
  );

  if (currentParsingSchema == null) {
    throw const CustomError(
      code: 404,
      message: 'Can\'t retrieve "current" parsing schema',
    );
  }

  ParsingSchema? parsingSchema = currentParsingSchema.schema;

  List<dynamic>? translationResult;
  String? pronunciationFromResult;
  String? pronunciationToResult;

  String translationRaw = await apiPost(
    url: parsingSchema.translation.fields.url,
    params: {
      parsingSchema.translation.fields.parameter: parsingSchema.translation.fields.body
          .replaceAll('{marker}', parsingSchema.translation.fields.marker)
          .replaceAll('{word}', encodedWord)
          .replaceAll('{sourceLanguage}', translateFrom.id)
          .replaceAll('{targetLanguage}', translateTo.id)
    },
  );

  translationResult = retrieveResponseRawData(translationRaw, parsingSchema.translation.fields.marker);
  if (translationResult == null) {
    if (forceCurrentSchemaDownload == null) {
      return translate(
        word: word,
        translateFrom: translateFrom,
        translateTo: translateTo,
        forceCurrentSchemaDownload: true,
      );
    } else {
      throw CustomError(
        code: 500,
        message: 'Can\'t parse translation response with "current" schema',
        information: [
          word,
          translationRaw,
          parsingSchema,
          translateFrom,
          translateTo,
        ],
      );
    }
  }

  try {
    return TranslationContainer.fromRaw(
      word: word,
      pronunciationFrom: pronunciationFromResult,
      pronunciationTo: pronunciationToResult,
      raw: translationResult,
      schema: parsingSchema,
      schemaVersion: currentParsingSchema.version,
      translateFrom: translateFrom,
      translateTo: translateTo,
    );
  } catch (err) {
    if (forceCurrentSchemaDownload == null) {
      return translate(
        word: word,
        translateFrom: translateFrom,
        translateTo: translateTo,
        forceCurrentSchemaDownload: true,
      );
    } else {
      throw CustomError(
        code: 500,
        message: 'Can\'t create TranslationContainer with new downloaded "current" schema',
        information: [
          err,
          word,
          translationResult,
          parsingSchema,
          currentParsingSchema.version,
          translateFrom,
          translateTo,
        ],
      );
    }
  }
}

List<dynamic>? retrieveResponseRawData(String rawData, String marker) {
  // retrieve individual lines from translate response
  final rawStrings = rawData.split('\n');

  // find the line with translation marker, decode it,
  // then find inner JSON data string and decode it also
  // the inner decoded JSON is our RAW translation data
  for (var item in rawStrings) {
    if (item.contains(marker)) {
      final responseJson = jsonDecode(item);
      // resulted list of lines is sorted so the longest line goes first
      List<String> dataStrings = findAllJsonStrings(responseJson);
      if (dataStrings.isNotEmpty) {
        return jsonDecode(dataStrings[0]);
      }
      break;
    }
  }

  return null;
}