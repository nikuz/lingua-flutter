import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/controllers/translate.dart';
import 'package:lingua_flutter/screens/translation_view/models/translation.model.dart';
import 'package:lingua_flutter/utils/types.dart';

import '../search_constants.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchState());

  void fetchTranslations({int from = 0, int to = SearchConstants.itemsPerPage, String? searchText}) async {
    emit(state.copyWith(
      searchText: searchText,
      loading: true,
    ));

    try {
      Map<String, dynamic> response;

      if (searchText != null) {
        response = await translateControllerSearch(searchText, from, to);
      } else {
        response = await translateControllerGetList(from, to);
      }

      List<Translation> translations = [];

      final List<Translation> newTranslations = response['translations']
          .map<Translation>((rawTranslation) => (Translation(
                id: rawTranslation['id'],
                word: rawTranslation['word'],
                translation: rawTranslation['translation'],
                pronunciation: rawTranslation['pronunciation'],
                image: rawTranslation['image'],
                createdAt: rawTranslation['created_at'],
                updatedAt: rawTranslation['updated_at'],
              )))
          .toList();

      if (to > SearchConstants.itemsPerPage) {
        translations = [...state.translations, ...newTranslations];
      } else {
        translations = newTranslations;
      }

      emit(state.copyWith(
        loading: false,
        from: response['from'],
        to: response['to'],
        totalAmount: response['totalAmount'],
        translations: translations,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: Wrapped.value(e),
      ));
    }
  }

  void removeTranslation(int id) async {
    await translateControllerRemoveItem(id);
    List<Translation> translationsClone = [...state.translations];
    int to = state.to;
    int totalAmount = state.totalAmount;

    int index = translationsClone.indexWhere((item) => item.id == id);
    if (index != -1) {
      translationsClone.removeAt(index);
      to--;
      totalAmount--;
    }

    emit(state.copyWith(
      to: to,
      totalAmount: totalAmount,
      translations: translationsClone,
    ));
  }

  void updateTranslation(Translation translation) async {
    List<Translation> translationsClone = [...state.translations];
    int index = translationsClone.indexWhere((item) => item.id == translation.id);
    if (index != -1) {
      translationsClone[index] = translation;
    }

    emit(state.copyWith(
      translations: translationsClone,
    ));
  }
}