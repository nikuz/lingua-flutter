import 'package:lingua_flutter/controllers/request/request.dart' as request_controller;
import 'package:lingua_flutter/controllers/request/request.dart' show CancelToken, Options, DioError;
import 'package:lingua_flutter/controllers/parsing_schema/parsing_schema.dart' as parsing_schema_controller;
import 'package:lingua_flutter/controllers/cookie/cookie.dart' as cookie_controller;
import 'package:lingua_flutter/controllers/session/session.dart' as session_controller;
import 'package:lingua_flutter/models/parsing_schema/stored_schema.dart';
import 'package:lingua_flutter/models/quick_translation/quick_translation.dart';
import 'package:lingua_flutter/models/language/language.dart';
import 'package:lingua_flutter/models/error/error.dart';
import 'package:lingua_flutter/utils/string.dart';

Future<QuickTranslation?> quickTranslate({
  required String word,
  required Language translateFrom,
  required Language translateTo,
  CancelToken? cancelToken,
  bool autoTranslateFrom = false,
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
    final translationResponse = await request_controller.get(
      url: parsingSchema.quickTranslation.fields.url
          .replaceFirst('{word}', encodedWord)
          .replaceFirst('{sourceLanguage}', autoTranslateFrom ? 'auto' : translateFrom.id)
          .replaceFirst('{targetLanguage}', translateTo.id),
      options: Options(
        headers: {
          'accept-encoding': 'gzip, deflate',
          'cookie': session?.cookieString,
        },
      ),
      cancelToken: cancelToken,
    );

    final List<dynamic>? translationResult = translationResponse.data;

    // the thrown error will be caught below and a translation with an updated "current" schema will be attempted
    if (translationResult == null) {
      throw Error();
    }

    return QuickTranslation.fromRaw(
      raw: translationResult,
      schema: parsingSchema,
      translateFrom: translateFrom,
      translateTo: translateTo,
    );
  } on DioError catch (err) {
    final statusCode = err.response?.statusCode;
    if (statusCode != null && statusCode >= 300 && statusCode < 400) {
      await cookie_controller.set(err.response?.headers['set-cookie']);
      // try to refresh session
      if (followRedirects) {
        await session_controller.invalidate();
        return quickTranslate(
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
        message: 'Can\'t retrieve quick translation using "current" parsing schema',
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
      return quickTranslate(
        word: word,
        translateFrom: translateFrom,
        translateTo: translateTo,
        cancelToken: cancelToken,
        forceCurrentSchemaDownload: true,
      );
    } else {
      throw CustomError(
        code: 500,
        message: 'Can\'t create QuickTranslation with new downloaded "current" schema',
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