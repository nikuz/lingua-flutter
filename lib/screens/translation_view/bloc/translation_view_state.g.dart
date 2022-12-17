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
      'updateLoading': instance.updateLoading,
      'error': instance.error,
    };
