import 'package:json_annotation/json_annotation.dart';

part 'translation_example.g.dart';

@JsonSerializable(explicitToJson: true)
class TranslationExample {
  final String text;

  const TranslationExample({
    required this.text,
  });

  factory TranslationExample.fromJson(Map<String, dynamic> json) => _$TranslationExampleFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationExampleToJson(this);
}