import 'package:jmespath/jmespath.dart' as jmespath;
import 'package:json_annotation/json_annotation.dart';
import 'package:lingua_flutter/models/parsing_schema/schema.dart';
import 'package:lingua_flutter/models/translation_container/translation_container.dart';
import 'package:lingua_flutter/models/language/language.dart';
import 'package:lingua_flutter/utils/types.dart';

part 'quick_translation.g.dart';

@JsonSerializable(explicitToJson: true)
class QuickTranslation {
  final String word;
  final String translation;
  final String? autoLanguage;
  final Language translateFrom;
  final Language translateTo;

  const QuickTranslation({
    required this.word,
    required this.translation,
    required this.autoLanguage,
    required this.translateFrom,
    required this.translateTo,
  });

  factory QuickTranslation.fromJson(Map<String, dynamic> json) => _$QuickTranslationFromJson(json);
  Map<String, dynamic> toJson() => _$QuickTranslationToJson(this);

  factory QuickTranslation.fromRaw({
    required List<dynamic> raw,
    required ParsingSchema schema,
    required Language translateFrom,
    required Language translateTo,
  }) {
    String word = '';
    String translation = '';

    QuickTranslationSchemaSentences quickTranslationSchema = schema.quickTranslation.sentences;
    List<dynamic>? sentencesRaw = getDynamicList(jmespath.search(quickTranslationSchema.value, raw));

    if (sentencesRaw != null) {
      for (var i = 0, l = sentencesRaw.length; i < l; i++) {
        final sentence = sentencesRaw[i];
        String? sentenceWord = getDynamicString(jmespath.search(quickTranslationSchema.word, sentence));
        String? sentenceTranslation = getDynamicString(jmespath.search(quickTranslationSchema.translation, sentence));

        if (sentenceWord != null && sentenceTranslation != null) {
          word += '$sentenceWord${i != l - 1 ? ' ' : ''}'; // add tailing space for all sentences except the last one
          translation += sentenceTranslation;
        }
      }
    }

    return QuickTranslation(
      word: word,
      translation: translation,
      autoLanguage: getDynamicString(jmespath.search(schema.quickTranslation.autoLanguage.value, raw)),
      translateFrom: translateFrom,
      translateTo: translateTo,
    );
  }

  factory QuickTranslation.fromTranslationContainer(TranslationContainer translationContainer) {
    return QuickTranslation(
      word: translationContainer.word,
      translation: translationContainer.translation,
      autoLanguage: translationContainer.autoLanguage,
      translateFrom: translationContainer.translateFrom,
      translateTo: translationContainer.translateTo,
    );
  }

  @override
  toString() {
    return '$word $translation';
  }
}