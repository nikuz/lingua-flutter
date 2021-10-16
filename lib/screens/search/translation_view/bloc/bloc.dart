import 'dart:async';
import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import 'package:lingua_flutter/app_config.dart' as appConfig;
import 'package:lingua_flutter/utils/api.dart';
import 'package:lingua_flutter/utils/db.dart';
import 'package:lingua_flutter/utils/string.dart';
import 'package:lingua_flutter/helpers/api.dart';
import 'package:lingua_flutter/controllers/translate.dart';

import '../model/item.dart';
import 'events.dart';
import 'state.dart';

class TranslationBloc extends Bloc<TranslationEvent, TranslationState> {
  final http.Client httpClient;

  TranslationBloc({@required this.httpClient}) : assert(httpClient is http.Client);

  @override
  TranslationState get initialState => TranslationUninitialized();

  @override
  Stream<TranslationState> mapEventToState(TranslationEvent event) async* {
    final currentState = state;
    if (event is TranslationRequest) {
      try {
        yield TranslationRequestLoading();
        final Translation translation = await _fetchTranslation(event.word);
        List<dynamic> highestRelevantTranslation;
        String transcription;
        List<dynamic> otherTranslations;
        List<dynamic> definitions;
        List<dynamic> definitionsSynonyms;
        List<dynamic> examples;
        int version = translation.version;
        String word = translation.word;
        String translationWord = translation.translation;
        String autoSpellingFix;
        bool strangeWord = false;

        if (translation.raw != null) {
          final List<dynamic> raw = translation.raw;
          if (version == 1) {
            highestRelevantTranslation = raw[0];
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
              translationWord = highestRelevantTranslation[0][0];
            }

            if (word.toLowerCase() != highestRelevantTranslation[0][1].toLowerCase()) {
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
            highestRelevantTranslation = raw[1][0];
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
              translationWord = highestRelevantTranslation[0][5][0][0];
            }

            if (raw.length > 3 && word.toLowerCase() != raw[3][0].toLowerCase()) {
              autoSpellingFix = word;
              word = raw[3][0];
            }

            transcription = raw[0][0];
          }

          strangeWord = word.toLowerCase() == translationWord.toLowerCase()
              && otherTranslations == null;
        }

        yield TranslationLoaded(
          id: translation.id,
          word: word,
          translationWord: translationWord,
          pronunciation: translation.pronunciation,
          image: translation.image,
          images: [],
          imageSearchWord: word,
          imageLoading: false,
          imageUpdate: false,
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
        );
      } on ApiException catch (e) {
        yield TranslationError(e);
      } on DBException catch (e) {
        yield TranslationError(e);
      } catch (e, s) {
        print(e);
        print(s);
      }
    } else if (event is TranslationRequestImage) {
      try {
        if (currentState is TranslationLoaded) {
          yield currentState.copyWith(
            imageLoading: true,
            imageSearchWord: event.word,
          );
          final List<dynamic> imagesData = await _fetchImage(event.word);
          yield currentState.copyWith(
            images: imagesData,
            imageLoading: false,
            imageSearchWord: event.word,
          );
        }
      } on ApiException catch (e) {
        yield TranslationError(e);
      } catch (e, s) {
        print(e);
        print(s);
      }
    } else if (event is TranslationSave) {
      try {
        if (currentState is TranslationLoaded) {
          yield currentState.copyWith(
            saveLoading: true,
          );
          await _fetchSave(
            word: event.word,
            translation: event.translation,
            pronunciationURL: event.pronunciationURL,
            image: event.image,
            raw: event.raw,
            version: event.version,
          );
          yield currentState.copyWith(
            saveLoading: false,
            saveSuccess: true,
          );
        }
      } on DBException catch (e) {
        yield TranslationError(e);
      } catch (e, s) {
        print(e);
        print(s);
      }
    } else if (event is TranslationUpdate) {
      try {
        if (currentState is TranslationLoaded) {
          yield currentState.copyWith(
            updateLoading: true,
          );
          await _fetchUpdate(
              word: currentState.word,
              translation: event.word,
              image: event.image,
          );
          yield currentState.copyWith(
            translationWord: event.word,
            updateLoading: false,
            updateSuccess: true,
            imageUpdate: false,
          );
        }
      } on DBException catch (e) {
        yield TranslationError(e);
      } catch (e, s) {
        print(e);
        print(s);
      }
    } else if (event is TranslationSelectImage) {
      if (currentState is TranslationLoaded) {
        yield currentState.copyWith(
          image: event.source,
          imageUpdate: true,
        );
      }
    }  else if (event is TranslationSetOwn) {
      if (currentState is TranslationLoaded) {
        yield currentState.copyWith(
          translationOwn: event.translation,
        );
      }
    } else if (event is TranslationClear) {
      yield TranslationUninitialized();
    }
  }

  Future<Translation> _fetchTranslation(String word) async {
    Map<String, dynamic> response = await translateControllerGet(word);

    if (response == null) {
      String sourceLanguage = 'en';
      String targetLanguage = 'ru';
      final bool wordIsCyrillic = isCyrillicWord(word);

      if (wordIsCyrillic) {
        sourceLanguage = 'ru';
        targetLanguage = 'en';
      }

      List<dynamic> translationResult;
      String pronunciationResult = '';

      String translationRaw = await apiPost(
          client: httpClient,
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

        final List<dynamic> correctionData = translationResult[0][1];
        if (correctionData != null && correctionData[0] != null && correctionData[0][0] != null && correctionData[0][0][1] != null) {
          correctedWord = correctionData[0][0][1].replaceAll(new RegExp(r'</?[i|b]>'), '');
        }

        if (word != correctedWord) {
          return _fetchTranslation(correctedWord);
        }

        String pronunciationRaw = await apiPost(
            client: httpClient,
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
        'word': word,
        'raw': translationResult,
        'pronunciation': pronunciationResult,
        'remote': true,
        'version': 2,
      };
    }

    return Translation(
      id: response['id'],
      word: response['word'],
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

  Future<List<String>> _fetchImage(String word) async {
    final String imagesRaw = await apiGet(
        client: httpClient,
        url: appConfig.imagesURL.replaceFirst('{word}', word),
        headers: {
          'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36',
        },
    );

    final imageReg = RegExp(r"'(data:image[^']{8000,})'");
    final base64EndReg = RegExp(r'\\x3d');
    final slashReg = RegExp(r'\\/');
    final List<String> imagesRawStrings = imagesRaw.split('\n');
    List<String> resultImages = [];

    for (int i = 0, l = imagesRawStrings.length; i < l; i++) {
      if (imagesRawStrings[i].contains(appConfig.imageMarker)) {
        Iterable<RegExpMatch> imageParts = imageReg.allMatches(imagesRawStrings[i]);
        for (var item in imageParts) {
          final String match = item.group(1);
          if (match != null) {
            final String decodedImageString = match
                .replaceAll(slashReg, '/')
                .replaceAll(base64EndReg, '=');

            resultImages.add(decodedImageString);
          }
        }
      }
    }

    return resultImages;
  }

  Future<bool> _fetchSave({
    String word,
    String translation,
    String pronunciationURL,
    String image,
    List<dynamic> raw,
    int version,
  }) async {
    await translateControllerSave({
      'word': '$word',
      'translation': '$translation',
      'pronunciationURL': '$pronunciationURL',
      'image': '$image',
      'raw': jsonEncode(raw),
      'version': '$version',
    });

    return true;
  }

  Future<bool> _fetchUpdate({
    String word,
    String translation,
    String image,
  }) async {
    await translateControllerUpdate({
      'word': '$word',
      'image': '${image != null ? image : ''}',
      'translation': '$translation',
    });

    return true;
  }
}
