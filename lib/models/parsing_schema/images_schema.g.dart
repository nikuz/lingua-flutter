// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'images_schema.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImagesSchema _$ImagesSchemaFromJson(Map<String, dynamic> json) => ImagesSchema(
      fields:
          ImagesSchemaFields.fromJson(json['fields'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ImagesSchemaToJson(ImagesSchema instance) =>
    <String, dynamic>{
      'fields': instance.fields.toJson(),
    };

ImagesSchemaFields _$ImagesSchemaFieldsFromJson(Map<String, dynamic> json) =>
    ImagesSchemaFields(
      url: json['url'] as String,
      userAgent: json['userAgent'] as String,
      regExp: json['regExp'] as String,
      minSize: json['minSize'] as String,
    );

Map<String, dynamic> _$ImagesSchemaFieldsToJson(ImagesSchemaFields instance) =>
    <String, dynamic>{
      'url': instance.url,
      'userAgent': instance.userAgent,
      'regExp': instance.regExp,
      'minSize': instance.minSize,
    };
