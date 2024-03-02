import 'package:json_annotation/json_annotation.dart';
import 'package:jmespath/jmespath.dart' as jmespath;
import 'package:lingua_flutter/models/parsing_schema/schema.dart';
import 'package:lingua_flutter/models/language/language.dart';
import 'package:lingua_flutter/models/quick_translation/quick_translation.dart';
import 'package:lingua_flutter/utils/types.dart';

import './translation.dart';
import './translation_example.dart';
import './translation_definition.dart';
import './translation_alternative.dart';

export './translation.dart';
export './translation_example.dart';
export './translation_definition.dart';
export './translation_alternative.dart';

part 'translation_container.g.dart';

@JsonSerializable(explicitToJson: true)
class TranslationContainer {
  final int? id;
  final int? cloudId;
  final String word;
  final String? autoSpelling;
  final String? autoLanguage;
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
    this.cloudId,
    required this.word,
    this.autoSpelling,
    this.autoLanguage,
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
    int? cloudId,
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

        if (items != null) {
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

        if (items != null) {
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
      cloudId: cloudId,
      word: word,
      autoSpelling: getDynamicString(jmespath.search(schema.translation.autoSpelling.value, raw)),
      autoLanguage: getDynamicString(jmespath.search(schema.translation.autoLanguage.value, raw)),
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

  factory TranslationContainer.fromQuickTranslation(QuickTranslation quickTranslation) {
    return TranslationContainer(
      word: quickTranslation.word,
      translation: quickTranslation.translation,
      translateFrom: quickTranslation.translateFrom,
      translateTo: quickTranslation.translateTo,
    );
  }

  TranslationContainer copyWith({
    int? id,
    int? cloudId,
    String? word,
    String? autoSpelling,
    String? autoLanguage,
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
      cloudId: cloudId ?? this.cloudId,
      word: word ?? this.word,
      autoSpelling: autoSpelling ?? this.autoSpelling,
      autoLanguage: autoLanguage ?? this.autoLanguage,
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