// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pronunciation_schema.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PronunciationSchema _$PronunciationSchemaFromJson(Map<String, dynamic> json) =>
    PronunciationSchema(
      fields: PronunciationSchemaFields.fromJson(
          json['fields'] as Map<String, dynamic>),
      data: SchemaItem.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PronunciationSchemaToJson(
        PronunciationSchema instance) =>
    <String, dynamic>{
      'fields': instance.fields.toJson(),
      'data': instance.data.toJson(),
    };

PronunciationSchemaFields _$PronunciationSchemaFieldsFromJson(
        Map<String, dynamic> json) =>
    PronunciationSchemaFields(
      url: json['url'] as String,
      parameter: json['parameter'] as String,
      body: json['body'] as String,
      marker: json['marker'] as String,
      base64Prefix: json['base64Prefix'] as String,
    );

Map<String, dynamic> _$PronunciationSchemaFieldsToJson(
        PronunciationSchemaFields instance) =>
    <String, dynamic>{
      'url': instance.url,
      'parameter': instance.parameter,
      'body': instance.body,
      'marker': instance.marker,
      'base64Prefix': instance.base64Prefix,
    };
