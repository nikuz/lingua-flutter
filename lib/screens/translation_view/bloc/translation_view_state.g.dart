// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_view_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranslationViewState _$TranslationViewStateFromJson(
        Map<String, dynamic> json) =>
    TranslationViewState(
      id: json['id'] as int?,
      word: json['word'] as String?,
      translationWord: json['translationWord'] as String?,
      translationOwn: json['translationOwn'] as String?,
      pronunciation: json['pronunciation'] as String?,
      image: json['image'] as String?,
      imageUrl: json['imageUrl'] as String?,
      images: json['images'] as List<dynamic>? ?? const [],
      imageUpdate: json['imageUpdate'] as bool?,
      imageSearchWord: json['imageSearchWord'] as String?,
      translateLoading: json['translateLoading'] as bool? ?? false,
      imageLoading: json['imageLoading'] as bool? ?? false,
      highestRelevantTranslation:
          json['highestRelevantTranslation'] as List<dynamic>?,
      transcription: json['transcription'] as String?,
      otherTranslations: json['otherTranslations'] as List<dynamic>?,
      definitions: json['definitions'] as List<dynamic>?,
      definitionsSynonyms: json['definitionsSynonyms'] as List<dynamic>?,
      examples: json['examples'] as List<dynamic>?,
      autoSpellingFix: json['autoSpellingFix'] as String?,
      strangeWord: json['strangeWord'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      raw: json['raw'] as List<dynamic>?,
      remote: json['remote'] as bool?,
      saveLoading: json['saveLoading'] as bool?,
      savedTranslation: json['savedTranslation'] == null
          ? null
          : Translation.fromJson(
              json['savedTranslation'] as Map<String, dynamic>),
      updateLoading: json['updateLoading'] as bool?,
      updatedTranslation: json['updatedTranslation'] == null
          ? null
          : Translation.fromJson(
              json['updatedTranslation'] as Map<String, dynamic>),
      version: json['version'] as int?,
      error: json['error'],
    );

Map<String, dynamic> _$TranslationViewStateToJson(
        TranslationViewState instance) =>
    <String, dynamic>{
      'id': instance.id,
      'word': instance.word,
      'translationWord': instance.translationWord,
      'translationOwn': instance.translationOwn,
      'pronunciation': instance.pronunciation,
      'highestRelevantTranslation': instance.highestRelevantTranslation,
      'transcription': instance.transcription,
      'otherTranslations': instance.otherTranslations,
      'definitions': instance.definitions,
      'definitionsSynonyms': instance.definitionsSynonyms,
      'examples': instance.examples,
      'autoSpellingFix': instance.autoSpellingFix,
      'strangeWord': instance.strangeWord,
      'image': instance.image,
      'imageUrl': instance.imageUrl,
      'imageUpdate': instance.imageUpdate,
      'images': instance.images,
      'imageSearchWord': instance.imageSearchWord,
      'translateLoading': instance.translateLoading,
      'imageLoading': instance.imageLoading,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'saveLoading': instance.saveLoading,
      'savedTranslation': instance.savedTranslation,
      'updateLoading': instance.updateLoading,
      'updatedTranslation': instance.updatedTranslation,
      'raw': instance.raw,
      'remote': instance.remote,
      'version': instance.version,
      'error': instance.error,
    };
