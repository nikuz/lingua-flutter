import 'package:json_annotation/json_annotation.dart';
import './schema.dart';

export './schema.dart';

part 'stored_schema.g.dart';

@JsonSerializable(explicitToJson: true)
class StoredParsingSchema {
  final String version;
  final ParsingSchema schema;
  final bool current;
  final int createdAt; // JS Date.now()
  final int? updatedAt; // JS Date.now()

  const StoredParsingSchema({
    required this.version,
    required this.schema,
    required this.current,
    required this.createdAt,
    this.updatedAt,
  });

  factory StoredParsingSchema.fromFirestore(Map<String, dynamic> snapshot, Map<String, dynamic> schemaJson) {
    return StoredParsingSchema(
      version: snapshot['version'],
      schema: ParsingSchema(
        // translation
        translation: TranslationSchema(
          fields: TranslationSchemaFields(
            url: schemaJson['translation']['fields']['url'],
            parameter: schemaJson['translation']['fields']['parameter'],
            body: schemaJson['translation']['fields']['body'],
            marker: schemaJson['translation']['fields']['marker'],
          ),

          //
          word: SchemaItem(value: schemaJson['translation']['word']['value']),
          autoSpelling: SchemaItem(value: schemaJson['translation']['auto_spelling_fix']['value']),
          autoLanguage: SchemaItem(value: schemaJson['translation']['auto_language_code']['value']),
          transcription: SchemaItem(value: schemaJson['translation']['transcription']['value']),

          // translation
          translations: TranslationSchemaTranslations(
            value: schemaJson['translation']['translations']['value'],
            word: SchemaItem(value: schemaJson['translation']['translations']['word']['value']),
            gender: SchemaItem(value: schemaJson['translation']['translations']['gender']['value']),
            sentences: TranslationSchemaTranslationsSentences(
              value: schemaJson['translation']['translations']['sentences']['value'],
              word: SchemaItem(value: schemaJson['translation']['translations']['sentences']['word']['value']),
            ),
          ),

          // alternative translations
          alternativeTranslations: TranslationSchemaAlternativeTranslations(
            value: schemaJson['translation']['alternative_translations']['value'],
            speechPart: SchemaItem(value: schemaJson['translation']['alternative_translations']['speech_part']['value']),
            items: TranslationSchemaAlternativeTranslationsItems(
              value: schemaJson['translation']['alternative_translations']['items']['value'],
              genre: SchemaItem(value: schemaJson['translation']['alternative_translations']['items']['genre']['value']),
              translation: SchemaItem(value: schemaJson['translation']['alternative_translations']['items']['translation']['value']),
              frequency: SchemaItem(value: schemaJson['translation']['alternative_translations']['items']['frequency']['value']),
              words: SchemaItem(value: schemaJson['translation']['alternative_translations']['items']['words']['value']),
            ),
          ),

          // definitions
          definitions: TranslationSchemaDefinitions(
            value: schemaJson['translation']['definitions']['value'],
            speechPart: SchemaItem(value: schemaJson['translation']['definitions']['speech_part']['value']),
            type: SchemaItem(value: schemaJson['translation']['definitions']['type']['value']),
            items: TranslationSchemaDefinitionsItems(
              value: schemaJson['translation']['definitions']['items']['value'],
              text: SchemaItem(value: schemaJson['translation']['definitions']['items']['text']['value']),
              example: SchemaItem(value: schemaJson['translation']['definitions']['items']['example']['value']),
              type: SchemaItem(value: schemaJson['translation']['definitions']['items']['type']['value']),
              synonyms: TranslationSchemaDefinitionsSynonyms(
                value: schemaJson['translation']['definitions']['items']['synonyms']['value'],
                type: SchemaItem(value: schemaJson['translation']['definitions']['items']['synonyms']['type']['value']),
                items: TranslationSchemaDefinitionsSynonymsItems(
                  value: schemaJson['translation']['definitions']['items']['synonyms']['items']['value'],
                  text: SchemaItem(value: schemaJson['translation']['definitions']['items']['synonyms']['items']['text']['value']),
                ),
              ),
            ),
          ),

          // examples
          examples: TranslationSchemaExamples(
            value: schemaJson['translation']['examples']['value'],
            text: SchemaItem(value: schemaJson['translation']['examples']['text']['value']),
          ),
        ),

        // pronunciation
        pronunciation: PronunciationSchema(
          fields: PronunciationSchemaFields(
            url: schemaJson['pronunciation']['fields']['url'],
            parameter: schemaJson['pronunciation']['fields']['parameter'],
            body: schemaJson['pronunciation']['fields']['body'],
            marker: schemaJson['pronunciation']['fields']['marker'],
            base64Prefix: schemaJson['pronunciation']['fields']['base64Prefix'],
          ),
          data: SchemaItem(value: schemaJson['pronunciation']['data']['value']),
        ),

        // images
        images: ImagesSchema(
          fields: ImagesSchemaFields(
            url: schemaJson['images']['fields']['url'],
            userAgent: schemaJson['images']['fields']['userAgent'],
            regExp: schemaJson['images']['fields']['regExp'],
            minSize: schemaJson['images']['fields']['minSize'],
          ),
        ),
      ),
      current: snapshot['current'],
      createdAt: snapshot['createdAt'],
      updatedAt: snapshot['updatedAt'],
    );
  }

  factory StoredParsingSchema.fromJson(Map<String, dynamic> json) => _$StoredParsingSchemaFromJson(json);
  Map<String, dynamic> toJson() => _$StoredParsingSchemaToJson(this);
}