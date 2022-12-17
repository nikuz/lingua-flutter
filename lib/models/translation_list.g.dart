// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranslationList _$TranslationListFromJson(Map<String, dynamic> json) =>
    TranslationList(
      from: json['from'] as int,
      to: json['to'] as int,
      totalAmount: json['totalAmount'] as int,
      translations: (json['translations'] as List<dynamic>)
          .map((e) => TranslationContainer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TranslationListToJson(TranslationList instance) =>
    <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
      'totalAmount': instance.totalAmount,
      'translations': instance.translations.map((e) => e.toJson()).toList(),
    };
