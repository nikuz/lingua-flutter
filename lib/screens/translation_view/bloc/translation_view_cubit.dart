import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/controllers/translate.dart';
import 'package:lingua_flutter/screens/translation_view/models/translation.model.dart';
import 'package:lingua_flutter/utils/types.dart';
import 'package:lingua_flutter/app_config.dart' as appConfig;
import 'package:lingua_flutter/providers/api.dart';
import 'package:lingua_flutter/utils/string.dart';

import 'translation_view_state.dart';

class TranslationViewCubit extends Cubit<TranslationViewState> {
  TranslationViewCubit() : super(TranslationViewState());

  void translate(String word) async {
    try {
      emit(state.copyWith(translateLoading: true));

      final Translation translation = await _fetchTranslation(word);
      List<dynamic>? highestRelevantTranslation;
      String? transcription;
      List<dynamic>? otherTranslations;
      List<dynamic>? definitions;
      List<dynamic>? definitionsSynonyms;
      List<dynamic>? examples;
      int? version = translation.version;
      String? translationWord = translation.translation;
      String? autoSpellingFix;
      bool strangeWord = false;

      if (translation.raw != null) {
        final List<dynamic>? raw = translation.raw;
        if (version == 1) {
          highestRelevantTranslation = raw![0];
          otherTranslations = raw[1];
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
        } else if (version == 2) {
          highestRelevantTranslation = raw![1][0];
          if (raw.length > 3 && raw[3].length >= 6 && raw[3][5] != null) {
            otherTranslations = raw[3][5][0];
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
            && otherTranslations == null;
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
        otherTranslations: otherTranslations,
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
    } catch (e) {
      emit(state.copyWith(
        error: Wrapped.value(e),
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
    } catch (e) {
      emit(state.copyWith(
        error: Wrapped.value(e),
        imageLoading: false,
      ));
    }
  }

  Future<bool> save(Translation translation) async {
    try {
      emit(state.copyWith(
        saveLoading: true,
      ));
      await translateControllerSave({
        'word': '${translation.word}',
        'translation': '${translation.translation}',
        'pronunciationURL': '${translation.pronunciation}',
        'image': '${translation.image}',
        'raw': jsonEncode(translation.raw),
        'version': '${translation.version}',
      });
      emit(state.copyWith(
        saveLoading: false,
      ));

      return true;
    } catch (e) {
      emit(state.copyWith(
        error: Wrapped.value(e),
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
    } catch (e) {
      emit(state.copyWith(
        error: Wrapped.value(e),
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
  Map<String, dynamic>? response = await translateControllerGet(word);

  if (response == null) {
    String sourceLanguage = 'en';
    String targetLanguage = 'ru';
    final bool wordIsCyrillic = isCyrillicWord(word);

    if (wordIsCyrillic) {
      sourceLanguage = 'ru';
      targetLanguage = 'en';
    }

    List<dynamic>? translationResult;
    String pronunciationResult = '';

    String translationRaw = await apiPost(
        url: appConfig.translationURL,
        params: {
          'f.req': '[[["${appConfig.translationMarker}","[[\\"$word\\",\\"$sourceLanguage\\",\\"$targetLanguage\\",true],[null]]",null,"generic"]]]'
        }
    );

    final List<String> translationRawStrings = translationRaw.split('\n');

    for (int i = 0, l = translationRawStrings.length; i < l; i++) {
      if (translationRawStrings[i].contains(appConfig.translationMarker)) {
        translationResult = jsonDecode(jsonDecode(translationRawStrings[i])[0][2]);
        break;
      }
    }

    if (!wordIsCyrillic) {
      String correctedWord = word;

      final List<dynamic>? correctionData = translationResult![0][1];
      if (correctionData != null && correctionData[0] != null && correctionData[0][0] != null && correctionData[0][0][1] != null) {
        correctedWord = correctionData[0][0][1].replaceAll(new RegExp(r'</?[i|b]>'), '');
      }

      if (word != correctedWord) {
        return _fetchTranslation(correctedWord);
      }

      String pronunciationRaw = await apiPost(
          url: appConfig.translationURL,
          params: {
            'f.req': '[[["${appConfig.pronunciationMarker}","[\\"$word\\",\\"$sourceLanguage\\",null,\\"null\\"]",null,"generic"]]]'
          }
      );

      final List<String> pronunciationRawStrings = pronunciationRaw.split('\n');

      for (int i = 0, l = pronunciationRawStrings.length; i < l; i++) {
        if (pronunciationRawStrings[i].contains(appConfig.pronunciationMarker)) {
          final decodedPronunciationData = jsonDecode(pronunciationRawStrings[i]);
          pronunciationResult = 'data:audio/mpeg;base64,' + jsonDecode(decodedPronunciationData[0][2])[0];
          break;
        }
      }
    }

    response = {
      'raw': translationResult,
      'pronunciation': pronunciationResult,
      'remote': true,
      'version': 2,
    };
  }

  return Translation(
    id: response['id'],
    translation: response['translation'],
    pronunciation: response['pronunciation'],
    image: response['image'],
    raw: response['raw'],
    createdAt: response['created_at'],
    updatedAt: response['updated_at'],
    remote: response['remote'] == true,
    version: response['version'],
  );
}