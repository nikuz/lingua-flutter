// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranslationContainer _$TranslationContainerFromJson(
        Map<String, dynamic> json) =>
    TranslationContainer(
      id: json['id'] as int?,
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

Translation _$TranslationFromJson(Map<String, dynamic> json) => Translation(
      gender: json['gender'] as String?,
      word: json['word'] as String?,
      sentences: (json['sentences'] as List<dynamic>?)
          ?.map((e) => TranslationSentence.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TranslationToJson(Translation instance) =>
    <String, dynamic>{
      'gender': instance.gender,
      'word': instance.word,
      'sentences': instance.sentences?.map((e) => e.toJson()).toList(),
    };

TranslationSentence _$TranslationSentenceFromJson(Map<String, dynamic> json) =>
    TranslationSentence(
      word: json['word'] as String,
    );

Map<String, dynamic> _$TranslationSentenceToJson(
        TranslationSentence instance) =>
    <String, dynamic>{
      'word': instance.word,
    };

TranslationAlternativeTranslation _$TranslationAlternativeTranslationFromJson(
        Map<String, dynamic> json) =>
    TranslationAlternativeTranslation(
      speechPart: json['speechPart'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => TranslationAlternativeTranslationItem.fromJson(
              e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TranslationAlternativeTranslationToJson(
        TranslationAlternativeTranslation instance) =>
    <String, dynamic>{
      'speechPart': instance.speechPart,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };

TranslationAlternativeTranslationItem
    _$TranslationAlternativeTranslationItemFromJson(
            Map<String, dynamic> json) =>
        TranslationAlternativeTranslationItem(
          genre: json['genre'] as String?,
          translation: json['translation'] as String,
          frequency: json['frequency'] as int,
          words:
              (json['words'] as List<dynamic>).map((e) => e as String).toList(),
        );

Map<String, dynamic> _$TranslationAlternativeTranslationItemToJson(
        TranslationAlternativeTranslationItem instance) =>
    <String, dynamic>{
      'genre': instance.genre,
      'translation': instance.translation,
      'frequency': instance.frequency,
      'words': instance.words,
    };

TranslationDefinition _$TranslationDefinitionFromJson(
        Map<String, dynamic> json) =>
    TranslationDefinition(
      speechPart: json['speechPart'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) =>
              TranslationDefinitionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      type: json['type'] as String?,
    );

Map<String, dynamic> _$TranslationDefinitionToJson(
        TranslationDefinition instance) =>
    <String, dynamic>{
      'speechPart': instance.speechPart,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'type': instance.type,
    };

TranslationDefinitionItem _$TranslationDefinitionItemFromJson(
        Map<String, dynamic> json) =>
    TranslationDefinitionItem(
      text: json['text'] as String,
      example: json['example'] as String?,
      type: json['type'] as String?,
    );

Map<String, dynamic> _$TranslationDefinitionItemToJson(
        TranslationDefinitionItem instance) =>
    <String, dynamic>{
      'text': instance.text,
      'example': instance.example,
      'type': instance.type,
    };

TranslationExample _$TranslationExampleFromJson(Map<String, dynamic> json) =>
    TranslationExample(
      text: json['text'] as String,
    );

Map<String, dynamic> _$TranslationExampleToJson(TranslationExample instance) =>
    <String, dynamic>{
      'text': instance.text,
    };
