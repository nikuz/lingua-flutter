import 'package:json_annotation/json_annotation.dart';
import './schema_item.dart';

part 'pronunciation_schema.g.dart';

@JsonSerializable(explicitToJson: true)
class PronunciationSchema {
  final PronunciationSchemaFields fields;
  final SchemaItem data;

  const PronunciationSchema({
    required this.fields,
    required this.data,
  });

  factory PronunciationSchema.fromJson(Map<String, dynamic> json) => _$PronunciationSchemaFromJson(json);
  Map<String, dynamic> toJson() => _$PronunciationSchemaToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PronunciationSchemaFields {
  final String url;
  final String parameter;
  final String body;
  final String marker;
  final String base64Prefix;

  const PronunciationSchemaFields({
    required this.url,
    required this.parameter,
    required this.body,
    required this.marker,
    required this.base64Prefix,
  });

  factory PronunciationSchemaFields.fromJson(Map<String, dynamic> json) => _$PronunciationSchemaFieldsFromJson(json);
  Map<String, dynamic> toJson() => _$PronunciationSchemaFieldsToJson(this);
}