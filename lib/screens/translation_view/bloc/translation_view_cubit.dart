import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/models/translation.dart';
import 'package:lingua_flutter/models/error.dart';
import 'package:lingua_flutter/controllers/local_translation.dart' as local_translate_controller;
import 'package:lingua_flutter/controllers/cloud_translation.dart' as cloud_translate_controller;
import 'package:lingua_flutter/controllers/images.dart' as images_controller;
import 'package:lingua_flutter/utils/types.dart';

import 'translation_view_state.dart';

class TranslationViewCubit extends Cubit<TranslationViewState> {
  TranslationViewCubit() : super(const TranslationViewState());

  void translate(String word, String translateFrom, String translateTo) async {
    try {
      emit(state.copyWith(translateLoading: true));

      final translation = await cloud_translate_controller.translate(
        word: word,
        translateFrom: translateFrom,
        translateTo: translateTo,
      );

      emit(state.copyWith(
        word: word,
        imageSearchWord: word,
        translation: translation,
      ));
    } catch (err) {
      emit(state.copyWith(
        error: Wrapped.value(CustomError(
          code: err.hashCode,
          message: err.toString(),
        )),
        translateLoading: false,
      ));
      rethrow;
    }
  }

  Future<String?> fetchImages(String word) async {
    emit(state.copyWith(
      imageLoading: true,
      imageSearchWord: word,
    ));

    try {
      final List<String>? images = await images_controller.search(word);

      emit(state.copyWith(
        images: images,
        imageLoading: false,
      ));
      return images?[0];
    } catch (err) {
      emit(state.copyWith(
        error: Wrapped.value(CustomError(
          code: err.hashCode,
          message: err.toString(),
        )),
        imageLoading: false,
      ));
      rethrow;
    }
  }

  Future<void> save(Translation translation) async {
    try {
      emit(state.copyWith(
        updateLoading: true,
      ));

      await local_translate_controller.save(translation);

      emit(state.copyWith(
        updateLoading: false,
      ));
    } catch (err) {
      emit(state.copyWith(
        error: Wrapped.value(CustomError(
          code: err.hashCode,
          message: err.toString(),
        )),
        updateLoading: false,
      ));
      rethrow;
    }
  }

  Future<void> update(Translation translation) async {
    try {
      emit(state.copyWith(
        updateLoading: true,
      ));

      await local_translate_controller.update(translation);

      emit(state.copyWith(
        updateLoading: false,
      ));
    } catch (err) {
      emit(state.copyWith(
        error: Wrapped.value(CustomError(
          code: err.hashCode,
          message: err.toString(),
        )),
        updateLoading: false,
      ));
      rethrow;
    }
  }

  void setImage(String image) {
    emit(state.copyWith(
      translation: state.translation?.copyWith(
        image: image,
      ),
      imageIsUpdated: true,
    ));
  }

  void setOwnTranslation(String translation) {
    emit(state.copyWith(
      translation: state.translation?.copyWith(
        translation: translation,
      ),
      translationIsUpdated: true,
    ));
  }

  void reset() {
    emit(const TranslationViewState());
  }
}

