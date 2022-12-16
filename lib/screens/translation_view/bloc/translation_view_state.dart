import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lingua_flutter/models/error.dart';
import 'package:lingua_flutter/utils/types.dart';
import 'package:lingua_flutter/models/translation.dart';

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
    updateLoading,
    error,
  ];
}