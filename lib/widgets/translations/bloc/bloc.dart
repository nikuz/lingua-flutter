import 'dart:async';
import 'package:lingua_flutter/utils/api.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import 'package:lingua_flutter/helpers/api.dart';
import '../model/list.dart';
import '../model/item.dart';
import './events.dart';
import './state.dart';

class TranslationsBloc extends Bloc<TranslationsEvent, TranslationsState> {
  final http.Client httpClient;

  TranslationsBloc({@required this.httpClient});

  @override
  TranslationsState get initialState => TranslationsUninitialized();

  @override
  Stream<TranslationsState> mapEventToState(TranslationsEvent event) async* {
    final currentState = state;
    if (event is TranslationsRequest) {
      try {
        if (currentState is TranslationsUninitialized) {
          final Translations translationsList = await _fetchTranslationsList(0, 20);
          print(translationsList);
          yield TranslationsLoaded(
              from: translationsList.from,
              to: translationsList.to,
              totalAmount: translationsList.totalAmount,
              translations: translationsList.translations,
          );
          return;
        }
      } on ApiException catch (e) {
        yield TranslationsError(e);
      } catch (e, s) {
        print(e);
        print(s);
      }
    }
  }

  Future<Translations> _fetchTranslationsList(int from, int to) async {
    final Map<String, dynamic> response = await apiGet(
        client: httpClient,
        url: '/translations',
        params: {
          'from': '$from',
          'to': '$to',
        }
    );

    return Translations(
      from: response['from'],
      to: response['to'],
      totalAmount: response['totalAmount'],
      translations: response['translations'].map<TranslationsItem>((rawTranslation) => (
          TranslationsItem(
            id: rawTranslation['id'],
            word: rawTranslation['word'],
            translation: rawTranslation['translation'],
            pronunciation: rawTranslation['pronunciation'],
            image: rawTranslation['image'],
            createdAt: rawTranslation['created_at'],
          )
      )).toList(),
    );
  }
}
