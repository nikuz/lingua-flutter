// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stored_schema.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoredParsingSchema _$StoredParsingSchemaFromJson(Map<String, dynamic> json) =>
    StoredParsingSchema(
      version: json['version'] as String,
      schema: ParsingSchema.fromJson(json['schema'] as Map<String, dynamic>),
      current: json['current'] as bool,
      createdAt: json['createdAt'] as int,
      updatedAt: json['updatedAt'] as int?,
    );

Map<String, dynamic> _$StoredParsingSchemaToJson(
        StoredParsingSchema instance) =>
    <String, dynamic>{
      'version': instance.version,
      'schema': instance.schema.toJson(),
      'current': instance.current,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
