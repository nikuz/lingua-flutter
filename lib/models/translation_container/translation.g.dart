// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
