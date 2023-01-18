import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lingua_flutter/models/error/error.dart';
import 'package:lingua_flutter/utils/types.dart';
import 'package:lingua_flutter/models/translation_container/translation_container.dart';

part 'translation_view_state.g.dart';

@JsonSerializable()
class TranslationViewState extends Equatable {
  final String? word;
  final TranslationContainer? translation;
  final List<String>? images;
  final String? imageSearchWord;
  final bool imageIsUpdated;
  final bool translationIsUpdated;
  final bool translateLoading;
  final bool imageLoading;
  final CustomError? imageError;
  final bool pronunciationLoading;
  final CustomError? pronunciationError;
  final bool updateLoading;
  final CustomError? error;

  const TranslationViewState({
    this.word,
    this.translation,
    this.images,
    this.imageSearchWord,
    this.imageIsUpdated = false,
    this.translationIsUpdated = false,
    this.translateLoading = false,
    this.imageLoading = false,
    this.imageError,
    this.pronunciationLoading = false,
    this.pronunciationError,
    this.updateLoading = false,
    this.error,
  });

  TranslationViewState copyWith({
    String? word,
    TranslationContainer? translation,
    List<String>? images,
    String? imageSearchWord,
    bool? imageIsUpdated,
    bool? translationIsUpdated,
    bool? translateLoading,
    bool? imageLoading,
    Wrapped<CustomError?>? imageError,
    bool? pronunciationLoading,
    Wrapped<CustomError?>? pronunciationError,
    bool? updateLoading,
    Wrapped<CustomError?>? error,
  }) {
    return TranslationViewState(
      word: word ?? this.word,
      translation: translation ?? this.translation,
      images: images ?? this.images,
      imageSearchWord: imageSearchWord ?? this.imageSearchWord,
      imageIsUpdated: imageIsUpdated ?? this.imageIsUpdated,
      translationIsUpdated: translationIsUpdated ?? this.translationIsUpdated,
      translateLoading: translateLoading ?? this.translateLoading,
      imageLoading: imageLoading ?? this.imageLoading,
      imageError: imageError != null ? imageError.value : this.imageError,
      pronunciationLoading: pronunciationLoading ?? this.pronunciationLoading,
      pronunciationError: pronunciationError != null ? pronunciationError.value : this.pronunciationError,
      updateLoading: updateLoading ?? this.updateLoading,
      error: error != null ? error.value : this.error,
    );
  }

  factory TranslationViewState.fromJson(Map<String, dynamic> json) => _$TranslationViewStateFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationViewStateToJson(this);

  @override
  List<Object?> get props => [
    word,
    translation,
    images,
    imageSearchWord,
    imageIsUpdated,
    translationIsUpdated,
    translateLoading,
    imageLoading,
    imageError,
    pronunciationLoading,
    pronunciationError,
    updateLoading,
    error,
  ];
}