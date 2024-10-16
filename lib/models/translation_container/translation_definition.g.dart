// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_definition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranslationDefinition _$TranslationDefinitionFromJson(
        Map<String, dynamic> json) =>
    TranslationDefinition(
      speechPart: json['speechPart'] as String?,
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
