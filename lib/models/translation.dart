import 'package:json_annotation/json_annotation.dart';
import 'package:jmespath/jmespath.dart' as jmespath;
import 'package:lingua_flutter/utils/types.dart';
import './parsing_schema/schema.dart';
import './language.dart';

part 'translation.g.dart';

@JsonSerializable(explicitToJson: true)
class TranslationContainer {
  final int? id;
  final String word;
  final String? autoSpellingFix;
  final String? transcription;
  // plain translation string is always present, usually populated from database or on creation at "fromRaw"
  final String translation;
  final List<Translation>? translations;
  final List<TranslationAlternativeTranslation>? alternativeTranslations;
  final List<TranslationDefinition>? definitions;
  final List<TranslationExample>? examples;
  final String? pronunciationFrom;
  final String? pronunciationTo;
  final String? image;
  final List<dynamic>? raw;
  final ParsingSchema? schema;
  final String? schemaVersion;
  final Language translateFrom;
  final Language translateTo;
  final String? createdAt;
  final String? updatedAt;

  const TranslationContainer({
    this.id,
    required this.word,
    this.autoSpellingFix,
    this.transcription,
    required this.translation,
    this.translations,
    this.alternativeTranslations,
    this.definitions,
    this.examples,
    this.pronunciationFrom,
    this.pronunciationTo,
    this.image,
    this.raw,
    this.schema,
    this.schemaVersion,
    required this.translateFrom,
    required this.translateTo,
    this.createdAt,
    this.updatedAt,
  });

  factory TranslationContainer.fromRaw({
    int? id,
    required String word,
    String? translation,
    String? pronunciationFrom,
    String? pronunciationTo,
    String? image,
    required List<dynamic> raw,
    required ParsingSchema schema,
    required String schemaVersion,
    required Language translateFrom,
    required Language translateTo,
    String? createdAt,
    String? updatedAt,
  }) {
    // translations
    TranslationSchemaTranslations translationsSchema = schema.translation.translations;
    List<dynamic>? translationsRaw = getDynamicList(jmespath.search(translationsSchema.value, raw));
    List<Translation>? translations;

    if (translationsRaw != null) {
      for (var item in translationsRaw) {
        String? word = getDynamicString(jmespath.search(translationsSchema.word.value, item));
        String? gender = getDynamicString(jmespath.search(translationsSchema.gender.value, item));
        List<dynamic>? sentencesRaw = getDynamicList(jmespath.search(translationsSchema.sentences.value, item));
        List<TranslationSentence>? sentences;

        if (sentencesRaw != null) {
          for (var sentence in sentencesRaw) {
            String? sentenceWord = getDynamicString(jmespath.search(translationsSchema.sentences.word.value, sentence));
            if (sentenceWord != null) {
              sentences ??= [];
              sentences.add(TranslationSentence(
                word: sentenceWord,
              ));
            }
          }
        }
        if ((word != null && gender != null) || sentences != null) {
          translations ??= [];
          translations.add(Translation(
            gender: gender,
            word: word,
            sentences: sentences,
          ));
        }
      }
    }

    // alternative translations
    TranslationSchemaAlternativeTranslations alternativeTranslationsSchema = schema.translation.alternativeTranslations;
    List<dynamic>? alternativeTranslationsRaw = getDynamicList(jmespath.search(alternativeTranslationsSchema.value, raw));
    List<TranslationAlternativeTranslation>? alternativeTranslations;

    if (alternativeTranslationsRaw != null) {
      for (var category in alternativeTranslationsRaw) {
        String? speechPart = getDynamicString(jmespath.search(alternativeTranslationsSchema.speechPart.value, category));
        List<dynamic>? itemsRaw = getDynamicList(jmespath.search(alternativeTranslationsSchema.items.value, category));
        List<TranslationAlternativeTranslationItem>? items;

        if (itemsRaw != null) {
          for (var item in itemsRaw) {
            String? genre = getDynamicString(jmespath.search(alternativeTranslationsSchema.items.genre.value, item));
            String? translation = getDynamicString(jmespath.search(alternativeTranslationsSchema.items.translation.value, item));
            int? frequency = getDynamicInt(jmespath.search(alternativeTranslationsSchema.items.frequency.value, item));
            List<dynamic>? words = getDynamicList(jmespath.search(alternativeTranslationsSchema.items.words.value, item));

            if (translation != null && frequency != null && words != null) {
              items ??= [];
              items.add(TranslationAlternativeTranslationItem(
                genre: genre,
                translation: translation,
                frequency: frequency,
                words: words.map((word) => word.toString()).toList(),
              ));
            }
          }
        }

        if (speechPart != null && items != null) {
          alternativeTranslations ??= [];
          alternativeTranslations.add(TranslationAlternativeTranslation(
            speechPart: speechPart,
            items: items,
          ));
        }
      }
    }

    // definitions
    TranslationSchemaDefinitions definitionsSchema = schema.translation.definitions;
    List<dynamic>? definitionsRaw = getDynamicList(jmespath.search(definitionsSchema.value, raw));
    List<TranslationDefinition>? definitions;

    if (definitionsRaw != null) {
      for (var category in definitionsRaw) {
        String? speechPart = getDynamicString(jmespath.search(definitionsSchema.speechPart.value, category));
        String? type = getDynamicString(jmespath.search(definitionsSchema.type.value, category));
        List<dynamic>? itemsRaw = getDynamicList(jmespath.search(definitionsSchema.items.value, category));
        List<TranslationDefinitionItem>? items;

        if (itemsRaw != null) {
          for (var item in itemsRaw) {
            String? text = getDynamicString(jmespath.search(definitionsSchema.items.text.value, item));
            String? example = getDynamicString(jmespath.search(definitionsSchema.items.example.value, item));

            if (text != null) {
              items ??= [];
              items.add(TranslationDefinitionItem(
                text: text,
                example: example,
                type: type,
              ));
            }
          }
        }

        if (speechPart != null && items != null) {
          definitions ??= [];
          definitions.add(TranslationDefinition(
            speechPart: speechPart,
            type: type,
            items: items,
          ));
        }
      }
    }

    // examples
    TranslationSchemaExamples examplesSchema = schema.translation.examples;
    List<dynamic>? examplesRaw = getDynamicList(jmespath.search(examplesSchema.value, raw));
    List<TranslationExample>? examples;

    if (examplesRaw != null) {
      for (var item in examplesRaw) {
        String? text = getDynamicString(jmespath.search(examplesSchema.text.value, item));
        if (text != null) {
          examples ??= [];
          examples.add(TranslationExample(text: text));
        }
      }
    }

    if (translations == null) {
      throw 'Can\'t parse raw data with current schema';
    }

    return TranslationContainer(
      id: id,
      word: word,
      autoSpellingFix: getDynamicString(jmespath.search(schema.translation.autoSpellingFix.value, raw)),
      transcription: getDynamicString(jmespath.search(schema.translation.transcription.value, raw)),
      translation: translation ?? translations.join(', '),
      translations: translations,
      alternativeTranslations: alternativeTranslations,
      definitions: definitions,
      examples: examples,
      pronunciationFrom: pronunciationFrom,
      pronunciationTo: pronunciationTo,
      image: image,
      raw: raw,
      schema: schema,
      schemaVersion: schemaVersion,
      translateFrom: translateFrom,
      translateTo: translateTo,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  String get mostRelevantTranslation {
    String translationWord = translation;

    // if translation contains gender-specific variants, then take first word from alternative translations instead
    if (translationWord.contains(',')) {
      final firstRelativeTranslation = alternativeTranslations?[0].items[0];
      if (firstRelativeTranslation != null) {
        translationWord = firstRelativeTranslation.translation;
      }
    }

    return translationWord;
  }

  TranslationContainer copyWith({
    int? id,
    String? word,
    String? autoSpellingFix,
    String? transcription,
    String? translation,
    List<Translation>? translations,
    List<TranslationAlternativeTranslation>? alternativeTranslations,
    List<TranslationDefinition>? definitions,
    List<TranslationExample>? examples,
    String? pronunciationFrom,
    String? pronunciationTo,
    String? image,
    List<dynamic>? raw,
    ParsingSchema? schema,
    String? schemaVersion,
    Language? translateFrom,
    Language? translateTo,
    String? createdAt,
    String? updatedAt,
  }) {
    return TranslationContainer(
      id: id ?? this.id,
      word: word ?? this.word,
      autoSpellingFix: autoSpellingFix ?? this.autoSpellingFix,
      transcription: transcription ?? this.transcription,
      translation: translation ?? this.translation,
      translations: translations ?? this.translations,
      alternativeTranslations: alternativeTranslations ?? this.alternativeTranslations,
      definitions: definitions ?? this.definitions,
      examples: examples ?? this.examples,
      pronunciationFrom: pronunciationFrom ?? this.pronunciationFrom,
      pronunciationTo: pronunciationTo ?? this.pronunciationTo,
      image: image ?? this.image,
      raw: raw ?? this.raw,
      schema: schema ?? this.schema,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      translateFrom: translateFrom ?? this.translateFrom,
      translateTo: translateTo ?? this.translateTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory TranslationContainer.fromJson(Map<String, dynamic> json) => _$TranslationContainerFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationContainerToJson(this);
}

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

// Alternative translations
@JsonSerializable(explicitToJson: true)
class TranslationAlternativeTranslation {
  final String speechPart;
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

// Definitions
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

// Example
@JsonSerializable(explicitToJson: true)
class TranslationExample {
  final String text;

  const TranslationExample({
    required this.text,
  });

  factory TranslationExample.fromJson(Map<String, dynamic> json) => _$TranslationExampleFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationExampleToJson(this);
}