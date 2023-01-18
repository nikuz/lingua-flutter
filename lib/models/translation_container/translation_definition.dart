import 'package:json_annotation/json_annotation.dart';

part 'translation_definition.g.dart';

@JsonSerializable(explicitToJson: true)
class TranslationDefinition {
  final String speechPart;
  final List<TranslationDefinitionItem> items;
  final String? type;

  const TranslationDefinition({
    required this.speechPart,
    required this.items,
    this.type,
  });

  factory TranslationDefinition.fromJson(Map<String, dynamic> json) => _$TranslationDefinitionFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationDefinitionToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TranslationDefinitionItem {
  final String text;
  final String? example;
  final String? type;

  const TranslationDefinitionItem({
    required this.text,
    required this.example,
    this.type,
  });

  factory TranslationDefinitionItem.fromJson(Map<String, dynamic> json) => _$TranslationDefinitionItemFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationDefinitionItemToJson(this);
}