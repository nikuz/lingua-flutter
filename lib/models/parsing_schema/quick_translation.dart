import 'package:json_annotation/json_annotation.dart';
import './schema_item.dart';

part 'quick_translation.g.dart';

@JsonSerializable(explicitToJson: true)
class QuickTranslationSchema {
  final QuickTranslationSchemaFields fields;
  final SchemaItem autoLanguage;
  final QuickTranslationSchemaSentences sentences;

  const QuickTranslationSchema({
    required this.fields,
    required this.autoLanguage,
    required this.sentences,
  });

  factory QuickTranslationSchema.fromJson(Map<String, dynamic> json) => _$QuickTranslationSchemaFromJson(json);
  Map<String, dynamic> toJson() => _$QuickTranslationSchemaToJson(this);
}

@JsonSerializable(explicitToJson: true)
class QuickTranslationSchemaFields {
  final String url;

  const QuickTranslationSchemaFields({
    required this.url,
  });

  factory QuickTranslationSchemaFields.fromJson(Map<String, dynamic> json) => _$QuickTranslationSchemaFieldsFromJson(json);
  Map<String, dynamic> toJson() => _$QuickTranslationSchemaFieldsToJson(this);
}

@JsonSerializable(explicitToJson: true)
class QuickTranslationSchemaSentences {
  final String value;
  final String word;
  final String translation;

  const QuickTranslationSchemaSentences({
    required this.value,
    required this.word,
    required this.translation,
  });

  factory QuickTranslationSchemaSentences.fromJson(Map<String, dynamic> json) => _$QuickTranslationSchemaSentencesFromJson(json);
  Map<String, dynamic> toJson() => _$QuickTranslationSchemaSentencesToJson(this);
}