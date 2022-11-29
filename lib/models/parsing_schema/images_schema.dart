import 'package:json_annotation/json_annotation.dart';

part 'images_schema.g.dart';

@JsonSerializable(explicitToJson: true)
class ImagesSchema {
  final ImagesSchemaFields fields;

  const ImagesSchema({
    required this.fields,
  });

  factory ImagesSchema.fromJson(Map<String, dynamic> json) => _$ImagesSchemaFromJson(json);
  Map<String, dynamic> toJson() => _$ImagesSchemaToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ImagesSchemaFields {
  final String url;
  final String userAgent;
  final String regExp;
  final String minSize;

  const ImagesSchemaFields({
    required this.url,
    required this.userAgent,
    required this.regExp,
    required this.minSize,
  });

  factory ImagesSchemaFields.fromJson(Map<String, dynamic> json) => _$ImagesSchemaFieldsFromJson(json);
  Map<String, dynamic> toJson() => _$ImagesSchemaFieldsToJson(this);
}