import 'package:shared_preferences/shared_preferences.dart';
import 'package:lingua_flutter/providers/api.dart';
import 'package:lingua_flutter/controllers/parsing_schemas.dart';
import 'package:lingua_flutter/models/error.dart';

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
    }
  } on DioError catch (err) {
    if (err.response?.statusCode == 302) {
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