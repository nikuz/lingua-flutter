import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:lingua_flutter/providers/api.dart';
import 'package:lingua_flutter/controllers/parsing_schemas.dart';
import 'package:lingua_flutter/controllers/parsing_schemas.dart' as parsing_schemas_controller;
import 'package:lingua_flutter/utils/string.dart';
import 'package:lingua_flutter/utils/convert.dart';
import 'package:lingua_flutter/models/error.dart';

import './images_session.dart';
import './images_safe_search.dart';

Future<List<String>?> search(String word, CancelToken? cancelToken) async {
  final encodedWord = removeQuotesFromString(removeSlashFromString(word));
  StoredParsingSchema? storedParsingSchema = await parsing_schemas_controller.get('current');

  if (storedParsingSchema == null) {
    throw const CustomError(
      code: 404,
      message: 'Can\'t retrieve "current" parsing schema',
    );
  }

  bool saveSearchIsOff = await isImagesSaveSearchOff();
  ParsingSchema parsingSchema = storedParsingSchema.schema;
  String? imagesRaw;
  ImagesSession? session;
  bool saveSearchIsSet = false;

  if (!saveSearchIsOff) {
    try {
      session = await retrieveImagesSession(
        word: encodedWord,
        parsingSchema: parsingSchema,
        cancelToken: cancelToken,
      );
    } catch (err) {
      developer.log(err.toString());
    }

    if (session != null) {
      refreshImagesSessionRetrievalFailingAttemptsCounter();

      // if session has signature, then it's new one and we need to enable save search
      if (session.signature != null) {
        try {
          saveSearchIsSet = await enableImagesSaveSearch(
            word: encodedWord,
            parsingSchema: parsingSchema,
            session: session,
            cancelToken: cancelToken,
          );
        } catch (err) {
          developer.log(err.toString());
          increaseImagesSessionRetrievalFailingAttemptsCounter();
        }
      } else {
        saveSearchIsSet = true;
      }
    } else {
      increaseImagesSessionRetrievalFailingAttemptsCounter();
    }
  }

  try {
    final Map<String, dynamic> headers = {
      'user-agent': parsingSchema.images.fields.userAgent,
      'accept-encoding': 'gzip, deflate',
    };

    if (saveSearchIsSet && session != null) {
      headers['cookie'] = session.cookies.join('; ');
    }

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