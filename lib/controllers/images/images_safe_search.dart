import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lingua_flutter/controllers/api/api.dart';
import 'package:lingua_flutter/controllers/parsing_schema/parsing_schema.dart';
import 'package:lingua_flutter/models/error/error.dart';

import './images_session.dart';
import './constants.dart';

Future<bool> enableImagesSaveSearch({
  required String word,
  required ParsingSchema parsingSchema,
  required ImagesSession session,
  CancelToken? cancelToken,
}) async {
  final imagesUri = Uri.parse(parsingSchema.images.fields.url.replaceFirst('{word}', word));
  final imagesUriSearchParam = Uri.encodeComponent(imagesUri.query);
  final redirectUri = '${imagesUri.scheme}://${imagesUri.host}${imagesUri.path}?$imagesUriSearchParam';
  final sessionFile = await getImagesSessionFile();

  try {
    final response = await apiGet(
      url: parsingSchema.images.fields.safeSearchUrl
          .replaceFirst('{signature}', session.signature ?? '')
          .replaceFirst('{redirect}', redirectUri),
      options: Options(
        contentType: 'application/x-www-form-urlencoded;charset=UTF-8',
        responseType: ResponseType.plain,
        headers: {
          'user-agent': parsingSchema.images.fields.userAgent,
          'accept-encoding': 'gzip, deflate',
          'cookie': session.cookies.join('; '),
        },
        followRedirects: false,
      ),
      cancelToken: cancelToken,
    );

    if (response.statusCode == 302) {
      sessionFile.writeAsStringSync(session.cookies.join('\n'));
      return true;
    } else {
      developer.log('-------- Error: Image safe search preference set returned non 302 response');
    }
  } on DioError catch (err) {
    developer.log(err.toString());
    final statusCode = err.response?.statusCode;
    if (statusCode != null && statusCode >= 300 && statusCode < 400) {
      sessionFile.writeAsStringSync(session.cookies.join('\n'));
      return true;
    } else if (!CancelToken.isCancel(err)) {
      throw CustomError(
        code: 500,
        message: 'Can\'t set images save search ON',
        information: [
          err,
          parsingSchema,
        ],
      );
    }
  }

  return false;
}

Future<bool> isImagesSaveSearchOff() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(ImagesControllerConstants.safeSearchOffPrefKey) ?? false;
}