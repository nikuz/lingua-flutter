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
        yield TranslationLoaded(
          id: translation.id,
          word: translation.word,
          translation: translation.translation,
          pronunciation: translation.pronunciation,
          raw: translation.raw,
          image: translation.image,
          createdAt: translation.createdAt,
        );
      } on ApiException catch (e) {
        yield TranslationError(e);
      } catch (e, s) {
        print(e);
        print(s);
      }
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
