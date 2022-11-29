import 'package:json_annotation/json_annotation.dart';
import './translation_schema.dart';
import './pronunciation_schema.dart';
import './images_schema.dart';

export './translation_schema.dart';
export './pronunciation_schema.dart';
export './images_schema.dart';
export './schema_item.dart';

part 'schema.g.dart';

@JsonSerializable(explicitToJson: true)
class ParsingSchema {
  final TranslationSchema translation;
  final PronunciationSchema pronunciation;
  final ImagesSchema images;

  const ParsingSchema({
    required this.translation,
    required this.pronunciation,
    required this.images,
  });

  factory ParsingSchema.fromJson(Map<String, dynamic> json) => _$ParsingSchemaFromJson(json);
  Map<String, dynamic> toJson() => _$ParsingSchemaToJson(this);
}