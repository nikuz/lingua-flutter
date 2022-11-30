import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jmespath/jmespath.dart' as jmespath;
import 'package:lingua_flutter/controllers/translation.dart';
import 'package:lingua_flutter/controllers/parsing_schemas.dart';
import 'package:lingua_flutter/models/translation.dart';
import 'package:lingua_flutter/utils/types.dart';
import 'package:lingua_flutter/app_config.dart' as appConfig;
import 'package:lingua_flutter/providers/api.dart';
import 'package:lingua_flutter/utils/string.dart';
import 'package:lingua_flutter/utils/json.dart';
import 'package:lingua_flutter/models/error.dart';

import 'translation_view_state.dart';

class TranslationViewCubit extends Cubit<TranslationViewState> {
  TranslationViewCubit() : super(TranslationViewState());

  void translate(String word) async {
    try {
      emit(state.copyWith(translateLoading: true));

      final Translation translation = await _fetchTranslation(word);
      final List<dynamic>? raw = translation.raw;
      List<dynamic>? highestRelevantTranslation;
      String? transcription;
      List<dynamic>? alternativeTranslations;
      List<dynamic>? definitions;
      List<dynamic>? definitionsSynonyms;
      List<dynamic>? examples;
      String? version = translation.version;
      String? translationWord = translation.translation;
      String? autoSpellingFix;
      bool strangeWord = false;

      if (raw != null) {
        if (version == '1') {
          highestRelevantTranslation = raw[0];
          alternativeTranslations = raw[1];
          if (raw.length >= 12) {
            definitionsSynonyms = raw[11];
          }
          if (raw.length >= 13) {
            definitions = raw[12];
          }
          if (raw.length >= 14 && raw[13] != null && raw[13][0] != null) {
            examples = raw[13][0];
          }

          if (translationWord == null) {
            translationWord = highestRelevantTranslation![0][0];
          }

          if (word.toLowerCase() != highestRelevantTranslation![0][1].toLowerCase()) {
            autoSpellingFix = word;
            word = highestRelevantTranslation[0][1];
          }

          if (
          highestRelevantTranslation.length > 1
              && highestRelevantTranslation[1] != null
              && highestRelevantTranslation[1].length >= 4
          ) {
            transcription = highestRelevantTranslation[1][3];
          }
        } else if (version == '2') {
          highestRelevantTranslation = raw[1][0];
          if (raw.length > 3 && raw[3].length >= 6 && raw[3][5] != null) {
            alternativeTranslations = raw[3][5][0];
          }
          if (raw.length > 3 && raw[3].length >= 2 && raw[3][1] != null) {
            definitions = raw[3][1][0];
          }
          if (raw.length > 3 && raw[3].length >= 3 && raw[3][2] != null) {
            examples = raw[3][2][0];
          }

          if (translationWord == null) {
            translationWord = highestRelevantTranslation![0][5][0][0];
          }

          if (raw.length > 3 && word.toLowerCase() != raw[3][0].toLowerCase()) {
            autoSpellingFix = word;
            word = raw[3][0];
          }

          transcription = raw[0][0];
        }

        strangeWord = word.toLowerCase() == translationWord!.toLowerCase()
            && alternativeTranslations == null;
      }

      emit(state.copyWith(
        id: translation.id,
        word: word,
        translationWord: translationWord,
        pronunciation: translation.pronunciation,
        image: translation.image,
        images: [],
        imageSearchWord: word,
        imageLoading: false,
        createdAt: translation.createdAt,
        updatedAt: translation.updatedAt,
        highestRelevantTranslation: highestRelevantTranslation,
        transcription: transcription,
        alternativeTranslations: alternativeTranslations,
        definitions: definitions,
        definitionsSynonyms: definitionsSynonyms,
        examples: examples,
        autoSpellingFix: autoSpellingFix,
        strangeWord: strangeWord,
        raw: translation.raw,
        remote: translation.remote,
        version: translation.version,
        translateLoading: false,
      ));
    } catch (err) {
      emit(state.copyWith(
        error: Wrapped.value(CustomError(
          code: err.hashCode,
          message: err.toString(),
        )),
        translateLoading: false,
      ));
    }
  }

  void fetchImages(String word) async {
    emit(state.copyWith(
      imageLoading: true,
      imageSearchWord: word,
    ));

    try {
      final String imagesRaw = await apiGet(
        url: appConfig.imagesURL.replaceFirst('{word}', word),
        headers: {
          'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36',
        },
      );

      final minImageSize = 8000; // in base64 characters
      final imageReg = RegExp(r"'(data:image[^']+)'");
      final base64EndReg = RegExp(r'\\x3d');
      final slashReg = RegExp(r'\\/');
      final List<String> imagesRawStrings = imagesRaw.split('\n');
      List<String> resultImages = [];

      for (int i = 0, l = imagesRawStrings.length; i < l; i++) {
        if (imagesRawStrings[i].contains(appConfig.imageMarker)) {
          Iterable<RegExpMatch> imageParts = imageReg.allMatches(imagesRawStrings[i]);
          for (var item in imageParts) {
            final String? match = item.group(1);
            if (match != null && match.length > minImageSize) {
              final String decodedImageString = match
                  .replaceAll(slashReg, '/')
                  .replaceAll(base64EndReg, '=');

              resultImages.add(decodedImageString);
            }
          }
        }
      }

      emit(state.copyWith(
        images: resultImages,
        imageLoading: false,
      ));
    } catch (err) {
      emit(state.copyWith(
        error: Wrapped.value(CustomError(
          code: err.hashCode,
          message: err.toString(),
        )),
        imageLoading: false,
      ));
    }
  }

  Future<bool> save(Translation translation) async {
    try {
      emit(state.copyWith(
        saveLoading: true,
      ));
      await translateControllerSave(translation);
      emit(state.copyWith(
        saveLoading: false,
      ));

      return true;
    } catch (err) {
      emit(state.copyWith(
        error: Wrapped.value(CustomError(
          code: err.hashCode,
          message: err.toString(),
        )),
        saveLoading: false,
      ));
    }

    return false;
  }

  Future<bool> update(Translation translation) async {
    try {
      emit(state.copyWith(
        updateLoading: true,
      ));
      await translateControllerUpdate({
        'word': '${translation.word}',
        'image': '${translation.image != null ? translation.image : ''}',
        'translation': '${translation.translation}',
      });
      emit(state.copyWith(
        updateLoading: false,
      ));

      return true;
    } catch (err) {
      emit(state.copyWith(
        error: Wrapped.value(CustomError(
          code: err.hashCode,
          message: err.toString(),
        )),
        updateLoading: false,
      ));
    }

    return false;
  }

  void setImage(String image) {
    emit(state.copyWith(
      image: image,
      imageUpdated: true,
    ));
  }

  void setOwnTranslation(String translation) {
    emit(state.copyWith(
      translationOwn: translation,
    ));
  }

  void reset() {
    emit(TranslationViewState());
  }
}

Future<Translation> _fetchTranslation(String word) async {
  final existingTranslation = await translateControllerGet(word);
  if (existingTranslation != null) {
    final schemaVersion = existingTranslation.version;
    StoredParsingSchema? storedParsingSchema;
    if (schemaVersion != null) {
      storedParsingSchema = await getParsingSchema(schemaVersion);
    }

    existingTranslation.schema = storedParsingSchema?.schema;

    return existingTranslation;
  }

  StoredParsingSchema? storedParsingSchema = await getParsingSchema('current');

  if (storedParsingSchema == null) {
    throw CustomError(
      code: 404,
      message: 'Can\'t retrieve "current" parsing schema',
    );
  }

  ParsingSchema? parsingSchema = storedParsingSchema.schema;

  String sourceLanguage = 'en';
  String targetLanguage = 'ru';
  final bool wordIsCyrillic = word.isCyrillic();

  if (wordIsCyrillic) {
    sourceLanguage = 'ru';
    targetLanguage = 'en';
  }

  List<dynamic>? translationResult;
  String? pronunciationResult;

  // fetch raw translate
  String translationRaw = await apiPost(
      url: parsingSchema.translation.fields.url,
      params: {
        '${parsingSchema.translation.fields.parameter}': parsingSchema.translation.fields.body
          .replaceAll('{marker}', parsingSchema.translation.fields.marker)
          .replaceAll('{word}', word)
          .replaceAll('{sourceLanguage}', sourceLanguage)
          .replaceAll('{targetLanguage}', targetLanguage)
      }
  );

  translationResult = _retrieveTranslationRawData(translationRaw, parsingSchema.translation.fields.marker);
  // print(translationResult);

  // fetch raw pronunciation
  String pronunciationRaw = await apiPost(
      url: parsingSchema.pronunciation.fields.url,
      params: {
        '${parsingSchema.pronunciation.fields.parameter}': parsingSchema.pronunciation.fields.body
            .replaceAll('{marker}', parsingSchema.pronunciation.fields.marker)
            .replaceAll('{word}', word)
            .replaceAll('{sourceLanguage}', sourceLanguage)
      }
  );

  final pronunciationRawData = _retrieveTranslationRawData(pronunciationRaw, parsingSchema.pronunciation.fields.marker);
  if (pronunciationRawData != null) {
    final base64Value = jmespath.search(parsingSchema.pronunciation.data.value, pronunciationRawData);
    pronunciationResult = parsingSchema.pronunciation.fields.base64Prefix + base64Value;
  }

  print(parsingSchema.translation.translation.value);
  return Translation(
    word: word,
    translation: jmespath.search(parsingSchema.translation.translation.value, translationResult ?? []),
    pronunciation: pronunciationResult,
    raw: translationResult ?? [],
    schema: parsingSchema,
    version: storedParsingSchema.version,
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