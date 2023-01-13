import 'package:flutter/material.dart';
import 'package:lingua_flutter/providers/api.dart';
import 'package:lingua_flutter/controllers/parsing_schemas.dart';
import 'package:lingua_flutter/controllers/parsing_schemas.dart' as parsing_schemas_controller;
import 'package:lingua_flutter/utils/string.dart';
import 'package:lingua_flutter/utils/convert.dart';
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

  ParsingSchema? parsingSchema = storedParsingSchema.schema;
  String? imagesRaw;

  try {
    imagesRaw = await apiGet(
      url: parsingSchema.images.fields.url.replaceFirst('{word}', encodedWord),
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