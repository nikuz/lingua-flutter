import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import 'package:lingua_flutter/utils/db.dart';
import 'package:lingua_flutter/controllers/translate.dart';
import '../model/list.dart';
import '../model/item.dart';
import 'events.dart';
import 'state.dart';

class TranslationsBloc extends Bloc<TranslationsEvent, TranslationsState> {
  final http.Client httpClient;

  TranslationsBloc({ required this.httpClient }) : super(TranslationsUninitialized()) {
    on<TranslationsRequest>((event, emit) async {
      final TranslationsState currentState = state;
      try {
        emit(TranslationsRequestLoading(
            currentState.translations,
            currentState.totalAmount
        ));
        final Translations translationsList = await _fetchTranslationsList(0, LIST_PAGE_SIZE);
        emit(TranslationsLoaded(
            from: translationsList.from,
            to: translationsList.to,
            totalAmount: translationsList.totalAmount,
            translations: translationsList.translations,
        ));
      } on DBException catch (e) {
        emit(TranslationsError(e));
      } catch (e, s) {
        print(e);
        print(s);
      }
    });

    on<TranslationsRequestMore>((event, emit) async {
      final TranslationsState currentState = state;
      emit(TranslationsRequestMoreLoading(currentState.totalAmount!, currentState.translations));
      try {
        int from = currentState.to!;
        final Translations translationsList = await _fetchTranslationsList(from, from + LIST_PAGE_SIZE);
        emit(TranslationsLoaded(
          from: translationsList.from,
          to: translationsList.to,
          totalAmount: translationsList.totalAmount,
          translations: currentState.translations + translationsList.translations,
        ));
      } on DBException catch (e) {
        emit(TranslationsError(e));
      } catch (e, s) {
        print(e);
        print(s);
      }
    });

    on<TranslationsSearch>((event, emit) async {
      emit(TranslationsSearchLoading());
      try {
        final Translations translationsList = await _fetchTranslationsList(
            0,
            LIST_PAGE_SIZE,
            searchText: event.text
        );
        emit(TranslationsLoaded(
          from: translationsList.from,
          to: translationsList.to,
          totalAmount: translationsList.totalAmount,
          translations: translationsList.translations,
          search: event.text,
        ));
      } on DBException catch (e) {
        emit(TranslationsError(e));
      } catch (e, s) {
        print(e);
        print(s);
      }
    });

    on<TranslationsItemRemove>((event, emit) async {
      final TranslationsState currentState = state;
      try {
        print(currentState);
        print(state);
        if (currentState is TranslationsLoaded) {
          print(event.id);
          await _removeTranslationsItem(event.id);
          emit(currentState.copyWith(
            removedItemId: event.id,
          ));
        }
      } on DBException catch (e) {
        emit(TranslationsError(e));
      } catch (e, s) {
        print(e);
        print(s);
      }
    });

    on<TranslationsUpdateItem>((event, emit) {
      final TranslationsState currentState = state;
      try {
        if (currentState is TranslationsLoaded) {
          String? oldImageUrl = event.imageUrl;
          final String newImage = event.image!;
          final RegExp imageExtension = new RegExp(r'\.[^?]+');

          if (newImage.indexOf('data:image/png') == 0 && oldImageUrl!.indexOf('.png') == -1) {
            oldImageUrl = oldImageUrl.replaceAll(imageExtension, '.png');
          } else if (newImage.indexOf('data:image/jpeg') == 0 && oldImageUrl!.indexOf('.jpeg') == -1) {
            oldImageUrl = oldImageUrl.replaceAll(imageExtension, '.jpeg');
          }

          emit(currentState.copyWith(
            updatedItem: TranslationsItem(
              id: event.id,
              word: event.word,
              translation: event.translation,
              pronunciation: event.pronunciation,
              image: oldImageUrl,
              createdAt: event.createdAt,
              updatedAt: event.updatedAt,
            ),
          ));
        }
      } on DBException catch (e) {
        emit(TranslationsError(e));
      } catch (e, s) {
        print(e);
        print(s);
      }
    });
  }

  Future<Translations> _fetchTranslationsList(int from, int to, {String? searchText}) async {
    Map<String, dynamic> response;

    if (searchText != null) {
      response = await translateControllerSearch(searchText, from, to);
    } else {
      response = await translateControllerGetList(from, to);
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

    response = await translateControllerRemoveItem(id);

    if (response['success'] == true) {
      return true;
    } else {
      return false;
    }
  }
}
