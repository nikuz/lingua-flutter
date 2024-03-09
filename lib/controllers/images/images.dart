import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:lingua_flutter/controllers/request/request.dart' as request_controller;
import 'package:lingua_flutter/controllers/request/request.dart' show CancelToken, Options, ResponseType, DioException;
import 'package:lingua_flutter/controllers/parsing_schema/parsing_schema.dart' as parsing_schema_controller;
import 'package:lingua_flutter/controllers/cookie/cookie.dart' as cookie_controller;
import 'package:lingua_flutter/controllers/session/session.dart' as session_controller;
import 'package:lingua_flutter/controllers/session/session.dart' show Session;
import 'package:lingua_flutter/utils/string.dart';
import 'package:lingua_flutter/utils/convert.dart';
import 'package:lingua_flutter/models/error/error.dart';

import './images_safe_search.dart';

Future<List<String>?> search({
  required String word,
  CancelToken? cancelToken,
  bool followRedirects = true,
}) async {
  Session? session = await session_controller.get(word: word, cancelToken: cancelToken);
  final encodedWord = removeQuotesFromString(removeSlashFromString(word));
  final storedParsingSchema = await parsing_schema_controller.get('current');
  if (storedParsingSchema == null) {
    return null;
  }
  final parsingSchema = storedParsingSchema.schema;

  final bool saveSearchIsOff = await isImagesSaveSearchOff();
  String? imagesRaw;

  // if session has signature, then it is a new one and we need to enable save search
  if (!saveSearchIsOff && session != null && session.signature != null) {
    try {
      await enableImagesSaveSearch(
        word: encodedWord,
        session: session,
        cancelToken: cancelToken,
      );
      await session_controller.signatureRemove();
      refreshImagesSaveSearchFailingAttemptsCounter();
      // refresh session
      session = await session_controller.get(word: word, cancelToken: cancelToken);
    } catch (err) {
      developer.log(err.toString());
      increaseImagesSaveSearchFailingAttemptsCounter();
    }
  }

  try {
    final imagesResponse = await request_controller.get(
      url: parsingSchema.images.fields.url.replaceFirst('{word}', encodedWord),
      options: Options(
        contentType: 'application/x-www-form-urlencoded;charset=UTF-8',
        responseType: ResponseType.plain,
        headers: {
          'user-agent': parsingSchema.images.fields.userAgent,
          'accept-encoding': 'gzip, deflate',
          'cookie': session?.cookieString,
        },
        followRedirects: false,
      ),
      cancelToken: cancelToken,
    );

    if (imagesResponse.statusCode == 200) {
      await cookie_controller.set(imagesResponse.headers['set-cookie']);
      imagesRaw = imagesResponse.data;

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
  } on DioException catch (err) {
    final statusCode = err.response?.statusCode;
    if (statusCode != null && statusCode >= 300 && statusCode < 400) {
      await cookie_controller.set(err.response?.headers['set-cookie']);
      // try to refresh session
      if (followRedirects) {
        await session_controller.invalidate();
        return search(word: word, cancelToken: cancelToken, followRedirects: false);
      }
    } else if (!CancelToken.isCancel(err)) {
      throw CustomError(
        code: 500,
        message: 'Can\'t retrieve images using "current" parsing schema',
        information: {
          'err': err,
          'word': word,
          'parsingSchema': parsingSchema,
        },
      );
    }
  }

  return null;
}