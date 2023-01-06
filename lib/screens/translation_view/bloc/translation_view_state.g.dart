// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_view_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranslationViewState _$TranslationViewStateFromJson(
        Map<String, dynamic> json) =>
    TranslationViewState(
      word: json['word'] as String?,
      translation: json['translation'] == null
          ? null
          : TranslationContainer.fromJson(
              json['translation'] as Map<String, dynamic>),
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      imageSearchWord: json['imageSearchWord'] as String?,
      imageIsUpdated: json['imageIsUpdated'] as bool? ?? false,
      translationIsUpdated: json['translationIsUpdated'] as bool? ?? false,
      translateLoading: json['translateLoading'] as bool? ?? false,
      imageLoading: json['imageLoading'] as bool? ?? false,
      imageError: json['imageError'] == null
          ? null
          : CustomError.fromJson(json['imageError'] as Map<String, dynamic>),
      pronunciationLoading: json['pronunciationLoading'] as bool? ?? false,
      pronunciationError: json['pronunciationError'] == null
          ? null
          : CustomError.fromJson(
              json['pronunciationError'] as Map<String, dynamic>),
      updateLoading: json['updateLoading'] as bool? ?? false,
      error: json['error'] == null
          ? null
          : CustomError.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TranslationViewStateToJson(
        TranslationViewState instance) =>
    <String, dynamic>{
      'word': instance.word,
      'translation': instance.translation,
      'images': instance.images,
      'imageSearchWord': instance.imageSearchWord,
      'imageIsUpdated': instance.imageIsUpdated,
      'translationIsUpdated': instance.translationIsUpdated,
      'translateLoading': instance.translateLoading,
      'imageLoading': instance.imageLoading,
      'imageError': instance.imageError,
      'pronunciationLoading': instance.pronunciationLoading,
      'pronunciationError': instance.pronunciationError,
      'updateLoading': instance.updateLoading,
      'error': instance.error,
    };
