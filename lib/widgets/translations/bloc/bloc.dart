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
  final int _pagerSize = 20;

  TranslationsBloc({@required this.httpClient});

  @override
  TranslationsState get initialState => TranslationsUninitialized();

  @override
  Stream<TranslationsState> mapEventToState(TranslationsEvent event) async* {
    final currentState = state;
    if (event is TranslationsRequest) {
      try {
        int from = currentState.to;
        if (currentState is TranslationsUninitialized) {
          from = 0;
        }
        int to = from + _pagerSize;
        final Translations translationsList = await _fetchTranslationsList(from, to);
        yield TranslationsLoaded(
          from: translationsList.from,
          to: translationsList.to,
          totalAmount: translationsList.totalAmount,
          translations: currentState.translations + translationsList.translations,
        );
      } on ApiException catch (e) {
        yield TranslationsError(e);
      } catch (e, s) {
        print(e);
        print(s);
      }
    } else if (event is TranslationsItemRemove) {
      try {
        final bool itemSuccessfullyRemoved = await _removeTranslationsItem(event.id);
        if (itemSuccessfullyRemoved) {
          final Translations translationsList = await _fetchTranslationsList(
              currentState.from,
              currentState.to
          );
          yield TranslationsLoaded(
            from: translationsList.from,
            to: translationsList.to,
            totalAmount: translationsList.totalAmount,
            translations: translationsList.translations,
          );
        } else {
          yield TranslationsError();
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

  Future<bool> _removeTranslationsItem(int id) async {
    final Map<String, dynamic> response = await apiDelete(
        client: httpClient,
        url: '/translate',
        params: {
          'id': '$id',
        }
    );

    if (response['success'] == true) {
      return true;
    } else {
      return false;
    }
  }
}
