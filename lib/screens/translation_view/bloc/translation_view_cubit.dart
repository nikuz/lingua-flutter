import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/controllers/request/request.dart' show CancelToken, DioError;
import 'package:lingua_flutter/models/quick_translation/quick_translation.dart';
import 'package:lingua_flutter/models/translation_container/translation_container.dart';
import 'package:lingua_flutter/models/error/error.dart';
import 'package:lingua_flutter/models/language/language.dart';
import 'package:lingua_flutter/controllers/dictionary/dictionary.dart' as dictionary_controller;
import 'package:lingua_flutter/controllers/translation/translation.dart' as translation_controller;
import 'package:lingua_flutter/controllers/images/images.dart' as images_controller;
import 'package:lingua_flutter/controllers/pronunciation/pronunciation.dart' as pronunciation_controller;
import 'package:lingua_flutter/controllers/cloud/cloud.dart' as cloud_controller;
import 'package:lingua_flutter/utils/types.dart';
import 'package:lingua_flutter/controllers/error_logger/error_logger.dart';

import './translation_view_state.dart';

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

      TranslationContainer? translation;

      translation = await translation_controller.localTranslate(
        word: word,
        translateFrom: translateFrom,
        translateTo: translateTo,
      );

      if (translation == null) {
        List<Future<dynamic>> requestList = [translation_controller.cloudTranslate(
          word: word,
          translateFrom: translateFrom,
          translateTo: translateTo,
          cancelToken: cancelToken,
        )];

        String? quickTranslation = state.translation?.translation;
        if (quickTranslation == null) {
          requestList.add(translation_controller.quickTranslate(
            word: word,
            translateFrom: translateFrom,
            translateTo: translateTo,
            cancelToken: cancelToken,
          ));
        }
        List<dynamic> results = await Future.wait(requestList);
        translation = results[0] as TranslationContainer?;
        if (results.length > 1) {
          quickTranslation = (results[1] as QuickTranslation?)?.translation;
        }

        if (quickTranslation != null && translation != null) {
          translation = translation.copyWith(
            translation: quickTranslation,
          );
        }
      }

      if (state.translateLoading) {
        emit(state.copyWith(
          word: word,
          imageSearchWord: word,
          translation: translation?.copyWith(
            image: state.translation?.image,
            pronunciationFrom: state.translation?.pronunciationFrom,
            pronunciationTo: state.translation?.pronunciationTo,
          ),
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
      final List<String>? images = await images_controller.search(word: word, cancelToken: cancelToken);
      String? image;
      if (images != null && images.isNotEmpty) {
        image = images[0];
      }

      emit(state.copyWith(
        images: images ?? [], // set empty list if image controller returns null instead of image list
        imageLoading: false,
        translation: selectFirstImage
            ? state.translation?.copyWith(image: image)
            : state.translation,
        imageIsUpdated: selectFirstImage ? true : state.imageIsUpdated,
      ));
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

  void fetchPronunciations({
    required String word,
    required Language translateFrom,
    required String translation,
    required Language translateTo,
    CancelToken? cancelToken,
  }) async {
    emit(state.copyWith(
      pronunciationLoading: true,
    ));

    try {
      List<String?> results = await Future.wait([
        pronunciation_controller.retrieve(
          word: word,
          language: translateFrom,
          cancelToken: cancelToken,
        ),
        pronunciation_controller.retrieve(
          word: translation,
          language: translateTo,
          cancelToken: cancelToken,
        ),
      ]);

      if (state.translation != null && state.translation!.word == word) {
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
          language: translation.translateTo,
          cancelToken: cancelToken,
        );
      }
      if (newPronunciationTo != null) {
        translation = translation.copyWith(
          pronunciationTo: newPronunciationTo,
        );
      }

      final newTranslationId = await dictionary_controller.save(translation);

      // do not wait saveWord response, cloud sync is not important for user experience
      cloud_controller.saveWord(translation.copyWith(id: newTranslationId));

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
          language: translation.translateTo,
          cancelToken: cancelToken,
        );
      }
      if (newPronunciationTo != null) {
        translation = translation.copyWith(
          pronunciationTo: newPronunciationTo,
        );
      }

      await dictionary_controller.update(translation);

      // do not wait updateWord response, cloud sync is not important for user experience
      cloud_controller.updateWord(translation);

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

