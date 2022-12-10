import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/controllers/local_translation.dart' as local_translate_controller;
import 'package:lingua_flutter/controllers/cloud_translation.dart' as cloud_translate_controller;
import 'package:lingua_flutter/models/error.dart';
import 'package:lingua_flutter/models/translation.dart';
import 'package:lingua_flutter/models/translation_list.dart';
import 'package:lingua_flutter/utils/types.dart';

import '../search_constants.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(const SearchState());

  void fetchTranslations({int from = 0, int to = SearchConstants.itemsPerPage, String? searchText}) async {
    emit(state.copyWith(
      searchText: Wrapped.value(searchText),
      // show loading only on search list refresh, but not on every letter typed into the search field
      loading: searchText == null ? true : false,
    ));

    try {
      TranslationList translationList;

      if (searchText != null) {
        translationList = await local_translate_controller.search(searchText, from, to);
      } else {
        translationList = await local_translate_controller.getList(from, to);
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
        loading: false,
      ));
      rethrow;
    }
  }

  void quickTranslate({
    required String word,
    required String translateFrom,
    required String translateTo,
  }) async {
    try {
      // emit(state.copyWith(
      //   // quickTranslationTimestamp: Wrapped.value(timestamp),
      // ));

      if (word == state.searchText) {
        final translation = await cloud_translate_controller.translate(
          word: word,
          translateFrom: translateFrom,
          translateTo: translateTo,
        );

        if (translation.word != state.searchText) {
          // print('translation.word: ${translation.word}');
          // print('state.searchText: ${state.searchText}');
          // print('word: $word');
        }
        if (translation.word == state.searchText) {
          print('translation.word: ${translation.word}');
          emit(state.copyWith(
            quickTranslation: Wrapped.value(translation),
            // quickTranslationTimestamp: const Wrapped.value(null),
          ));
        }
      }
    } catch (err) {
      emit(state.copyWith(
        quickTranslationError: Wrapped.value(CustomError(
          code: err.hashCode,
          message: err.toString(),
        )),
        // quickTranslationTimestamp: const Wrapped.value(null),
      ));
      rethrow;
    }
  }

  void clearQuickTranslate() {
    emit(state.copyWith(
      quickTranslation: const Wrapped.value(null),
      quickTranslationError: const Wrapped.value(null),
    ));
  }

  void removeTranslation(int id) async {
    try {
      await local_translate_controller.removeItem(id);
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
      rethrow;
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