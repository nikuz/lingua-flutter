import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import 'package:lingua_flutter/utils/api.dart';
import 'package:lingua_flutter/utils/db.dart';
import 'package:lingua_flutter/helpers/api.dart';
import 'package:lingua_flutter/helpers/db.dart';
import 'package:lingua_flutter/controllers/translate.dart';
import '../model/list.dart';
import '../model/item.dart';
import 'events.dart';
import 'state.dart';

class TranslationsBloc extends Bloc<TranslationsEvent, TranslationsState> {
  final http.Client httpClient;

  TranslationsBloc({@required this.httpClient}) : assert(httpClient is http.Client);

  @override
  TranslationsState get initialState => TranslationsUninitialized();

  @override
  Stream<TranslationsState> mapEventToState(TranslationsEvent event) async* {
    final currentState = state;
    if (event is TranslationsRequest) {
      try {
        yield TranslationsRequestLoading(
            currentState.translations,
            currentState.totalAmount
        );
        final Translations translationsList = await _fetchTranslationsList(0, LIST_PAGE_SIZE);
        yield TranslationsLoaded(
          from: translationsList.from,
          to: translationsList.to,
          totalAmount: translationsList.totalAmount,
          translations: translationsList.translations,
        );
      } on ApiException catch (e) {
        yield TranslationsError(e);
      } catch (e, s) {
        print(e);
        print(s);
      }
    } else if (event is TranslationsRequestMore) {
      yield TranslationsRequestMoreLoading(currentState.totalAmount, currentState.translations);
      try {
        int from = currentState.to;
        final Translations translationsList = await _fetchTranslationsList(from, from + LIST_PAGE_SIZE);
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
    } else if (event is TranslationsSearch) {
      yield TranslationsSearchLoading();
      try {
        final Translations translationsList = await _fetchTranslationsList(
            0,
            LIST_PAGE_SIZE,
            searchText: event.text
        );
        yield TranslationsLoaded(
          from: translationsList.from,
          to: translationsList.to,
          totalAmount: translationsList.totalAmount,
          translations: translationsList.translations,
          search: event.text,
        );
      } on ApiException catch (e) {
        yield TranslationsError(e);
      } catch (e, s) {
        print(e);
        print(s);
      }
    } else if (event is TranslationsItemRemove) {
      try {
        if (currentState is TranslationsLoaded) {
          await _removeTranslationsItem(event.id);
          yield currentState.copyWith(
            removedItemId: event.id,
          );
        }
      } on ApiException catch (e) {
        yield TranslationsError(e);
      } on DBException catch (e) {
        yield TranslationsError(e);
      } catch (e, s) {
        print(e);
        print(s);
      }
    } else if (event is TranslationsUpdateItem) {
      try {
        if (currentState is TranslationsLoaded) {
          String oldImageUrl = event.imageUrl;
          final String newImage = event.image;
          final RegExp imageExtension = new RegExp(r'\.[^?]+');

          if (newImage.indexOf('data:image/png') == 0 && oldImageUrl.indexOf('.png') == -1) {
            oldImageUrl = oldImageUrl.replaceAll(imageExtension, '.png');
          } else if (newImage.indexOf('data:image/jpeg') == 0 && oldImageUrl.indexOf('.jpeg') == -1) {
            oldImageUrl = oldImageUrl.replaceAll(imageExtension, '.jpeg');
          }

          yield currentState.copyWith(
            updatedItem: TranslationsItem(
              id: event.id,
              word: event.word,
              translation: event.translation,
              pronunciation: event.pronunciation,
              image: oldImageUrl,
              createdAt: event.createdAt,
              updatedAt: event.updatedAt,
            ),
          );
        }
      } on ApiException catch (e) {
        yield TranslationsError(e);
      } catch (e, s) {
        print(e);
        print(s);
      }
    }
  }

  Future<Translations> _fetchTranslationsList(int from, int to, {String searchText}) async {
    Map<String, dynamic> response;

    if (db != null) {
      if (searchText != null) {
        response = await translateControllerSearch(searchText, from, to);
      } else {
        response = await translateControllerGetList(from, to);
      }
    } else {
      final String url = searchText == null ? '/translations' : '/translate/search';
      response = await apiGet(
          client: httpClient,
          url: url,
          params: {
            'q': searchText,
            'from': '$from',
            'to': '$to',
          }
      );
    }

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
            updatedAt: rawTranslation['updated_at'],
          )
      )).toList(),
    );
  }

  Future<bool> _removeTranslationsItem(int id) async {
    Map<String, dynamic> response;

    if (db != null) {
      response = await translateControllerRemoveItem(id);
    } else {
      response = await apiDelete(
          client: httpClient,
          url: '/translate',
          params: {
            'id': '$id',
          }
      );
    }

    if (response['success'] == true) {
      return true;
    } else {
      return false;
    }
  }
}
