import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/controllers/translation.dart';
import 'package:lingua_flutter/models/error.dart';
import 'package:lingua_flutter/models/translation.dart';
import 'package:lingua_flutter/models/translation_list.dart';
import 'package:lingua_flutter/utils/types.dart';

import '../search_constants.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchState());

  void fetchTranslations({int from = 0, int to = SearchConstants.itemsPerPage, String? searchText}) async {
    emit(state.copyWith(
      searchText: Wrapped.value(searchText),
      loading: true,
    ));

    try {
      TranslationList translationList;

      if (searchText != null) {
        translationList = await translateControllerSearch(searchText, from, to);
      } else {
        translationList = await translateControllerGetList(from, to);
      }

      List<Translation> translations = [];

      if (to > SearchConstants.itemsPerPage) {
        translations = [...state.translations, ...translationList.translations];
      } else {
        translations = translationList.translations;
      }

      emit(state.copyWith(
        loading: false,
        from: translationList.from,
        to: translationList.to,
        totalAmount: translationList.totalAmount,
        translations: translations,
      ));
    } catch (err) {
      emit(state.copyWith(
        error: Wrapped.value(CustomError(
          code: err.hashCode,
          message: err.toString(),
        )),
      ));
      throw err;
    }
  }

  void removeTranslation(int id) async {
    try {
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
    } catch (err) {
      emit(state.copyWith(
        error: Wrapped.value(CustomError(
          code: err.hashCode,
          message: err.toString(),
        )),
      ));
      throw err;
    }
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