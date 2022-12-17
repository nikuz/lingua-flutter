// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_schema.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranslationSchema _$TranslationSchemaFromJson(Map<String, dynamic> json) =>
    TranslationSchema(
      fields: TranslationSchemaFields.fromJson(
          json['fields'] as Map<String, dynamic>),
      word: SchemaItem.fromJson(json['word'] as Map<String, dynamic>),
      autoSpellingFix:
          SchemaItem.fromJson(json['autoSpellingFix'] as Map<String, dynamic>),
      transcription:
          SchemaItem.fromJson(json['transcription'] as Map<String, dynamic>),
      translations: TranslationSchemaTranslations.fromJson(
          json['translations'] as Map<String, dynamic>),
      alternativeTranslations:
          TranslationSchemaAlternativeTranslations.fromJson(
              json['alternativeTranslations'] as Map<String, dynamic>),
      definitions: TranslationSchemaDefinitions.fromJson(
          json['definitions'] as Map<String, dynamic>),
      examples: TranslationSchemaExamples.fromJson(
          json['examples'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TranslationSchemaToJson(TranslationSchema instance) =>
    <String, dynamic>{
      'fields': instance.fields.toJson(),
      'word': instance.word.toJson(),
      'autoSpellingFix': instance.autoSpellingFix.toJson(),
      'transcription': instance.transcription.toJson(),
      'translations': instance.translations.toJson(),
      'alternativeTranslations': instance.alternativeTranslations.toJson(),
      'definitions': instance.definitions.toJson(),
      'examples': instance.examples.toJson(),
    };

TranslationSchemaFields _$TranslationSchemaFieldsFromJson(
        Map<String, dynamic> json) =>
    TranslationSchemaFields(
      url: json['url'] as String,
      parameter: json['parameter'] as String,
      body: json['body'] as String,
      marker: json['marker'] as String,
    );

Map<String, dynamic> _$TranslationSchemaFieldsToJson(
        TranslationSchemaFields instance) =>
    <String, dynamic>{
      'url': instance.url,
      'parameter': instance.parameter,
      'body': instance.body,
      'marker': instance.marker,
    };

TranslationSchemaTranslations _$TranslationSchemaTranslationsFromJson(
        Map<String, dynamic> json) =>
    TranslationSchemaTranslations(
      value: json['value'] as String,
      word: SchemaItem.fromJson(json['word'] as Map<String, dynamic>),
      gender: SchemaItem.fromJson(json['gender'] as Map<String, dynamic>),
      sentences: TranslationSchemaTranslationsSentences.fromJson(
          json['sentences'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TranslationSchemaTranslationsToJson(
        TranslationSchemaTranslations instance) =>
    <String, dynamic>{
      'value': instance.value,
      'word': instance.word.toJson(),
      'gender': instance.gender.toJson(),
      'sentences': instance.sentences.toJson(),
    };

TranslationSchemaTranslationsSentences
    _$TranslationSchemaTranslationsSentencesFromJson(
            Map<String, dynamic> json) =>
        TranslationSchemaTranslationsSentences(
          value: json['value'] as String,
          word: SchemaItem.fromJson(json['word'] as Map<String, dynamic>),
        );

Map<String, dynamic> _$TranslationSchemaTranslationsSentencesToJson(
        TranslationSchemaTranslationsSentences instance) =>
    <String, dynamic>{
      'value': instance.value,
      'word': instance.word.toJson(),
    };

TranslationSchemaAlternativeTranslations
    _$TranslationSchemaAlternativeTranslationsFromJson(
            Map<String, dynamic> json) =>
        TranslationSchemaAlternativeTranslations(
          value: json['value'] as String,
          speechPart:
              SchemaItem.fromJson(json['speechPart'] as Map<String, dynamic>),
          items: TranslationSchemaAlternativeTranslationsItems.fromJson(
              json['items'] as Map<String, dynamic>),
        );

Map<String, dynamic> _$TranslationSchemaAlternativeTranslationsToJson(
        TranslationSchemaAlternativeTranslations instance) =>
    <String, dynamic>{
      'value': instance.value,
      'speechPart': instance.speechPart.toJson(),
      'items': instance.items.toJson(),
    };

TranslationSchemaAlternativeTranslationsItems
    _$TranslationSchemaAlternativeTranslationsItemsFromJson(
            Map<String, dynamic> json) =>
        TranslationSchemaAlternativeTranslationsItems(
          value: json['value'] as String,
          genre: SchemaItem.fromJson(json['genre'] as Map<String, dynamic>),
          translation:
              SchemaItem.fromJson(json['translation'] as Map<String, dynamic>),
          words: SchemaItem.fromJson(json['words'] as Map<String, dynamic>),
          frequency:
              SchemaItem.fromJson(json['frequency'] as Map<String, dynamic>),
        );

Map<String, dynamic> _$TranslationSchemaAlternativeTranslationsItemsToJson(
        TranslationSchemaAlternativeTranslationsItems instance) =>
    <String, dynamic>{
      'value': instance.value,
      'genre': instance.genre.toJson(),
      'translation': instance.translation.toJson(),
      'words': instance.words.toJson(),
      'frequency': instance.frequency.toJson(),
    };

TranslationSchemaDefinitions _$TranslationSchemaDefinitionsFromJson(
        Map<String, dynamic> json) =>
    TranslationSchemaDefinitions(
      value: json['value'] as String,
      speechPart:
          SchemaItem.fromJson(json['speechPart'] as Map<String, dynamic>),
      type: SchemaItem.fromJson(json['type'] as Map<String, dynamic>),
      items: TranslationSchemaDefinitionsItems.fromJson(
          json['items'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TranslationSchemaDefinitionsToJson(
        TranslationSchemaDefinitions instance) =>
    <String, dynamic>{
      'value': instance.value,
      'speechPart': instance.speechPart.toJson(),
      'type': instance.type.toJson(),
      'items': instance.items.toJson(),
    };

TranslationSchemaDefinitionsItems _$TranslationSchemaDefinitionsItemsFromJson(
        Map<String, dynamic> json) =>
    TranslationSchemaDefinitionsItems(
      value: json['value'] as String,
      text: SchemaItem.fromJson(json['text'] as Map<String, dynamic>),
      example: SchemaItem.fromJson(json['example'] as Map<String, dynamic>),
      type: SchemaItem.fromJson(json['type'] as Map<String, dynamic>),
      synonyms: TranslationSchemaDefinitionsSynonyms.fromJson(
          json['synonyms'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TranslationSchemaDefinitionsItemsToJson(
        TranslationSchemaDefinitionsItems instance) =>
    <String, dynamic>{
      'value': instance.value,
      'text': instance.text.toJson(),
      'example': instance.example.toJson(),
      'type': instance.type.toJson(),
      'synonyms': instance.synonyms.toJson(),
    };

TranslationSchemaDefinitionsSynonyms
    _$TranslationSchemaDefinitionsSynonymsFromJson(Map<String, dynamic> json) =>
        TranslationSchemaDefinitionsSynonyms(
          value: json['value'] as String,
          type: SchemaItem.fromJson(json['type'] as Map<String, dynamic>),
          items: TranslationSchemaDefinitionsSynonymsItems.fromJson(
              json['items'] as Map<String, dynamic>),
        );

Map<String, dynamic> _$TranslationSchemaDefinitionsSynonymsToJson(
        TranslationSchemaDefinitionsSynonyms instance) =>
    <String, dynamic>{
      'value': instance.value,
      'type': instance.type.toJson(),
      'items': instance.items.toJson(),
    };

TranslationSchemaDefinitionsSynonymsItems
    _$TranslationSchemaDefinitionsSynonymsItemsFromJson(
            Map<String, dynamic> json) =>
        TranslationSchemaDefinitionsSynonymsItems(
          value: json['value'] as String,
          text: SchemaItem.fromJson(json['text'] as Map<String, dynamic>),
        );

Map<String, dynamic> _$TranslationSchemaDefinitionsSynonymsItemsToJson(
        TranslationSchemaDefinitionsSynonymsItems instance) =>
    <String, dynamic>{
      'value': instance.value,
      'text': instance.text.toJson(),
    };

TranslationSchemaExamples _$TranslationSchemaExamplesFromJson(
        Map<String, dynamic> json) =>
    TranslationSchemaExamples(
      value: json['value'] as String,
      text: SchemaItem.fromJson(json['text'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TranslationSchemaExamplesToJson(
        TranslationSchemaExamples instance) =>
    <String, dynamic>{
      'value': instance.value,
      'text': instance.text.toJson(),
    };
