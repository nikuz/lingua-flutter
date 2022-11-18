// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alternative_translation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlternativeTranslation _$AlternativeTranslationFromJson(
        Map<String, dynamic> json) =>
    AlternativeTranslation(
      word: json['word'] as String,
      synonyms:
          (json['synonyms'] as List<dynamic>).map((e) => e as String).toList(),
      frequency: json['frequency'] as int?,
    );

Map<String, dynamic> _$AlternativeTranslationToJson(
        AlternativeTranslation instance) =>
    <String, dynamic>{
      'word': instance.word,
      'synonyms': instance.synonyms,
      'frequency': instance.frequency,
    };
