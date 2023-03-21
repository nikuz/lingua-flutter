import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lingua_flutter/controllers/request/request.dart' as request_controller;
import 'package:lingua_flutter/controllers/request/request.dart' show CancelToken, Options, ResponseType, DioError;
import 'package:lingua_flutter/controllers/parsing_schema/parsing_schema.dart' as parsing_schema_controller;
import 'package:lingua_flutter/controllers/cookie/cookie.dart' as cookie_controller;
import 'package:lingua_flutter/controllers/session/session.dart' show Session;
import 'package:lingua_flutter/models/parsing_schema/stored_schema.dart';
import 'package:lingua_flutter/models/error/error.dart';
import 'package:lingua_flutter/utils/headers.dart';

import './constants.dart';

Future<void> enableImagesSaveSearch({
  required String word,
  required Session session,
  CancelToken? cancelToken,
}) async {
  StoredParsingSchema? storedParsingSchema = await parsing_schema_controller.get('current');
  if (storedParsingSchema == null) {
    return;
  }
  ParsingSchema parsingSchema = storedParsingSchema.schema;

  final imagesUri = Uri.parse(parsingSchema.images.fields.url.replaceFirst('{word}', word));
  final imagesUriSearchParam = Uri.encodeComponent(imagesUri.query);
  final redirectUri = '${imagesUri.scheme}://${imagesUri.host}${imagesUri.path}?$imagesUriSearchParam';
  final url = parsingSchema.images.fields.safeSearchUrl
      .replaceFirst('{signature}', session.signature ?? '')
      .replaceFirst('{redirect}', redirectUri);

  developer.log('------------- Images save search preference URL: $url');

  try {
    await request_controller.get(
      url: url,
      options: Options(
        contentType: 'application/x-www-form-urlencoded;charset=UTF-8',
        responseType: ResponseType.plain,
        headers: {
          'user-agent': parsingSchema.images.fields.userAgent,
          'accept-encoding': 'gzip, deflate',
          'cookie': session.cookieString,
        },
        followRedirects: false,
      ),
      cancelToken: cancelToken,
    );
  } on DioError catch (err) {
    final statusCode = err.response?.statusCode;
    if (statusCode != null && statusCode >= 300 && statusCode < 400) {
      final location = getHeaderRedirectLocation(err.response?.headers);
      developer.log('------------- Images save search redirect location $location');
      developer.log('------------- Images save search is set successfully');
      await cookie_controller.set(err.response?.headers['set-cookie']);
    } else if (!CancelToken.isCancel(err)) {
      developer.log(err.toString());
      throw CustomError(
        code: 500,
        message: 'Can\'t set images save search ON',
        information: {
          'err': err,
          'parsingSchema': parsingSchema,
        },
      );
    }
  }
}

Future<bool> isImagesSaveSearchOff() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(ImagesControllerConstants.safeSearchOffPrefKey) == true;
}

void increaseImagesSaveSearchFailingAttemptsCounter() async {
  final prefs = await SharedPreferences.getInstance();
  const prefKey = ImagesControllerConstants.inabilityToSetSaveSearchCounterPrefKey;
  int inabilityCounter = (prefs.getInt(prefKey) ?? 0) + 1;

  prefs.setInt(prefKey, inabilityCounter);

  if (inabilityCounter > ImagesControllerConstants.maxConsecutiveSaveSearchSettingAttempts) {
    prefs.setBool(ImagesControllerConstants.safeSearchOffPrefKey, true);
  }
}

void refreshImagesSaveSearchFailingAttemptsCounter() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setInt(ImagesControllerConstants.inabilityToSetSaveSearchCounterPrefKey, 0);
}
