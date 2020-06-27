import 'dart:async';
import 'dart:convert';
import 'package:lingua_flutter/utils/api.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import 'package:lingua_flutter/helpers/api.dart';
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
        List<dynamic> otherTranslations;
        List<dynamic> definitions;
        List<dynamic> definitionsSynonyms;
        List<dynamic> examples;
        String word = translation.word;
        String translationWord = translation.translation;
        String autoSpellingFix;
        bool strangeWord = false;

        if (translation.raw != null) {
          final List<dynamic> raw = translation.raw;
          highestRelevantTranslation = raw[0];
          otherTranslations = raw[1];
          if (raw.length >= 12) {
            definitionsSynonyms = raw[11];
          }
          if (raw.length >= 13) {
            definitions = raw[12];
          }
          if (raw.length >= 14) {
            examples = raw[13];
          }

          if (translationWord == null) {
            translationWord = highestRelevantTranslation[0][0];
          }

          if (word.toLowerCase() != highestRelevantTranslation[0][1].toLowerCase()) {
            autoSpellingFix = word;
            word = highestRelevantTranslation[0][1];
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
          otherTranslations: otherTranslations,
          definitions: definitions,
          definitionsSynonyms: definitionsSynonyms,
          examples: examples,
          autoSpellingFix: autoSpellingFix,
          strangeWord: strangeWord,
          raw: translation.raw,
        );
      } on ApiException catch (e) {
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
          );
          yield currentState.copyWith(
            saveLoading: false,
            saveSuccess: true,
          );
        }
      } on ApiException catch (e) {
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
      } on ApiException catch (e) {
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
    final Map<String, dynamic> response = await apiGet(
        client: httpClient,
        url: '/translate',
        params: {
          'q': '$word',
        }
    );

    return Translation(
      id: response['id'],
      word: response['word'],
      translation: response['translation'],
      pronunciation: response['pronunciation'],
      image: response['image'],
      raw: response['raw'],
      createdAt: response['created_at'],
      updatedAt: response['updated_at'],
    );
  }

  Future<List<dynamic>> _fetchImage(String word) async {
    final Map<String, dynamic> response = await apiGet(
        client: httpClient,
        url: '/image',
        params: {
          'q': '$word',
        }
    );

    return response['images'];
  }

  Future<bool> _fetchSave({
    String word,
    String translation,
    String pronunciationURL,
    String image,
    List<dynamic> raw,
  }) async {
    await apiPost(
        client: httpClient,
        url: '/translate',
        params: {
          'word': '$word',
          'translation': '$translation',
          'pronunciationURL': '$pronunciationURL',
          'image': '$image',
          'raw': jsonEncode(raw),
        }
    );

    return true;
  }

  Future<bool> _fetchUpdate({
    String word,
    String translation,
    String image,
  }) async {
    await apiPut(
        client: httpClient,
        url: '/translate',
        params: {
          'word': '$word',
          'image': '${image != null ? image : ''}',
          'translation': '$translation',
        }
    );

    return true;
  }
}
