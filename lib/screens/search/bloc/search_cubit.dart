import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/controllers/request/request.dart' show CancelToken, DioError;
import 'package:lingua_flutter/controllers/dictionary/dictionary.dart' as dictionary_controller;
import 'package:lingua_flutter/controllers/translation/translation.dart' as translation_controller;
import 'package:lingua_flutter/models/error/error.dart';
import 'package:lingua_flutter/models/translation_container/translation_container.dart';
import 'package:lingua_flutter/models/translation_container/translation_list.dart';
import 'package:lingua_flutter/models/language/language.dart';
import 'package:lingua_flutter/utils/types.dart';
import 'package:lingua_flutter/controllers/error_logger/error_logger.dart';

import '../search_constants.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(const SearchState());

  void fetchTranslations({int from = 0, int to = SearchConstants.itemsPerPage, String? searchText}) async {
    emit(state.copyWith(
      searchText: Wrapped.value(searchText),
      // show loading only on search list refresh, but not on every letter typed into the search field
      loading: state.translations.isEmpty,
    ));

    try {
      TranslationList translationList;

      if (searchText != null) {
        translationList = await dictionary_controller.search(searchText, from, to);
      } else {
        translationList = await dictionary_controller.getList(from, to);
      }

      List<TranslationContainer> translations = [];

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
    } catch (err, stack) {
      handleError(state.copyWith(
        error: Wrapped.value(CustomError(
          message: err.toString(),
        )),
        loading: false,
      ), err, stack);
    }
  }

  void quickTranslation({
    required String word,
    required Language translateFrom,
    required Language translateTo,
    CancelToken? cancelToken,
  }) async {
    try {
      if (word == state.searchText) {
        emit(state.copyWith(
          quickTranslationLoading: true,
          quickTranslationError: const Wrapped.value(null),
        ));
        final translation = await translation_controller.translate(
          word: word,
          translateFrom: translateFrom,
          translateTo: translateTo,
          cancelToken: cancelToken,
        );

        if (translation?.word == state.searchText) {
          emit(state.copyWith(
            quickTranslation: Wrapped.value(translation),
            quickTranslationLoading: false,
          ));
        }
      }
    } on DioError catch (err, stack) {
      if (!CancelToken.isCancel(err)) {
        handleError(state.copyWith(
          quickTranslationError: Wrapped.value(CustomError(
            message: err.toString(),
          )),
          quickTranslationLoading: false,
        ), err, stack);
      }
    } catch (err, stack) {
      handleError(state.copyWith(
        quickTranslationError: Wrapped.value(CustomError(
          message: err.toString(),
        )),
        quickTranslationLoading: false,
      ), err, stack);
    }
  }

  void clearQuickTranslation() {
    emit(state.copyWith(
      quickTranslation: const Wrapped.value(null),
      quickTranslationLoading: false,
      quickTranslationError: const Wrapped.value(null),
    ));
  }

  void removeTranslation(int id) async {
    try {
      await dictionary_controller.removeItem(id);
      List<TranslationContainer> translationsClone = [...state.translations];
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
    } catch (err, stack) {
      handleError(state.copyWith(
        error: Wrapped.value(CustomError(
          message: err.toString(),
        )),
      ), err, stack);
    }
  }

  void updateTranslation(TranslationContainer translation) async {
    List<TranslationContainer> translationsClone = [...state.translations];
    int index = translationsClone.indexWhere((item) => item.id == translation.id);
    if (index != -1) {
      translationsClone[index] = translation;
    }

    emit(state.copyWith(
      translations: translationsClone,
    ));
  }

  void handleError(state, err, stack) {
    emit(state);

    Iterable<Object>? information;
    if (err is CustomError) {
      information = err.information;
    }
    recordFatalError(err, stack, information: information);
  }
}