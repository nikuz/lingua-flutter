import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/models/translation.dart';
import 'package:lingua_flutter/models/error.dart';
import 'package:lingua_flutter/models/language.dart';
import 'package:lingua_flutter/controllers/local_translation.dart' as local_translate_controller;
import 'package:lingua_flutter/controllers/cloud_translation.dart' as cloud_translate_controller;
import 'package:lingua_flutter/controllers/images.dart' as images_controller;
import 'package:lingua_flutter/controllers/pronunciation.dart' as pronunciation_controller;
import 'package:lingua_flutter/utils/types.dart';
import 'package:lingua_flutter/providers/error_logger.dart';

import 'translation_view_state.dart';

class TranslationViewCubit extends Cubit<TranslationViewState> {
  TranslationViewCubit() : super(const TranslationViewState());

  void translate(String word, Language translateFrom, Language translateTo) async {
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
        translateLoading: false,
      ));
    } catch (err, stack) {
      emit(state.copyWith(
        error: Wrapped.value(CustomError(
          code: err.hashCode,
          message: err.toString(),
        )),
        translateLoading: false,
      ));

      Iterable<Object>? information;
      if (err is CustomError) {
        information = err.information;
      }
      recordFatalError(err, stack, information: information);
    }
  }

  void setTranslation(TranslationContainer translation) {
    emit(state.copyWith(
      word: translation.word,
      translation: translation
    ));
  }

  void fetchImages(String word, { bool setFirstImage = false }) async {
    emit(state.copyWith(
      imageLoading: true,
      imageSearchWord: word,
    ));

    try {
      final List<String>? images = await images_controller.search(word);
      String? image;
      if (images != null && images.isNotEmpty) {
        image = images[0];
      }

      emit(state.copyWith(
        images: images,
        imageLoading: false,
        translation: setFirstImage
            ? state.translation?.copyWith(image: image)
            : state.translation,
        imageIsUpdated: setFirstImage ? true : state.imageIsUpdated,
      ));
    } catch (err, stack) {
      emit(state.copyWith(
        imageError: Wrapped.value(CustomError(
          code: err.hashCode,
          message: err.toString(),
        )),
        imageLoading: false,
      ));

      Iterable<Object>? information;
      if (err is CustomError) {
        information = err.information;
      }
      recordFatalError(err, stack, information: information);
    }
  }

  void fetchPronunciations(TranslationContainer translation) async {
    if (translation.schema == null) {
      return null;
    }

    emit(state.copyWith(
      pronunciationLoading: true,
    ));

    try {
      List<String?> results = await Future.wait([
        pronunciation_controller.retrieve(
          word: translation.word,
          schema: translation.schema!,
          language: translation.translateFrom,
        ),
        pronunciation_controller.retrieve(
          word: translation.mostRelevantTranslation,
          schema: translation.schema!,
          language: translation.translateTo,
        ),
      ]);

      emit(state.copyWith(
        translation: state.translation?.copyWith(
          pronunciationFrom: results[0],
          pronunciationTo: results[1],
        ),
        imageLoading: false,
      ));
    } catch (err, stack) {
      emit(state.copyWith(
        pronunciationError: Wrapped.value(CustomError(
          code: err.hashCode,
          message: err.toString(),
        )),
        pronunciationLoading: false,
      ));

      Iterable<Object>? information;
      if (err is CustomError) {
        information = err.information;
      }
      recordFatalError(err, stack, information: information);
    }
  }

  Future<void> save(TranslationContainer translation) async {
    try {
      emit(state.copyWith(
        updateLoading: true,
      ));

      String? newPronunciationTo;
      if (state.translationIsUpdated && translation.schema != null) {
        newPronunciationTo = await pronunciation_controller.retrieve(
          word: translation.translation,
          schema: translation.schema!,
          language: translation.translateTo,
        );
      }
      if (newPronunciationTo != null) {
        translation = translation.copyWith(
          pronunciationTo: newPronunciationTo,
        );
      }

      await local_translate_controller.save(translation);

      emit(state.copyWith(
        updateLoading: false,
      ));
    } catch (err, stack) {
      emit(state.copyWith(
        error: Wrapped.value(CustomError(
          code: err.hashCode,
          message: err.toString(),
        )),
        updateLoading: false,
      ));
      recordFatalError(err, stack);
    }
  }

  Future<void> update(TranslationContainer translation) async {
    try {
      emit(state.copyWith(
        updateLoading: true,
      ));

      String? newPronunciationTo;
      if (state.translationIsUpdated && translation.schema != null) {
        newPronunciationTo = await pronunciation_controller.retrieve(
          word: translation.translation,
          schema: translation.schema!,
          language: translation.translateTo,
        );
      }
      if (newPronunciationTo != null) {
        translation = translation.copyWith(
          pronunciationTo: newPronunciationTo,
        );
      }

      await local_translate_controller.update(translation);

      emit(state.copyWith(
        updateLoading: false,
      ));
    } catch (err, stack) {
      emit(state.copyWith(
        error: Wrapped.value(CustomError(
          code: err.hashCode,
          message: err.toString(),
        )),
        updateLoading: false,
      ));
      recordFatalError(err, stack);
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

