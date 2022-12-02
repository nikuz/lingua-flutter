import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lingua_flutter/models/error.dart';
import 'package:lingua_flutter/utils/types.dart';
import 'package:lingua_flutter/models/translation.dart';

part 'translation_view_state.g.dart';

@JsonSerializable()
class TranslationViewState extends Equatable {
  final String? word;
  final Translation? translation;
  final String? image;
  final List<String>? images;
  final String? imageSearchWord;
  final String? ownTranslation;
  final bool imageIsUpdated;
  final bool translateLoading;
  final bool imageLoading;
  final bool updateLoading;
  final CustomError? error;

  const TranslationViewState({
    this.word,
    this.translation,
    this.image,
    this.images,
    this.imageSearchWord,
    this.ownTranslation,
    this.imageIsUpdated = false,
    this.translateLoading = false,
    this.imageLoading = false,
    this.updateLoading = false,
    this.error,
  });

  TranslationViewState copyWith({
    String? word,
    Translation? translation,
    String? image,
    List<String>? images,
    String? imageSearchWord,
    String? ownTranslation,
    bool? imageIsUpdated,
    bool? translateLoading,
    bool? imageLoading,
    bool? updateLoading,
    Wrapped? error,
  }) {
    return TranslationViewState(
      word: word ?? this.word,
      translation: translation ?? this.translation,
      image: image ?? this.image,
      images: images ?? this.images,
      imageSearchWord: imageSearchWord ?? this.imageSearchWord,
      ownTranslation: ownTranslation ?? this.ownTranslation,
      imageIsUpdated: imageIsUpdated ?? this.imageIsUpdated,
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
    image,
    images,
    imageSearchWord,
    ownTranslation,
    imageIsUpdated,
    translateLoading,
    imageLoading,
    updateLoading,
    error,
  ];
}