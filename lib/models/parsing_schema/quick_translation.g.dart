// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quick_translation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuickTranslationSchema _$QuickTranslationSchemaFromJson(
        Map<String, dynamic> json) =>
    QuickTranslationSchema(
      fields: QuickTranslationSchemaFields.fromJson(
          json['fields'] as Map<String, dynamic>),
      autoLanguage:
          SchemaItem.fromJson(json['autoLanguage'] as Map<String, dynamic>),
      sentences: QuickTranslationSchemaSentences.fromJson(
          json['sentences'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$QuickTranslationSchemaToJson(
        QuickTranslationSchema instance) =>
    <String, dynamic>{
      'fields': instance.fields.toJson(),
      'autoLanguage': instance.autoLanguage.toJson(),
      'sentences': instance.sentences.toJson(),
    };

QuickTranslationSchemaFields _$QuickTranslationSchemaFieldsFromJson(
        Map<String, dynamic> json) =>
    QuickTranslationSchemaFields(
      url: json['url'] as String,
    );

Map<String, dynamic> _$QuickTranslationSchemaFieldsToJson(
        QuickTranslationSchemaFields instance) =>
    <String, dynamic>{
      'url': instance.url,
    };

QuickTranslationSchemaSentences _$QuickTranslationSchemaSentencesFromJson(
        Map<String, dynamic> json) =>
    QuickTranslationSchemaSentences(
      value: json['value'] as String,
      word: json['word'] as String,
      translation: json['translation'] as String,
    );

Map<String, dynamic> _$QuickTranslationSchemaSentencesToJson(
        QuickTranslationSchemaSentences instance) =>
    <String, dynamic>{
      'value': instance.value,
      'word': instance.word,
      'translation': instance.translation,
    };
