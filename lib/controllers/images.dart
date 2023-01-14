import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:lingua_flutter/providers/api.dart';
import 'package:lingua_flutter/controllers/parsing_schemas.dart';
import 'package:lingua_flutter/controllers/parsing_schemas.dart' as parsing_schemas_controller;
import 'package:lingua_flutter/utils/string.dart';
import 'package:lingua_flutter/utils/convert.dart';
import 'package:lingua_flutter/utils/files.dart';
import 'package:lingua_flutter/models/error.dart';

Future<List<String>?> search(String word, CancelToken? cancelToken) async {
  final encodedWord = removeQuotesFromString(removeSlashFromString(word));
  StoredParsingSchema? storedParsingSchema = await parsing_schemas_controller.get('current');

  if (storedParsingSchema == null) {
    throw const CustomError(
      code: 404,
      message: 'Can\'t retrieve "current" parsing schema',
    );
  }

  ParsingSchema parsingSchema = storedParsingSchema.schema;
  String? imagesRaw;
  ImagesSession? session;

  // try {
  //   session = await _retrieveSession(
  //     word: encodedWord,
  //     parsingSchema: parsingSchema,
  //     cancelToken: cancelToken,
  //   );
  // } catch (err) {
  //   developer.log(err.toString());
  // }
  //
  bool saveSearchIsSet = false;
  //
  // // if session has signature, then it's new session and we need to enable save search
  // if (session?.signature != null) {
  //   try {
  //     saveSearchIsSet = await _enableSaveSearch(
  //       word: encodedWord,
  //       parsingSchema: parsingSchema,
  //       session: session!,
  //       cancelToken: cancelToken,
  //     );
  //   } catch (err) {
  //     developer.log(err.toString());
  //   }
  // } else if (session?.cookies != null) {
  //   saveSearchIsSet = true;
  // }

  try {
    final Map<String, dynamic> headers = {
      'user-agent': parsingSchema.images.fields.userAgent,
      'accept-encoding': 'gzip, deflate',
    };

    if (saveSearchIsSet && session != null) {
      // headers['cookie'] = session.cookies.join('; ');
    }

    print('---------- saveSearchIsSet: $saveSearchIsSet');
    print('---------- cookie: ${session?.cookies}');
    final imagesResponse = await apiGet(
      url: parsingSchema.images.fields.url.replaceFirst('{word}', encodedWord),
      options: Options(
        contentType: 'application/x-www-form-urlencoded;charset=UTF-8',
        responseType: ResponseType.plain,
        headers: headers,
      ),
      cancelToken: cancelToken,
    );
    imagesRaw = imagesResponse.data;
  } on DioError catch (err) {
    if (!CancelToken.isCancel(err)) {
      throw CustomError(
        code: 500,
        message: 'Can\'t retrieve images using "current" parsing schema',
        information: [
          err,
          word,
          parsingSchema,
        ],
      );
    }
    return null;
  }

  if (imagesRaw == null) {
    return null;
  }

  final minBase64Length = int.parse(parsingSchema.images.fields.minSize); // in base64 characters
  const minImageSize = 100;
  final imageReg = RegExp(parsingSchema.images.fields.regExp);
  final base64EndReg = RegExp(r'\\x3d');
  final slashReg = RegExp(r'\\/');
  List<String> resultImages = [];

  Iterable<RegExpMatch> imageParts = imageReg.allMatches(imagesRaw);
  for (var item in imageParts) {
    final String? match = item.group(1);
    // filter small images with base64 string length less than "minBase64Length"
    if (match != null && match.length > minBase64Length) {
      final String decodedImageString = match
          .replaceAll(slashReg, '/')
          .replaceAll(base64EndReg, '=');

      final imageBytes = getBytesFrom64String(decodedImageString);
      final imageSize = await decodeImageFromList(imageBytes);

      // additionally filter images with with/height smaller than "minImageSize"
      if (imageSize.width > minImageSize && imageSize.height > minImageSize) {
        resultImages.add(decodedImageString);
      }
    }
  }

  return resultImages;
}

Future<ImagesSession?> _retrieveSession({
  required String word,
  required ParsingSchema parsingSchema,
  CancelToken? cancelToken
}) async {
  final sessionFilePath = await _getSessionFilePath();
  final sessionFile = File(sessionFilePath);

  if (sessionFile.existsSync()) {
    String? fileValue;
    try {
      fileValue = sessionFile.readAsStringSync();
    } catch (err) {
      sessionFile.deleteSync();
    }

    if (fileValue != null) {
      final cookies = fileValue.split('\n');
      bool cookiesExpired = false;

      for (var item in cookies) {
        final cookieItem = Cookie.fromSetCookieValue(item);
        if (cookieItem.expires is! DateTime || DateTime.now().compareTo(cookieItem.expires!) >= 0) {
          cookiesExpired = true;
        }
      }

      if (!cookiesExpired) {
        return ImagesSession(cookies: cookies);
      }
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

Future<bool> _enableSaveSearch({
  required String word,
  required ParsingSchema parsingSchema,
  required ImagesSession session,
  CancelToken? cancelToken,
}) async {
  final imagesUri = Uri.parse(parsingSchema.images.fields.url.replaceFirst('{word}', word));
  final imagesUriSearchParam = Uri.encodeComponent(imagesUri.query);
  final redirectUri = '${imagesUri.scheme}://${imagesUri.host}${imagesUri.path}?$imagesUriSearchParam';
  final sessionFilePath = await _getSessionFilePath();
  final sessionFile = File(sessionFilePath);

  try {
    final response = await apiGet(
      url: parsingSchema.images.fields.safeSearchUrl
          .replaceFirst('signature', session.signature ?? '')
          .replaceFirst('redirect', redirectUri),
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

class ImagesSession {
  final List<String> cookies;
  final String? signature;

  const ImagesSession({
    required this.cookies,
    this.signature,
  });
}

Future<String> _getSessionFilePath() async {
  final documentsPath = await getDocumentsPath();
  print('${documentsPath}images_cookies.txt');
  return '${documentsPath}images_cookies.txt';
}