// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_alternative.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
