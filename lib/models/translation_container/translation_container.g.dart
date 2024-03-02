// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_container.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranslationContainer _$TranslationContainerFromJson(
        Map<String, dynamic> json) =>
    TranslationContainer(
      id: json['id'] as int?,
      cloudId: json['cloudId'] as int?,
      word: json['word'] as String,
      autoSpelling: json['autoSpelling'] as String?,
      autoLanguage: json['autoLanguage'] as String?,
      transcription: json['transcription'] as String?,
      translation: json['translation'] as String,
      translations: (json['translations'] as List<dynamic>?)
          ?.map((e) => Translation.fromJson(e as Map<String, dynamic>))
          .toList(),
      alternativeTranslations:
          (json['alternativeTranslations'] as List<dynamic>?)
              ?.map((e) => TranslationAlternativeTranslation.fromJson(
                  e as Map<String, dynamic>))
              .toList(),
      definitions: (json['definitions'] as List<dynamic>?)
          ?.map(
              (e) => TranslationDefinition.fromJson(e as Map<String, dynamic>))
          .toList(),
      examples: (json['examples'] as List<dynamic>?)
          ?.map((e) => TranslationExample.fromJson(e as Map<String, dynamic>))
          .toList(),
      pronunciationFrom: json['pronunciationFrom'] as String?,
      pronunciationTo: json['pronunciationTo'] as String?,
      image: json['image'] as String?,
      raw: json['raw'] as List<dynamic>?,
      schema: json['schema'] == null
          ? null
          : ParsingSchema.fromJson(json['schema'] as Map<String, dynamic>),
      schemaVersion: json['schemaVersion'] as String?,
      translateFrom:
          Language.fromJson(json['translateFrom'] as Map<String, dynamic>),
      translateTo:
          Language.fromJson(json['translateTo'] as Map<String, dynamic>),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$TranslationContainerToJson(
        TranslationContainer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cloudId': instance.cloudId,
      'word': instance.word,
      'autoSpelling': instance.autoSpelling,
      'autoLanguage': instance.autoLanguage,
      'transcription': instance.transcription,
      'translation': instance.translation,
      'translations': instance.translations?.map((e) => e.toJson()).toList(),
      'alternativeTranslations':
          instance.alternativeTranslations?.map((e) => e.toJson()).toList(),
      'definitions': instance.definitions?.map((e) => e.toJson()).toList(),
      'examples': instance.examples?.map((e) => e.toJson()).toList(),
      'pronunciationFrom': instance.pronunciationFrom,
      'pronunciationTo': instance.pronunciationTo,
      'image': instance.image,
      'raw': instance.raw,
      'schema': instance.schema?.toJson(),
      'schemaVersion': instance.schemaVersion,
      'translateFrom': instance.translateFrom.toJson(),
      'translateTo': instance.translateTo.toJson(),
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
