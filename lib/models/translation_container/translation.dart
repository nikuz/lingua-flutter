import 'package:json_annotation/json_annotation.dart';

part 'translation.g.dart';

// Translation
@JsonSerializable(explicitToJson: true)
class Translation {
  final String? gender;
  final String? word;
  final List<TranslationSentence>? sentences;

  const Translation({
    required this.gender,
    required this.word,
    this.sentences,
  });

  factory Translation.fromJson(Map<String, dynamic> json) => _$TranslationFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationToJson(this);

  @override
  toString() {
    if (gender != null && word != null) {
      return '$word $gender';
    }

    return sentences?.join(' ') ?? '';
  }
}

@JsonSerializable(explicitToJson: true)
class TranslationSentence {
  final String word;

  const TranslationSentence({
    required this.word,
  });

  factory TranslationSentence.fromJson(Map<String, dynamic> json) => _$TranslationSentenceFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationSentenceToJson(this);

  @override
  String toString() => word;
}