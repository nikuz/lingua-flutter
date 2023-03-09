import 'package:jmespath/jmespath.dart' as jmespath;
import 'package:lingua_flutter/controllers/request/request.dart' as request_controller;
import 'package:lingua_flutter/controllers/request/request.dart' show CancelToken, Options, ResponseType, DioError;
import 'package:lingua_flutter/controllers/cookie/cookie.dart' as cookie_controller;
import 'package:lingua_flutter/controllers/translation/translation.dart' as translation_controller;
import 'package:lingua_flutter/controllers/session/session.dart' as session_controller;
import 'package:lingua_flutter/models/parsing_schema/stored_schema.dart';
import 'package:lingua_flutter/models/language/language.dart';
import 'package:lingua_flutter/models/error/error.dart';
import 'package:lingua_flutter/utils/string.dart';
import 'package:lingua_flutter/utils/types.dart';

Future<String?> retrieve({
  required ParsingSchema schema,
  required String word,
  required Language language,
  CancelToken? cancelToken,
  bool followRedirects = true,
}) async {
  final encodedWord = removeQuotesFromString(removeSlashFromString(word));
  final session = await session_controller.get(word: word, cancelToken: cancelToken);

  try {
    final pronunciationResponse = await request_controller.post(
      url: schema.pronunciation.fields.url,
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
        schema.pronunciation.fields.parameter: schema.pronunciation.fields.body
            .replaceAll('{marker}', schema.pronunciation.fields.marker)
            .replaceAll('{word}', encodedWord)
            .replaceAll('{sourceLanguage}', language.id)
      },
    );
    final pronunciationRaw = pronunciationResponse.data;

    if (pronunciationRaw != null) {
      final pronunciationRawData = await translation_controller.retrieveResponseRawData(
        pronunciationRaw,
        schema.pronunciation.fields.marker,
      );
      if (pronunciationRawData != null) {
        String? base64Value = getDynamicString(jmespath.search(schema.pronunciation.data.value, pronunciationRawData));
        if (base64Value != null) {
          return schema.pronunciation.fields.base64Prefix + base64Value;
        }
      }
    }
  } on DioError catch (err) {
    final statusCode = err.response?.statusCode;
    if (statusCode != null && statusCode >= 300 && statusCode < 400) {
      await cookie_controller.set(err.response?.headers['set-cookie']);
      // try to refresh session
      if (followRedirects) {
        await session_controller.invalidate();
        return retrieve(
          schema: schema,
          word: word,
          language: language,
          cancelToken: cancelToken,
          followRedirects: false,
        );
      }
    } else if (!CancelToken.isCancel(err)) {
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
  }

  return null;
}