import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jmespath/jmespath.dart' as jmespath;
import 'package:lingua_flutter/controllers/translation.dart';
import 'package:lingua_flutter/controllers/parsing_schemas.dart';
import 'package:lingua_flutter/models/translation.dart';
import 'package:lingua_flutter/utils/string.dart';
import 'package:lingua_flutter/utils/types.dart';
import 'package:lingua_flutter/providers/api.dart';
import 'package:lingua_flutter/utils/json.dart';
import 'package:lingua_flutter/models/error.dart';

import 'translation_view_state.dart';

class TranslationViewCubit extends Cubit<TranslationViewState> {
  TranslationViewCubit() : super(TranslationViewState());

  void translate(String word) async {
    try {
      emit(state.copyWith(translateLoading: true));

      final translation = await _fetchTranslation(word);

      emit(state.copyWith(
        word: word,
        imageSearchWord: word,
        translation: translation,
      ));
    } catch (err) {
      emit(state.copyWith(
        error: Wrapped.value(CustomError(
          code: err.hashCode,
          message: err.toString(),
        )),
        translateLoading: false,
      ));
      throw err;
    }
  }

  Future<String?> fetchImages(String word) async {
    emit(state.copyWith(
      imageLoading: true,
      imageSearchWord: word,
    ));

    try {
      final List<String>? images = await _fetchImages(word);

      emit(state.copyWith(
        images: images,
        imageLoading: false,
      ));
      return images?[0];
    } catch (err) {
      emit(state.copyWith(
        error: Wrapped.value(CustomError(
          code: err.hashCode,
          message: err.toString(),
        )),
        imageLoading: false,
      ));
      throw err;
    }
  }

  Future<void> save(Translation translation) async {
    try {
      emit(state.copyWith(
        updateLoading: true,
      ));

      await translateControllerSave(translation);

      emit(state.copyWith(
        updateLoading: false,
      ));
    } catch (err) {
      emit(state.copyWith(
        error: Wrapped.value(CustomError(
          code: err.hashCode,
          message: err.toString(),
        )),
        updateLoading: false,
      ));
      throw err;
    }
  }

  Future<void> update(Translation translation) async {
    try {
      emit(state.copyWith(
        updateLoading: true,
      ));

      await translateControllerUpdate(translation);

      emit(state.copyWith(
        updateLoading: false,
      ));
    } catch (err) {
      emit(state.copyWith(
        error: Wrapped.value(CustomError(
          code: err.hashCode,
          message: err.toString(),
        )),
        updateLoading: false,
      ));
      throw err;
    }
  }

  void setImage(String image) {
    emit(state.copyWith(
      translation: state.translation?.copyWith(
        image: image,
      ),
      imageIsUpdated: true,
    ));
  }

  void setOwnTranslation(String translation) {
    emit(state.copyWith(
      translation: state.translation?.copyWith(
        translation: translation,
      ),
      translationIsUpdated: true,
    ));
  }

  void reset() {
    emit(TranslationViewState());
  }
}

Future<Translation> _fetchTranslation(String word, { bool? forceCurrentSchemaDownload }) async {
  final encodedWord = removeSlash(word);
  final existingTranslation = await translateControllerGet(encodedWord);
  if (existingTranslation != null) {
    final schemaVersion = existingTranslation.schemaVersion;
    StoredParsingSchema? storedParsingSchema;
    if (schemaVersion != null) {
      storedParsingSchema = await getParsingSchema(schemaVersion);
    }

    return existingTranslation.copyWith(
        schema: storedParsingSchema?.schema,
    );
  }

  StoredParsingSchema? storedParsingSchema = await getParsingSchema(
    'current',
    forceUpdate: forceCurrentSchemaDownload == true,
  );

  if (storedParsingSchema == null) {
    throw CustomError(
      code: 404,
      message: 'Can\'t retrieve "current" parsing schema',
    );
  }

  ParsingSchema? parsingSchema = storedParsingSchema.schema;

  String sourceLanguage = 'en';
  String targetLanguage = 'ru';

  List<dynamic>? translationResult;
  String? pronunciationResult;

  List<String> results = await Future.wait([
    // fetch raw translation
    apiPost(
        url: parsingSchema.translation.fields.url,
        params: {
          '${parsingSchema.translation.fields.parameter}': parsingSchema.translation.fields.body
              .replaceAll('{marker}', parsingSchema.translation.fields.marker)
              .replaceAll('{word}', encodedWord)
              .replaceAll('{sourceLanguage}', sourceLanguage)
              .replaceAll('{targetLanguage}', targetLanguage)
        }
    ),
    // fetch raw pronunciation
    apiPost(
        url: parsingSchema.pronunciation.fields.url,
        params: {
          '${parsingSchema.pronunciation.fields.parameter}': parsingSchema.pronunciation.fields.body
              .replaceAll('{marker}', parsingSchema.pronunciation.fields.marker)
              .replaceAll('{word}', encodedWord)
              .replaceAll('{sourceLanguage}', sourceLanguage)
        }
    )
  ]);

  String translationRaw = results[0];
  translationResult = _retrieveTranslationRawData(translationRaw, parsingSchema.translation.fields.marker);
  String? translationString = jmespath.search(parsingSchema.translation.translation.value, translationResult);
  if (translationResult == null || translationString == null) {
    if (forceCurrentSchemaDownload == null) {
      return _fetchTranslation(word, forceCurrentSchemaDownload: true);
    } else {
      throw CustomError(
        code: 500,
        message: 'Can\'t parse translation response with "current" schema',
      );
    }
  }

  String pronunciationRaw = results[1];
  final pronunciationRawData = _retrieveTranslationRawData(pronunciationRaw, parsingSchema.pronunciation.fields.marker);
  if (pronunciationRawData != null) {
    String? base64Value = jmespath.search(parsingSchema.pronunciation.data.value, pronunciationRawData);
    if (base64Value != null) {
      pronunciationResult = parsingSchema.pronunciation.fields.base64Prefix + base64Value;
    }
  }

  return Translation(
    word: word,
    translation: translationString,
    pronunciation: pronunciationResult,
    raw: translationResult,
    schema: parsingSchema,
    schemaVersion: storedParsingSchema.version,
  );
}

List<dynamic>? _retrieveTranslationRawData(String rawData, String marker) {
  // retrieve individual lines from translate response
  final rawStrings = rawData.split('\n');

  // find the line with translation marker, decode it,
  // then find inner JSON data string and decode it also
  // the inner decoded JSON is our translation data
  for (var item in rawStrings) {
    if (item.contains(marker)) {
      final responseJson = jsonDecode(item);
      List<String> dataStrings = findAllJsonStrings(responseJson);
      if (dataStrings.isNotEmpty) {
        return jsonDecode(dataStrings[0]);
      }
      break;
    }
  }

  return null;
}

Future<List<String>> _fetchImages(String word) async {
  StoredParsingSchema? storedParsingSchema = await getParsingSchema('current');

  if (storedParsingSchema == null) {
    throw CustomError(
      code: 404,
      message: 'Can\'t retrieve "current" parsing schema',
    );
  }

  ParsingSchema? parsingSchema = storedParsingSchema.schema;

  final String imagesRaw = await apiGet(
    url: parsingSchema.images.fields.url.replaceFirst('{word}', removeSlash(word)),
    headers: {
      'user-agent': parsingSchema.images.fields.userAgent,
    },
  );

  final minImageSize = int.parse(parsingSchema.images.fields.minSize); // in base64 characters
  final imageReg = RegExp('${parsingSchema.images.fields.regExp}');
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