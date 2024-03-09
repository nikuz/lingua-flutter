import 'package:lingua_flutter/controllers/request/request.dart' as request_controller;
import 'package:lingua_flutter/controllers/request/request.dart' show CancelToken, Options, ResponseType, DioException;
import 'package:lingua_flutter/controllers/parsing_schema/parsing_schema.dart' as parsing_schema_controller;
import 'package:lingua_flutter/controllers/cookie/cookie.dart' as cookie_controller;
import 'package:lingua_flutter/controllers/session/session.dart' as session_controller;
import 'package:lingua_flutter/models/parsing_schema/stored_schema.dart';
import 'package:lingua_flutter/models/translation_container/translation_container.dart';
import 'package:lingua_flutter/models/error/error.dart';
import 'package:lingua_flutter/models/language/language.dart';
import 'package:lingua_flutter/utils/json.dart';
import 'package:lingua_flutter/utils/string.dart';

export './local_translation.dart';
export './quick_translation.dart';

Future<TranslationContainer?> cloudTranslate({
  required String word,
  required Language translateFrom,
  required Language translateTo,
  CancelToken? cancelToken,
  bool forceCurrentSchemaDownload = false,
  bool followRedirects = true,
}) async {
  final encodedWord = removeQuotesFromString(removeSlashFromString(word));
  StoredParsingSchema? currentParsingSchema = await parsing_schema_controller.get(
    'current',
    forceUpdate: forceCurrentSchemaDownload,
  );
  if (currentParsingSchema == null) {
    return null;
  }
  ParsingSchema? parsingSchema = currentParsingSchema.schema;

  List<dynamic>? translationResult;

  try {
    final session = await session_controller.get(word: word, cancelToken: cancelToken);
    final translationResponse = await request_controller.post(
      url: parsingSchema.translation.fields.url,
      options: Options(
        contentType: 'application/x-www-form-urlencoded;charset=UTF-8',
        responseType: ResponseType.plain,
        headers: {
          'accept-encoding': 'gzip, deflate',
          'cookie': session?.cookieString,
        },
      ),
      cancelToken: cancelToken,
      data: {
        parsingSchema.translation.fields.parameter: parsingSchema.translation.fields.body
            .replaceAll('{marker}', parsingSchema.translation.fields.marker)
            .replaceAll('{word}', encodedWord)
            .replaceAll('{sourceLanguage}', translateFrom.id)
            .replaceAll('{targetLanguage}', translateTo.id)
      },
    );

    final String? translationRaw = translationResponse.data;

    if (translationRaw != null) {
      translationResult = await retrieveResponseRawData(translationRaw, parsingSchema.translation.fields.marker);
    }

    // the thrown error will be caught below and a translation with an updated "current" schema will be attempted
    if (translationResult == null) {
      throw Error();
    }

    return TranslationContainer.fromRaw(
      word: word,
      raw: translationResult,
      schema: parsingSchema,
      schemaVersion: currentParsingSchema.version,
      translateFrom: translateFrom,
      translateTo: translateTo,
    );
  } on DioException catch (err) {
    final statusCode = err.response?.statusCode;
    if (statusCode != null && statusCode >= 300 && statusCode < 400) {
      await cookie_controller.set(err.response?.headers['set-cookie']);
      // try to refresh session
      if (followRedirects) {
        await session_controller.invalidate();
        return cloudTranslate(
          word: word,
          translateFrom: translateFrom,
          translateTo: translateTo,
          cancelToken: cancelToken,
          forceCurrentSchemaDownload: forceCurrentSchemaDownload,
          followRedirects: false,
        );
      }
    } else if (!CancelToken.isCancel(err)) {
      throw CustomError(
        code: 500,
        message: 'Can\'t retrieve translation using "current" parsing schema',
        information: {
          'err': err,
          'word': word,
          'parsingSchema': parsingSchema.toJson(),
          'translateFrom': translateFrom.toJson(),
          'translateTo': translateTo.toJson(),
        },
      );
    }
  } catch (err) {
    if (!forceCurrentSchemaDownload) {
      return cloudTranslate(
        word: word,
        translateFrom: translateFrom,
        translateTo: translateTo,
        cancelToken: cancelToken,
        forceCurrentSchemaDownload: true,
      );
    } else {
      throw CustomError(
        code: 500,
        message: 'Can\'t create TranslationContainer with new downloaded "current" schema',
        information: {
          'err': err,
          'word': word,
          'translationResult': translationResult ?? '',
          'parsingSchema': parsingSchema,
          'currentParsingSchema': currentParsingSchema.version,
          'translateFrom': translateFrom.toJson(),
          'translateTo': translateTo.toJson(),
        },
      );
    }
  }

  return null;
}

Future<List<dynamic>?>? retrieveResponseRawData(String rawData, String marker) async {
  // retrieve individual lines from translate response
  final rawStrings = rawData.split('\n');

  // find the line with translation marker, decode it,
  // then find inner JSON data string and decode it also
  // the inner decoded JSON is our RAW translation data
  for (var item in rawStrings) {
    if (item.contains(marker)) {
      final responseJson = await jsonDecodeIsolate(item);
      // resulted list of lines is sorted so the longest line goes first
      List<String> dataStrings = findAllJsonStrings(responseJson);
      if (dataStrings.isNotEmpty) {
        return await jsonDecodeIsolate(dataStrings[0]);
      }
      break;
    }
  }

  return null;
}