import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/models/translation.dart';
import 'package:lingua_flutter/models/error.dart';
import 'package:lingua_flutter/models/language.dart';
import 'package:lingua_flutter/controllers/local_translation.dart' as local_translate_controller;
import 'package:lingua_flutter/controllers/cloud_translation.dart' as cloud_translate_controller;
import 'package:lingua_flutter/controllers/images/images.dart' as images_controller;
import 'package:lingua_flutter/controllers/pronunciation.dart' as pronunciation_controller;
import 'package:lingua_flutter/providers/api.dart';
import 'package:lingua_flutter/utils/types.dart';
import 'package:lingua_flutter/providers/error_logger.dart';

import 'translation_view_state.dart';

class TranslationViewCubit extends Cubit<TranslationViewState> {
  TranslationViewCubit() : super(const TranslationViewState());

  void translate({
    required String word,
    required Language translateFrom,
    required Language translateTo,
    CancelToken? cancelToken,
  }) async {
    try {
      emit(state.copyWith(translateLoading: true));

      final translation = await cloud_translate_controller.translate(
        word: word,
        translateFrom: translateFrom,
        translateTo: translateTo,
        cancelToken: cancelToken,
      );

      if (state.translateLoading) {
        emit(state.copyWith(
          word: word,
          imageSearchWord: word,
          translation: translation,
          translateLoading: false,
        ));
      }
    } on DioError catch (err, stack) {
      if (!CancelToken.isCancel(err)) {
        handleError(state.copyWith(
          error: Wrapped.value(CustomError(
            code: err.hashCode,
            message: err.toString(),
          )),
          translateLoading: false,
        ), err, stack);
      }
    } catch (err, stack) {
      handleError(state.copyWith(
        error: Wrapped.value(CustomError(
          code: err.hashCode,
          message: err.toString(),
        )),
        translateLoading: false,
      ), err, stack);
    }
  }

  void setTranslation(TranslationContainer translation) {
    emit(state.copyWith(
      word: translation.word,
      translation: translation
    ));
  }

  void fetchImages(String word, {
    bool selectFirstImage = false,
    CancelToken? cancelToken,
  }) async {
    emit(state.copyWith(
      imageLoading: true,
      imageSearchWord: word,
    ));

    try {
      final List<String>? images = await images_controller.search(word, cancelToken);
      String? image;
      if (images != null && images.isNotEmpty) {
        image = images[0];
      }

      if (state.translation != null) {
        emit(state.copyWith(
          images: images,
          imageLoading: false,
          translation: selectFirstImage
              ? state.translation?.copyWith(image: image)
              : state.translation,
          imageIsUpdated: selectFirstImage ? true : state.imageIsUpdated,
        ));
      }
    } on DioError catch (err, stack) {
      if (!CancelToken.isCancel(err)) {
        handleError(state.copyWith(
          imageError: Wrapped.value(CustomError(
            code: err.hashCode,
            message: err.toString(),
          )),
          imageLoading: false,
        ), err, stack);
      }
    } catch (err, stack) {
      handleError(state.copyWith(
        imageError: Wrapped.value(CustomError(
          code: err.hashCode,
          message: err.toString(),
        )),
        imageLoading: false,
      ), err, stack);
    }
  }

  void fetchPronunciations(TranslationContainer translation, CancelToken cancelToken) async {
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
          cancelToken: cancelToken,
        ),
        pronunciation_controller.retrieve(
          word: translation.mostRelevantTranslation,
          schema: translation.schema!,
          language: translation.translateTo,
          cancelToken: cancelToken,
        ),
      ]);

      if (state.translation != null && state.translation!.word == translation.word) {
        emit(state.copyWith(
          translation: state.translation?.copyWith(
            pronunciationFrom: results[0],
            pronunciationTo: results[1],
          ),
          pronunciationLoading: false,
        ));
      }
    } on DioError catch (err, stack) {
      if (!CancelToken.isCancel(err)) {
        handleError(state.copyWith(
          pronunciationError: Wrapped.value(CustomError(
            code: err.hashCode,
            message: err.toString(),
          )),
          pronunciationLoading: false,
        ), err, stack);
      }
    } catch (err, stack) {
      handleError(state.copyWith(
        pronunciationError: Wrapped.value(CustomError(
          code: err.hashCode,
          message: err.toString(),
        )),
        pronunciationLoading: false,
      ), err, stack);
    }
  }

  Future<void> save(TranslationContainer translation, CancelToken? cancelToken) async {
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
          cancelToken: cancelToken,
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
      handleError(state.copyWith(
        updateLoading: false,
      ), err, stack);
      // we need to rethrow here because this "save" used as a bare Future
      // and if we don't throw, the Future will complete without error
      rethrow;
    }
  }

  Future<void> update(TranslationContainer translation, CancelToken? cancelToken) async {
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
          cancelToken: cancelToken,
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
      handleError(state.copyWith(
        updateLoading: false,
      ), err, stack);
      // we need to rethrow here because this "update" used as a bare Future
      // and if we don't throw, the Future will complete without error
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

  void resetImageSearchWord() {
    emit(state.copyWith(
      imageSearchWord: state.word,
    ));
  }

  void reset() {
    emit(const TranslationViewState());
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

