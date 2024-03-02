// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quick_translation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuickTranslation _$QuickTranslationFromJson(Map<String, dynamic> json) =>
    QuickTranslation(
      word: json['word'] as String,
      translation: json['translation'] as String,
      autoLanguage: json['autoLanguage'] as String?,
      translateFrom:
          Language.fromJson(json['translateFrom'] as Map<String, dynamic>),
      translateTo:
          Language.fromJson(json['translateTo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$QuickTranslationToJson(QuickTranslation instance) =>
    <String, dynamic>{
      'word': instance.word,
      'translation': instance.translation,
      'autoLanguage': instance.autoLanguage,
      'translateFrom': instance.translateFrom.toJson(),
      'translateTo': instance.translateTo.toJson(),
    };
