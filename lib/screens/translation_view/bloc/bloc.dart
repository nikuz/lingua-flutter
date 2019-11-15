import 'dart:async';
import 'package:lingua_flutter/utils/api.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import 'package:lingua_flutter/helpers/api.dart';
import '../model/item.dart';
import './events.dart';
import './state.dart';

class TranslationBloc extends Bloc<TranslationEvent, TranslationState> {
  final http.Client httpClient;

  TranslationBloc({@required this.httpClient}) : assert(httpClient is http.Client);

  @override
  TranslationState get initialState => TranslationUninitialized();

  @override
  Stream<TranslationState> mapEventToState(TranslationEvent event) async* {
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
          if (raw.length >= 13) {
            definitions = raw[12];
          }
          if (raw.length >= 14) {
            examples = raw[13];
          }

          if (translationWord == null) {
            translationWord = highestRelevantTranslation[0][0];
          }

          if (word != highestRelevantTranslation[0][1]) {
            autoSpellingFix = word;
            word = highestRelevantTranslation[0][1];
          }

          strangeWord = word.toLowerCase() == translationWord.toLowerCase();
        }
        yield TranslationLoaded(
          id: translation.id,
          word: word,
          translationWord: translationWord,
          pronunciation: translation.pronunciation,
          image: translation.image,
          createdAt: translation.createdAt,
          highestRelevantTranslation: highestRelevantTranslation,
          otherTranslations: otherTranslations,
          definitions: definitions,
          definitionsSynonyms: definitionsSynonyms,
          examples: examples,
          autoSpellingFix: autoSpellingFix,
          strangeWord: strangeWord,
        );
      } on ApiException catch (e) {
        yield TranslationError(e);
      } catch (e, s) {
        print(e);
        print(s);
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
    );
  }
}
