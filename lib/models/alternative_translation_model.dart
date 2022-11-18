import 'package:json_annotation/json_annotation.dart';

part 'alternative_translation_model.g.dart';

@JsonSerializable()
class AlternativeTranslation {
  final String word;
  final List<String> synonyms;
  final int? frequency; // indicates how often translation appears in public documents

  const AlternativeTranslation({
    required this.word,
    required this.synonyms,
    this.frequency,
  });

  factory AlternativeTranslation.fromJson(Map<String, dynamic> json) => _$AlternativeTranslationFromJson(json);
  Map<String, dynamic> toJson() => _$AlternativeTranslationToJson(this);
}
