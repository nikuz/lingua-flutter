import 'dart:io';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lingua_flutter/controllers/api/api.dart';
import 'package:lingua_flutter/controllers/parsing_schema/parsing_schema.dart';
import 'package:lingua_flutter/utils/files.dart';
import 'package:lingua_flutter/models/error/error.dart';

import './constants.dart';

class ImagesSession {
  final List<String> cookies;
  final String? signature;

  const ImagesSession({
    required this.cookies,
    this.signature,
  });
}

Future<ImagesSession?> retrieveImagesSession({
  required String word,
  required ParsingSchema parsingSchema,
  CancelToken? cancelToken
}) async {
  final sessionFile = await getImagesSessionFile();

  if (sessionFile.existsSync()) {
    String? fileValue;
    try {
      fileValue = sessionFile.readAsStringSync();
      final cookies = fileValue.split('\n');
      bool cookiesExpired = false;

      if (cookies.isEmpty) {
        cookiesExpired = true;
      } else {
        for (var item in cookies) {
          final cookieItem = Cookie.fromSetCookieValue(item);
          if (cookieItem.expires is! DateTime || DateTime.now().compareTo(cookieItem.expires!) >= 0) {
            cookiesExpired = true;
          }
        }
      }

      if (!cookiesExpired) {
        return ImagesSession(cookies: cookies);
      }
    } catch (err) {
      sessionFile.deleteSync();
    }
  }

  final RegExp signatureReg = RegExp(parsingSchema.images.fields.safeSearchSignatureRegExp);
  const requestIconModifier = '&tbs=isz:i';
  final url = parsingSchema.images.fields.url.replaceFirst('{word}', word);
  String? responseData;
  List<String>? responseCookies;
  String? signature;

  try {
    final response = await apiGet(
      url: '$url$requestIconModifier',
      options: Options(
        contentType: 'application/x-www-form-urlencoded;charset=UTF-8',
        responseType: ResponseType.plain,
        headers: {
          'user-agent': parsingSchema.images.fields.userAgent,
          'accept-encoding': 'gzip, deflate',
        },
      ),
      cancelToken: cancelToken,
    );
    responseData = response.data;
    responseCookies = response.headers['set-cookie'];
  } on DioError catch (err) {
    developer.log(err.toString());
    if (!CancelToken.isCancel(err)) {
      throw CustomError(
        code: 500,
        message: 'Can\'t retrieve images cookies using "current" parsing schema',
        information: [
          err,
          parsingSchema,
        ],
      );
    }
  }

  if (responseData != null) {
    Iterable<RegExpMatch> signatureParts = signatureReg.allMatches(responseData);
    for (var item in signatureParts) {
      final String? match = item.group(1);
      if (match != null) {
        signature = match;
        break;
      }
    }
  }

  if (responseCookies != null && signature != null) {
    return ImagesSession(
      cookies: responseCookies,
      signature: signature,
    );
  }

  return null;
}

Future<File> getImagesSessionFile() async {
  final documentsPath = await getDocumentsPath();
  File file = File('${documentsPath}images_cookies.txt');
  return await file.create(recursive: true);
}

void increaseImagesSessionRetrievalFailingAttemptsCounter() async {
  final prefs = await SharedPreferences.getInstance();
  const prefKey = ImagesControllerConstants.inabilityToRetrieveSessionCounterPrefKey;
  int inabilityCounter = (prefs.getInt(prefKey) ?? 0) + 1;

  prefs.setInt(prefKey, inabilityCounter);

  if (inabilityCounter > ImagesControllerConstants.maxConsecutiveCookieRetrievalAttempts) {
    prefs.setBool(ImagesControllerConstants.safeSearchOffPrefKey, true);
  }
}

void refreshImagesSessionRetrievalFailingAttemptsCounter() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setInt(ImagesControllerConstants.inabilityToRetrieveSessionCounterPrefKey, 0);
}
