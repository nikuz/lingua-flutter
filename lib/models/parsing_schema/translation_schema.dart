import 'package:json_annotation/json_annotation.dart';
import './schema_item.dart';

part 'translation_schema.g.dart';

@JsonSerializable(explicitToJson: true)
class TranslationSchema {
  final TranslationSchemaFields fields;
  final SchemaItem word;
  final SchemaItem autoSpellingFix;
  final SchemaItem translation;
  final SchemaItem transcription;
  final TranslationSchemaAlternativeTranslations alternativeTranslations;
  final TranslationSchemaDefinitions definitions;
  final TranslationSchemaExamples examples;

  const TranslationSchema({
    required this.fields,
    required this.word,
    required this.autoSpellingFix,
    required this.translation,
    required this.transcription,
    required this.alternativeTranslations,
    required this.definitions,
    required this.examples,
  });

  factory TranslationSchema.fromJson(Map<String, dynamic> json) => _$TranslationSchemaFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationSchemaToJson(this);
}

// Fields
@JsonSerializable(explicitToJson: true)
class TranslationSchemaFields {
  final String url;
  final String parameter;
  final String body;
  final String marker;

  const TranslationSchemaFields({
    required this.url,
    required this.parameter,
    required this.body,
    required this.marker,
  });

  factory TranslationSchemaFields.fromJson(Map<String, dynamic> json) => _$TranslationSchemaFieldsFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationSchemaFieldsToJson(this);
}

// Alternative translations
@JsonSerializable(explicitToJson: true)
class TranslationSchemaAlternativeTranslations {
  final String value;
  final SchemaItem speechPart;
  final TranslationSchemaAlternativeTranslationsItems items;

  const TranslationSchemaAlternativeTranslations({
    required this.value,
    required this.speechPart,
    required this.items,
  });

  factory TranslationSchemaAlternativeTranslations.fromJson(Map<String, dynamic> json) => _$TranslationSchemaAlternativeTranslationsFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationSchemaAlternativeTranslationsToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TranslationSchemaAlternativeTranslationsItems {
  final String value;
  final SchemaItem translation;
  final SchemaItem words;
  final SchemaItem frequency;

  const TranslationSchemaAlternativeTranslationsItems({
    required this.value,
    required this.translation,
    required this.words,
    required this.frequency,
  });

  factory TranslationSchemaAlternativeTranslationsItems.fromJson(Map<String, dynamic> json) => _$TranslationSchemaAlternativeTranslationsItemsFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationSchemaAlternativeTranslationsItemsToJson(this);
}

// Definitions
@JsonSerializable(explicitToJson: true)
class TranslationSchemaDefinitions {
  final String value;
  final SchemaItem speechPart;
  final SchemaItem type;
  final TranslationSchemaDefinitionsItems items;

  const TranslationSchemaDefinitions({
    required this.value,
    required this.speechPart,
    required this.type,
    required this.items,
  });

  factory TranslationSchemaDefinitions.fromJson(Map<String, dynamic> json) => _$TranslationSchemaDefinitionsFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationSchemaDefinitionsToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TranslationSchemaDefinitionsItems {
  final String value;
  final SchemaItem text;
  final SchemaItem example;
  final SchemaItem type;
  final TranslationSchemaDefinitionsSynonyms synonyms;

  const TranslationSchemaDefinitionsItems({
    required this.value,
    required this.text,
    required this.example,
    required this.type,
    required this.synonyms,
  });

  factory TranslationSchemaDefinitionsItems.fromJson(Map<String, dynamic> json) => _$TranslationSchemaDefinitionsItemsFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationSchemaDefinitionsItemsToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TranslationSchemaDefinitionsSynonyms {
  final String value;
  final SchemaItem type;
  final TranslationSchemaDefinitionsSynonymsItems items;

  const TranslationSchemaDefinitionsSynonyms({
    required this.value,
    required this.type,
    required this.items,
  });

  factory TranslationSchemaDefinitionsSynonyms.fromJson(Map<String, dynamic> json) => _$TranslationSchemaDefinitionsSynonymsFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationSchemaDefinitionsSynonymsToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TranslationSchemaDefinitionsSynonymsItems {
  final String value;
  final SchemaItem text;

  const TranslationSchemaDefinitionsSynonymsItems({
    required this.value,
    required this.text,
  });

  factory TranslationSchemaDefinitionsSynonymsItems.fromJson(Map<String, dynamic> json) => _$TranslationSchemaDefinitionsSynonymsItemsFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationSchemaDefinitionsSynonymsItemsToJson(this);
}

// Examples
@JsonSerializable(explicitToJson: true)
class TranslationSchemaExamples {
  final String value;
  final SchemaItem text;

  const TranslationSchemaExamples({
    required this.value,
    required this.text,
  });

  factory TranslationSchemaExamples.fromJson(Map<String, dynamic> json) => _$TranslationSchemaExamplesFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationSchemaExamplesToJson(this);
}