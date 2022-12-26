import 'package:lingua_flutter/providers/api.dart';
import 'package:lingua_flutter/controllers/parsing_schemas.dart';
import 'package:lingua_flutter/controllers/parsing_schemas.dart' as parsing_schemas_controller;
import 'package:lingua_flutter/utils/string.dart';
import 'package:lingua_flutter/models/error.dart';

Future<List<String>?> search(String word) async {
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
      url: parsingSchema.images.fields.url.replaceFirst('{word}', removeSlashFromString(word)),
      headers: {
        'user-agent': parsingSchema.images.fields.userAgent,
      },
    );
  } catch(err) {
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

  final minImageSize = int.parse(parsingSchema.images.fields.minSize); // in base64 characters
  final imageReg = RegExp(parsingSchema.images.fields.regExp);
  final base64EndReg = RegExp(r'\\x3d');
  final slashReg = RegExp(r'\\/');
  List<String> resultImages = [];

  Iterable<RegExpMatch> imageParts = imageReg.allMatches(imagesRaw);
  for (var item in imageParts) {
    final String? match = item.group(1);
    if (match != null && match.length > minImageSize) {
      final String decodedImageString = match
          .replaceAll(slashReg, '/')
          .replaceAll(base64EndReg, '=');

      resultImages.add(decodedImageString);
    }
  }

  return resultImages;
}