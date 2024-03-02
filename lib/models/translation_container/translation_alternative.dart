import 'package:json_annotation/json_annotation.dart';

part 'translation_alternative.g.dart';

@JsonSerializable(explicitToJson: true)
class TranslationAlternativeTranslation {
  final String? speechPart;
  final List<TranslationAlternativeTranslationItem> items;

  const TranslationAlternativeTranslation({
    required this.speechPart,
    required this.items,
  });

  factory TranslationAlternativeTranslation.fromJson(Map<String, dynamic> json) => _$TranslationAlternativeTranslationFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationAlternativeTranslationToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TranslationAlternativeTranslationItem {
  final String? genre;
  final String translation;
  final int frequency;
  final List<String> words;

  const TranslationAlternativeTranslationItem({
    this.genre,
    required this.translation,
    required this.frequency,
    required this.words,
  });

  factory TranslationAlternativeTranslationItem.fromJson(Map<String, dynamic> json) => _$TranslationAlternativeTranslationItemFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationAlternativeTranslationItemToJson(this);
}